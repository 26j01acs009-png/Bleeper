import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_data.dart';

class TopicChip extends StatelessWidget {
  const TopicChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: context.spacingSm),
      padding: EdgeInsets.symmetric(
        horizontal: context.spacingLg,
        vertical: context.spacingXs,
      ),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(context.radiusRound),
        border: Border.all(color: context.divider),
      ),
      child: Text(label, style: context.bodyMedium),
    );
  }
}
