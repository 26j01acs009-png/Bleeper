import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../shared/widgets.dart';

class ChatCard extends StatelessWidget {
  const ChatCard({
    super.key,
    required this.name,
    required this.preview,
    required this.timeAgo,
    required this.onTap,
    this.avatarUrl,
    this.isOnline = false,
    this.unreadCount,
    this.isRead = true,
  });

  final String name;
  final String preview;
  final String timeAgo;
  final VoidCallback onTap;
  final String? avatarUrl;
  final bool isOnline;
  final int? unreadCount;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: context.spacingSm + 2),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                avatarUrl != null
                    ? CircleAvatar(
                        radius: 24,
                        backgroundColor: context.accent.withValues(alpha: 0.15),
                        backgroundImage: NetworkImage(avatarUrl!),
                      )
                    : const DefaultAvatar(size: 48),
                if (isOnline)
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
                          name,
                          style: context.bodyMedium.copyWith(
                            fontWeight: unreadCount != null ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: context.caption.copyWith(
                          color: unreadCount != null ? context.accent : context.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      if (!isRead && preview.isNotEmpty) ...[
                        Icon(
                          Icons.done_all,
                          size: 14,
                          color: context.accent,
                        ),
                        SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          preview,
                          style: context.bodySmall.copyWith(
                            color: unreadCount != null ? context.textPrimary : context.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount != null && unreadCount! > 0)
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
                            '$unreadCount',
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
