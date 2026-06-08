import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../shared/widgets/default_avatar.dart';
import '../../data/chats_repository.dart';
import '../../data/messages_provider.dart';
import '../../../profile/domain/models/profile_model.dart';
import '../widgets/chat_header.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  const ChatScreen({required this.chatId, super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatsRepository _chatsRepository = ChatsRepository(
    Supabase.instance.client,
  );
  ProfileModel? _otherUser;
  final TextEditingController _textController = TextEditingController();
  bool _isLoadingHeader = true;

  @override
  void initState() {
    super.initState();
    _loadChatHeader();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagesProvider>().loadMessages(widget.chatId);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadChatHeader() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final participants = await Supabase.instance.client
          .from('chat_participants')
          .select('user_id')
          .eq('chat_id', widget.chatId)
          .neq('user_id', userId);

      final participantsList = participants as List<dynamic>;
      if (participantsList.isEmpty) return;

      final otherUserId = participantsList.first['user_id'] as String;
      final profileData = await _chatsRepository.getProfileById(otherUserId);

      if (!mounted) return;

      setState(() {
        _otherUser = profileData;
        _isLoadingHeader = false;
      });
    } catch (e) {
      setState(() => _isLoadingHeader = false);
    }
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final senderId = Supabase.instance.client.auth.currentUser?.id;
    if (senderId == null) return;

    context.read<MessagesProvider>().sendMessage(widget.chatId, senderId, text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesProvider = context.watch<MessagesProvider>();
    final messages = messagesProvider.messages;

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            if (_isLoadingHeader)
              Container(
                padding: EdgeInsets.all(context.spacingMd),
                decoration: BoxDecoration(
                  color: context.bg,
                  border: Border(bottom: BorderSide(color: context.divider)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.chevron_left, size: 28, color: context.textPrimary),
                    ),
                    SizedBox(width: context.spacingSm),
                    Expanded(
                      child: Text(
                        widget.chatId.substring(0, 8),
                        style: context.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            else
              ChatHeader(
                name: _otherUser?.displayName ?? _otherUser?.username ?? 'Unknown',
                avatarUrl: _otherUser?.avatarUrl,
                isOnline: _otherUser?.isOnline ?? false,
                onBack: () => Navigator.pop(context),
                onMore: () {},
              ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: context.screenPadding,
                  vertical: context.screenPadding,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return ChatBubble(message: msg);
                },
              ),
            ),
            ChatInput(
              controller: _textController,
              onSend: _handleSend,
            ),
          ],
        ),
      ),
    );
  }
}
