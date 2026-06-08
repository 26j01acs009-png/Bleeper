import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_data.dart';

class SeeMoreCard extends StatelessWidget {
  const SeeMoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: EdgeInsets.only(right: context.spacingSm),
      decoration: BoxDecoration(
        color: context.surfaceAlt,
        borderRadius: BorderRadius.circular(context.radiusMd),
      ),
      child: Center(
        child: Text(
          'See more',
          style: context.bodyMedium.copyWith(
            color: context.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
