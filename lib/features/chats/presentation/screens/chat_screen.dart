import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../widgets/chat_header.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../../data/messages_provider.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;
  const ChatScreen({required this.chatId, super.key});

  @override
  Widget build(BuildContext context) {
    final messagesProvider = context.watch<MessagesProvider>();
    final messages = messagesProvider.messages;

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            ChatHeader(
              name: 'User $chatId',
              avatarUrl: chatId.contains('0') ? 'https://i.pravatar.cc/150?img=0' : null,
              isOnline: chatId.contains('0'),
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
            ChatInput(),
          ],
        ),
      ),
    );
  }
}
