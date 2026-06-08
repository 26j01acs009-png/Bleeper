import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_data.dart';

class CommunityCard extends StatelessWidget {
  const CommunityCard({required this.index, super.key});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: context.spacingSm),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(context.radiusMd),
        border: Border.all(color: context.divider),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.group, size: 20, color: context.accent),
                ),
                SizedBox(width: context.spacingSm),
                Expanded(
                  child: Text(
                    'Community $index',
                    style: context.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.spacingSm),
            Text(
              '${(index + 1) * 124} members',
              style: context.bodyMedium.copyWith(color: context.textSecondary),
            ),
            SizedBox(height: context.spacingSm),
            Text(
              'Discuss the latest trends and share ideas with the community.',
              style: context.bodyMedium.copyWith(
                color: context.textPrimary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: context.spacingSm),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: context.spacingLg,
                  vertical: context.spacingSm,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: context.accent,
                side: const BorderSide(color: Colors.transparent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.radiusSm),
                ),
              ),
              child: Text(
                'Join',
                style: context.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
