import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../widgets/chat_card.dart';
import '../../data/chats_provider.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatsProvider = context.watch<ChatsProvider>();
    final chats = chatsProvider.chats;

    return Scaffold(
      backgroundColor: context.bg,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/new-message'),
        backgroundColor: context.accent,
        child: HugeIcon(
          icon: HugeIconsStrokeRounded.messageAdd01,
          color: Colors.white,
          size: 24,
        ),
      ),
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
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ChatCard(
                  chat: chat,
                  onTap: () => context.push('/chat/${chat.id}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
