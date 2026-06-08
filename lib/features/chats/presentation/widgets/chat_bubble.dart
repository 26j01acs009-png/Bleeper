import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/chat_message_model.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = message.isMe ? context.accent : context.surface;
    final textColor = message.isMe ? Colors.white : context.textPrimary;

    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: AppSpacing.xs + 2,
          left: message.isMe ? AppSpacing.xl : 0,
          right: message.isMe ? 0 : AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment:
              message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md + 2,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(message.isMe ? 16 : 4),
                  topRight: Radius.circular(message.isMe ? 4 : 16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                message.text,
                style: AppTypography.body(textColor).copyWith(height: 1.3),
              ),
            ),
            if (message.timeAgo != null) ...[
              SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.timeAgo!,
                    style: AppTypography.caption(context.textTertiary),
                  ),
                  if (message.isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 14,
                      color: message.isRead ? context.accent : context.textTertiary,
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
