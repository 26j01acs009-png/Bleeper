import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../widgets/chat_header.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;
  const ChatScreen({required this.chatId, super.key});

  @override
  Widget build(BuildContext context) {
    final chat = _getChatData(chatId);

    return Scaffold(
      backgroundColor: context.bg,
      body: SafeArea(
        child: Column(
          children: [
            ChatHeader(
              name: chat['name'],
              avatarUrl: chat['avatarUrl'],
              isOnline: chat['isOnline'],
              onBack: () => Navigator.pop(context),
              onMore: () {},
            ),
            Expanded(
              child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: context.screenPadding,
                vertical: context.screenPadding,
              ),
                itemCount: chat['messages'].length,
                itemBuilder: (context, index) {
                  final msg = chat['messages'][index];
                  return ChatBubble(
                    text: msg['text'],
                    timeAgo: msg['timeAgo'],
                    isMe: msg['isMe'],
                    isRead: msg['isRead'],
                  );
                },
              ),
            ),
            ChatInput(),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getChatData(String chatId) {
    final index = int.tryParse(chatId) ?? 0;
    return {
      'name': 'User $index',
      'avatarUrl': index % 3 == 0 ? 'https://i.pravatar.cc/150?img=$index' : null,
      'isOnline': index % 2 == 0,
      'messages': [
        {
          'text': 'Hey, how are you?',
          'timeAgo': '10:30 AM',
          'isMe': false,
          'isRead': true,
        },
        {
          'text': 'I’m good, thanks! How about you?',
          'timeAgo': '10:32 AM',
          'isMe': true,
          'isRead': true,
        },
        {
          'text': 'Doing great! Want to grab coffee later?',
          'timeAgo': '10:33 AM',
          'isMe': false,
          'isRead': true,
        },
        {
          'text': 'Sure, sounds good!',
          'timeAgo': '10:35 AM',
          'isMe': true,
          'isRead': true,
        },
        {
          'text': 'See you at 5pm then!',
          'timeAgo': '10:36 AM',
          'isMe': false,
          'isRead': false,
        },
      ],
    };
  }
}
