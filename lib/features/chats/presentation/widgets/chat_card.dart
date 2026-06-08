import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../shared/widgets.dart';
import '../../domain/models/chat_model.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({
    super.key,
    required this.chat,
    required this.onTap,
  });

  final Chat chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = chat;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: context.spacingSm + 2),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                c.avatarUrl != null
                    ? CircleAvatar(
                        radius: 24,
                        backgroundColor: context.accent.withValues(alpha: 0.15),
                        backgroundImage: NetworkImage(c.avatarUrl!),
                      )
                    : const DefaultAvatar(size: 48),
                if (c.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(color: context.bg, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: context.spacingMd + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.name,
                          style: context.bodyMedium.copyWith(
                            fontWeight: c.unreadCount != null
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        c.timeAgo,
                        style: context.caption.copyWith(
                          color: c.unreadCount != null
                              ? context.accent
                              : context.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      if (!c.isRead && c.preview.isNotEmpty) ...[
                        Icon(
                          Icons.done_all,
                          size: 14,
                          color: context.accent,
                        ),
                        SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          c.preview,
                          style: context.bodySmall.copyWith(
                            color: c.unreadCount != null
                                ? context.textPrimary
                                : context.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (c.unreadCount != null && c.unreadCount! > 0)
                        Container(
                          margin: EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.accent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${c.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
