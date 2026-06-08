import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.text,
    this.timeAgo,
    this.isMe = false,
    this.isRead = false,
  });

  final String text;
  final String? timeAgo;
  final bool isMe;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? context.accent : context.surface;
    final textColor = isMe ? Colors.white : context.textPrimary;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: AppSpacing.xs + 2,
          left: isMe ? AppSpacing.xl : 0,
          right: isMe ? 0 : AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md + 2,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMe ? 16 : 4),
                  topRight: Radius.circular(isMe ? 4 : 16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                text,
                style: AppTypography.body(textColor).copyWith(height: 1.3),
              ),
            ),
            if (timeAgo != null) ...[
              SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeAgo!,
                    style: AppTypography.caption(context.textTertiary),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      isRead ? Icons.done_all : Icons.done,
                      size: 14,
                      color: isRead ? context.accent : context.textTertiary,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
