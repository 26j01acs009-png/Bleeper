import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme_data.dart';

class CommunityCard extends StatelessWidget {
  const CommunityCard({required this.data, super.key});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final name = data['name'] ?? 'Community';
    final description = data['description'] ?? '';
    final memberCount = data['member_count'] ?? 0;
    final avatarUrl = data['avatar_url'] as String?;

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
                avatarUrl != null
                    ? CircleAvatar(
                        radius: 20,
                        backgroundImage: CachedNetworkImageProvider(avatarUrl),
                      )
                    : Container(
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
                    name,
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
              '$memberCount members',
              style: context.bodyMedium.copyWith(color: context.textSecondary),
            ),
            SizedBox(height: context.spacingSm),
            Text(
              description.isEmpty ? 'No description provided.' : description,
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
