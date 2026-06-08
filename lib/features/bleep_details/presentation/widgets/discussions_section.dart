import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../features/bleep_details/domain/entities/discussion.dart';
import '../../../../shared/widgets/bleeper_loading_indicator.dart';

class DiscussionsSection extends StatelessWidget {
  const DiscussionsSection({
    super.key,
    required this.discussions,
    required this.isLoading,
  });

  final List<Discussion> discussions;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discussions',
          style: context.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.spacingSm),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: BleeperLoadingIndicator(size: 32),
            ),
          )
        else if (discussions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No discussions yet.',
                style: context.bodySmall.copyWith(
                  color: context.textTertiary,
                ),
              ),
            ),
          )
        else
          ...discussions.map((discussion) {
            final authorName = discussion.displayName ?? discussion.username ?? 'User';
            final avatarUrl = discussion.avatarUrl;
            final content = discussion.content;

            return Padding(
              padding: EdgeInsets.symmetric(vertical: context.spacingSm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: context.accent.withValues(alpha: 0.12),
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl == null
                        ? Icon(Icons.person, size: 16, color: context.accent)
                        : null,
                  ),
                  SizedBox(width: context.spacingSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorName,
                          style: context.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                        SizedBox(height: context.spacingXs / 2),
                        Text(
                          content,
                          style: context.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
