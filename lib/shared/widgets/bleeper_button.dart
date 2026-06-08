import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_data.dart';

class BleeperButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const BleeperButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 56,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? context.accent;
    final effectiveFg = foregroundColor ?? Colors.white;
    final isDisabled = onPressed == null || isLoading;

    Widget buttonChild = isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveFg),
            ),
          )
        : Text(
            label,
            style: context.h3.copyWith(
              color: effectiveFg,
              fontWeight: FontWeight.w600,
            ),
          );

    Widget button = ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? context.textTertiary.withValues(alpha: 0.3) : effectiveBg,
        foregroundColor: effectiveFg,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.radiusRound),
        ),
        padding: EdgeInsets.zero,
        disabledBackgroundColor: context.textTertiary.withValues(alpha: 0.3),
      ),
      child: buttonChild,
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, height: height, child: button);
    }

    return SizedBox(width: 160, height: height, child: button);
  }
}
