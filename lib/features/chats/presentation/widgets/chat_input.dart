import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class ChatInput extends StatelessWidget {
  const ChatInput({super.key, this.onSend});

  final VoidCallback? onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border(top: BorderSide(color: context.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: AppTypography.body(context.textSecondary),
                filled: true,
                fillColor: context.surfaceAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: onSend,
            icon: HugeIcon(
              icon: HugeIconsStrokeRounded.sent,
              size: 24.0,
              color: context.accent,
            ),
          ),
        ],
      ),
    );
  }
}
