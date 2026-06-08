import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../widgets/chat_card.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatData = [
      {
        'name': 'Alice Chen',
        'preview': 'Sure, sounds good!',
        'timeAgo': '2m',
        'avatarUrl': 'https://i.pravatar.cc/150?img=1',
        'isOnline': true,
        'unreadCount': 3,
        'isRead': false,
      },
      {
        'name': 'Bob Smith',
        'preview': 'Can you send me the files?',
        'timeAgo': '15m',
        'avatarUrl': 'https://i.pravatar.cc/150?img=2',
        'isOnline': true,
        'unreadCount': 1,
        'isRead': false,
      },
      {
        'name': 'Charlie',
        'preview': 'Thanks for the help!',
        'timeAgo': '1h',
        'avatarUrl': null,
        'isOnline': false,
        'unreadCount': null,
        'isRead': true,
      },
      {
        'name': 'Diana Prince',
        'preview': 'Let’s meet tomorrow at 5pm',
        'timeAgo': '2h',
        'avatarUrl': 'https://i.pravatar.cc/150?img=3',
        'isOnline': true,
        'unreadCount': 5,
        'isRead': false,
      },
      {
        'name': 'Eve Wilson',
        'preview': 'Okay, I’ll check it out',
        'timeAgo': '3h',
        'avatarUrl': 'https://i.pravatar.cc/150?img=4',
        'isOnline': false,
        'unreadCount': null,
        'isRead': true,
      },
      {
        'name': 'Frank Miller',
        'preview': 'Haha, that’s funny 😂',
        'timeAgo': '5h',
        'avatarUrl': null,
        'isOnline': true,
        'unreadCount': null,
        'isRead': true,
      },
      {
        'name': 'Grace Lee',
        'preview': 'Call me when you can',
        'timeAgo': '8h',
        'avatarUrl': 'https://i.pravatar.cc/150?img=5',
        'isOnline': false,
        'unreadCount': 2,
        'isRead': false,
      },
      {
        'name': 'Henry Ford',
        'preview': 'I’ll get back to you later',
        'timeAgo': '1d',
        'avatarUrl': 'https://i.pravatar.cc/150?img=6',
        'isOnline': false,
        'unreadCount': null,
        'isRead': true,
      },
    ];

    return Scaffold(
      backgroundColor: context.bg,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.screenPadding),
            child: Row(children: [Text('Chats', style: context.h1)]),
          ),
          SizedBox(height: context.spacingMd),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.screenPadding),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacingLg,
                  vertical: context.spacingMd,
                ),
                decoration: BoxDecoration(
                  color: context.surfaceAlt,
                  borderRadius: BorderRadius.circular(context.radiusRound),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: context.textSecondary, size: 20),
                    SizedBox(width: context.spacingSm),
                    Text(
                      'Search chats',
                      style: context.bodyMedium.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: context.spacingMd),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10),
              itemCount: chatData.length,
              itemBuilder: (context, index) {
                final chat = chatData[index];
                return ChatCard(
                  name: chat['name'] as String,
                  preview: chat['preview'] as String,
                  timeAgo: chat['timeAgo'] as String,
                  onTap: () => context.push('/chat/$index'),
                  avatarUrl: chat['avatarUrl'] as String?,
                  isOnline: chat['isOnline'] as bool,
                  unreadCount: chat['unreadCount'] as int?,
                  isRead: chat['isRead'] as bool,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
