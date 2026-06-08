import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_data.dart';

class DiscussionInput extends StatelessWidget {
  const DiscussionInput({
    super.key,
    this.controller,
    this.focusNode,
    this.onSubmit,
  });

  static const _maxLength = 800;

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final text = controller?.text ?? '';
    final remaining = _maxLength - text.length;
    final isOverLimit = remaining < 0;

    return Container(
      margin: EdgeInsets.fromLTRB(
        context.screenPadding,
        0,
        context.screenPadding,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.spacingSm,
        vertical: context.spacingXs,
      ),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(context.radiusRound),
        border: Border.all(
          color: isOverLimit ? context.error : context.divider,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLength: _maxLength,
                  decoration: InputDecoration(
                    hintText: 'Add to the discussion...',
                    hintStyle: context.bodySmall.copyWith(
                      color: context.textTertiary,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: context.spacingSm,
                    ),
                    counterText: '',
                  ),
                  style: context.bodySmall,
                  onSubmitted: (_) => onSubmit?.call(),
                ),
              ),
              GestureDetector(
                onTap: isOverLimit ? null : onSubmit,
                child: Container(
                  padding: EdgeInsets.all(context.spacingSm),
                  decoration: BoxDecoration(
                    color: isOverLimit
                        ? context.textSecondary
                        : context.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.send,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (remaining <= _maxLength * 0.2)
            Padding(
              padding: EdgeInsets.only(
                left: context.spacingSm,
                right: context.spacingSm,
                bottom: context.spacingXs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$remaining',
                    style: context.caption.copyWith(
                      color: isOverLimit ? context.error : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
