import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:provider/provider.dart';
import '../../../../../features/profile/data/profile_provider.dart';
import '../../../../../core/theme/app_theme_data.dart';
import '../../../../../shared/widgets.dart';

class SettingsProfileCard extends StatelessWidget {
  const SettingsProfileCard({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final profile = profileProvider.profile;
        final isLoading = profileProvider.isLoading;
        final finalAvatar = profile?.avatarUrl;

        String displayName;
        String displayUsername;

        if (isLoading && profile == null) {
          displayName = 'Loading...';
          displayUsername = '';
        } else if (profile != null) {
          displayName = profile.displayName ?? profile.username ?? 'User';
          displayUsername = '@${profile.username ?? ''}';
        } else {
          displayName = 'Guest';
          displayUsername = '';
        }

        return Container(
          padding: EdgeInsets.all(context.cardPadding),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(context.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: isLoading ? null : onTap,
            borderRadius: BorderRadius.circular(context.radiusLg),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE5E7EB),
                  ),
                  child: finalAvatar != null && finalAvatar.isNotEmpty
                      ? CircleAvatar(
                          radius: 28,
                          backgroundColor: context.accent.withValues(alpha: 0.15),
                          backgroundImage: NetworkImage(finalAvatar),
                        )
                      : const DefaultAvatar(size: 56),
                ),
                SizedBox(width: context.spacingLg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: context.h2,
                      ),
                      if (displayUsername.isNotEmpty) ...[
                        SizedBox(height: context.spacingXs),
                        Text(
                          displayUsername,
                          style: context.bodySmall.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                HugeIcon(
                  icon: HugeIconsStrokeRounded.arrowRight01,
                  size: 20,
                  color: context.textSecondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
