import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../shared/widgets.dart';
import '../../../../features/home/domain/entities/bleep.dart';

class NotificationCard extends StatelessWidget {
  final NotificationType notificationType;
  final String actorUsername;
  final String? actorDisplayName;
  final String? actorAvatarUrl;
  final String timeAgo;
  final String? message;
  final Bleep? bleepPreview;
  final bool isUnread;

  const NotificationCard({
    super.key,
    required this.notificationType,
    required this.actorUsername,
    this.actorDisplayName,
    this.actorAvatarUrl,
    required this.timeAgo,
    this.message,
    this.bleepPreview,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isUnread ? context.accent.withValues(alpha: 0.06) : null,
      padding: EdgeInsets.symmetric(
        vertical: context.spacingMd,
        horizontal: context.screenPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(context),
              SizedBox(width: context.spacingSm),
              actorAvatarUrl != null
                  ? CircleAvatar(
                      radius: 16,
                      backgroundColor: context.accent.withValues(alpha: 0.12),
                      backgroundImage: NetworkImage(actorAvatarUrl!),
                    )
                  : const DefaultAvatar(size: 32),
              SizedBox(width: context.spacingSm),
              Expanded(
                child: _buildNotificationText(context),
              ),
              Text(
                timeAgo,
                style: context.caption,
              ),
            ],
          ),
          if (bleepPreview != null) ...[
            SizedBox(height: context.spacingSm),
            Padding(
              padding: const EdgeInsets.only(left: 52),
              child: _buildBleepPreview(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final icon = switch (notificationType) {
      NotificationType.appreciate => HugeIconsStrokeRounded.strokeRoundedHeartAdd,
      NotificationType.discuss => HugeIconsStrokeRounded.strokeRoundedBubbleChat,
      NotificationType.reshare => HugeIconsStrokeRounded.strokeRoundedRepeat,
      NotificationType.follow => HugeIconsStrokeRounded.strokeRoundedUserAdd01,
      NotificationType.mention => HugeIconsStrokeRounded.strokeRoundedAt,
    };

    return HugeIcon(
      icon: icon,
      size: 20,
      color: context.accent,
    );
  }

  Widget _buildNotificationText(BuildContext context) {
    final displayName = actorDisplayName ?? actorUsername;

    return RichText(
      text: TextSpan(
        style: context.body.copyWith(color: context.textPrimary),
        children: [
          TextSpan(text: '$displayName ', style: context.body.copyWith(color: context.accent)),
          TextSpan(text: message ?? ''),
        ],
      ),
    );
  }

  Widget _buildBleepPreview(BuildContext context) {
    final preview = bleepPreview!;
    return Container(
      padding: EdgeInsets.all(context.spacingSm),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(context.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (preview.content.isNotEmpty)
            Text(
              preview.content,
              style: context.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (preview.mediaUrl != null) ...[
            SizedBox(height: context.spacingXs),
            ClipRRect(
              borderRadius: BorderRadius.circular(context.radiusXs),
              child: Image.network(
                preview.mediaUrl!,
                width: double.infinity,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 80,
                  color: context.divider,
                  child: Icon(Icons.broken_image, color: context.textSecondary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum NotificationType {
  appreciate,
  discuss,
  reshare,
  follow,
  mention,
}
