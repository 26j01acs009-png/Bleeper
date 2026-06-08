import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_data.dart';

class DiscussionInput extends StatelessWidget {
  const DiscussionInput({
    super.key,
    this.controller,
    this.focusNode,
    this.onSubmit,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
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
        border: Border.all(color: context.divider, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
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
              ),
              style: context.bodySmall,
              onSubmitted: (_) => onSubmit?.call(),
            ),
          ),
          GestureDetector(
            onTap: onSubmit,
            child: Container(
              padding: EdgeInsets.all(context.spacingSm),
              decoration: BoxDecoration(
                color: context.accent,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
