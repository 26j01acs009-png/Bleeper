import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_data.dart';

class DiscoverSearchBar extends StatelessWidget {
  const DiscoverSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.spacingLg,
          vertical: context.spacingMd,
        ),
        decoration: BoxDecoration(
          color: context.surfaceAlt,
          borderRadius: BorderRadius.circular(context.radiusRound),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: context.textSecondary, size: 20),
            SizedBox(width: context.spacingSm),
            Text(
              'Search Bleeper',
              style: context.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
