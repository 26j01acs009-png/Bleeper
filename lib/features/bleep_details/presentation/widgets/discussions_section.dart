import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../features/bleep_details/domain/entities/discussion.dart';
import '../../../../shared/widgets/bleeper_loading_indicator.dart';
import '../../../../shared/widgets/default_avatar.dart';

class DiscussionsSection extends StatelessWidget {
  const DiscussionsSection({
    super.key,
    required this.discussions,
    required this.isLoading,
    this.totalCount = 0,
    this.error,
    this.currentUserId,
    this.onDeleteDiscussion,
  });

  final List<Discussion> discussions;
  final bool isLoading;
  final int totalCount;
  final String? error;
  final String? currentUserId;
  final Future<void> Function(String discussionId)? onDeleteDiscussion;

  @override
  Widget build(BuildContext context) {
    final countText = totalCount == 1 ? '1 reply' : '$totalCount replies';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Discussions',
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (totalCount > 0) ...[
              SizedBox(width: context.spacingXs),
              Text(
                '• $countText',
                style: context.caption.copyWith(
                  color: context.textTertiary,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: context.spacingSm),
        if (error != null)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Failed: $error',
              style: context.bodySmall.copyWith(color: context.error),
            ),
          )
        else if (isLoading)
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
            final authorName =
                discussion.displayName ?? discussion.username ?? 'User';
            final authorUsername = discussion.username;
            final avatarUrl = discussion.avatarUrl;
            final content = discussion.content;
            final isMine = currentUserId != null &&
                discussion.userId == currentUserId;

            return Padding(
              padding: EdgeInsets.symmetric(vertical: context.spacingSm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      context.push('/identity/${discussion.userId}');
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: context.accent.withValues(alpha: 0.12),
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null ? const DefaultAvatar(size: 32) : null,
                    ),
                  ),
                  SizedBox(width: context.spacingSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.push('/identity/${discussion.userId}');
                              },
                              child: Text(
                                authorName,
                                style: context.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: context.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (authorUsername != null) ...[
                              SizedBox(width: 4),
                              Text(
                                '@$authorUsername',
                                style: context.caption.copyWith(
                                  color: context.textTertiary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const Spacer(),
                            if (isMine)
                              _ActionIcon(
                                icon: Icons.delete_outline,
                                color: context.error,
                                onTap: () async {
                                  if (onDeleteDiscussion != null) {
                                    await onDeleteDiscussion!(discussion.id);
                                  }
                                },
                              )
                            else
                              _ActionIcon(
                                icon: Icons.flag_outlined,
                                color: context.textSecondary,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Reported')),
                                  );
                                },
                              ),
                          ],
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

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 16, color: color),
    );
  }
}
