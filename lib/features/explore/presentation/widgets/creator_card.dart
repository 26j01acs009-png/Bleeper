import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/widgets.dart';
import '../../../../core/theme/app_theme_data.dart';

class CreatorCard extends StatelessWidget {
  const CreatorCard({
    required this.data,
    this.isFollowing = false,
    this.onFollowTap,
    super.key,
  });

  final Map<String, dynamic> data;
  final bool isFollowing;
  final VoidCallback? onFollowTap;

  @override
  Widget build(BuildContext context) {
    final username = data['username'] ?? '@unknown';
    final displayName = data['display_name'] ?? 'Unknown';
    final avatarUrl = data['avatar_url'] as String?;
    final followersCount = data['followers_count'] ?? 0;

    return Container(
      width: 130,
      margin: EdgeInsets.only(right: context.spacingSm),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(context.radiusMd),
        border: Border.all(color: context.divider),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.spacingSm,
          vertical: context.spacingXs,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              avatarUrl != null
                  ? CircleAvatar(
                      radius: 20,
                      backgroundImage: CachedNetworkImageProvider(avatarUrl),
                    )
                  : const DefaultAvatar(size: 40),
              SizedBox(height: context.spacingXs),
              Text(
                displayName,
                style: context.bodySmall.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2),
              Text(
                username,
                style: context.bodySmall.copyWith(color: context.textSecondary),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                '$followersCount followers',
                style: context.bodySmall.copyWith(color: context.textSecondary, fontSize: 11),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacingXs),
               Center(
                 child: TextButton(
                   onPressed: onFollowTap ?? () {},
                   style: TextButton.styleFrom(
                     padding: EdgeInsets.symmetric(
                       horizontal: context.spacingLg,
                       vertical: context.spacingSm,
                     ),
                     minimumSize: Size.zero,
                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                     backgroundColor: isFollowing ? context.divider : context.accent,
                     side: const BorderSide(color: Colors.transparent),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(context.radiusSm),
                     ),
                   ),
                   child: Text(
                     isFollowing ? 'Following' : 'Follow',
                     style: context.bodySmall.copyWith(
                       color: isFollowing ? context.textSecondary : Colors.white,
                       fontWeight: FontWeight.w600,
                     ),
                   ),
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
