import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_data.dart';

class CreateBottomBar extends StatelessWidget {
  const CreateBottomBar({
    required this.onPickFromCamera,
    required this.onPickImage,
    required this.visibilityLabel,
    required this.onVisibilityTap,
    required this.replyLabel,
    required this.replyTap,
    required this.remainingChars,
    required this.isOverLimit,
    required this.isNearLimit,
    super.key,
  });

  final VoidCallback onPickFromCamera;
  final VoidCallback onPickImage;
  final String visibilityLabel;
  final VoidCallback onVisibilityTap;
  final String replyLabel;
  final VoidCallback replyTap;
  final int remainingChars;
  final bool isOverLimit;
  final bool isNearLimit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.screenPadding,
        vertical: context.spacingSm,
      ),
      decoration: BoxDecoration(
        color: context.bg,
        border: Border(
          top: BorderSide(color: context.divider, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: onPickFromCamera,
              icon: const Icon(Icons.camera_alt_outlined, size: 20),
              color: context.accent,
              tooltip: 'Camera',
            ),
            IconButton(
              onPressed: onPickImage,
              icon: const Icon(Icons.image_outlined, size: 20),
              color: context.accent,
              tooltip: 'Gallery',
            ),
            _SettingChip(
              icon: Icons.public,
              label: visibilityLabel,
              onTap: onVisibilityTap,
            ),
            _SettingChip(
              icon: Icons.chat_bubble_outline,
              label: replyLabel,
              onTap: replyTap,
            ),
            const Spacer(),
            Text(
              '$remainingChars',
              style: context.bodySmall.copyWith(
                color: isOverLimit
                    ? context.error
                    : isNearLimit
                        ? context.accent
                        : context.textSecondary,
                fontWeight: isOverLimit || isNearLimit
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingChip extends StatelessWidget {
  const _SettingChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: context.textSecondary,
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 60,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 14,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
