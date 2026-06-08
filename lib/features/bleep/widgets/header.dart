import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../../core/theme/app_theme_data.dart';
import '../../../features/home/domain/entities/bleep.dart';
import '../../../shared/widgets.dart';

class BleepCardHeader extends StatelessWidget {
  const BleepCardHeader({
    super.key,
    required this.bleep,
    required this.onOpenProfile,
    this.onMore,
  });

  final Bleep bleep;
  final VoidCallback onOpenProfile;
  final VoidCallback? onMore;

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  void _showMoreSheet(BuildContext context) {
    if (onMore != null) onMore!();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('View profile'),
              onTap: () {
                Navigator.pop(ctx);
                onOpenProfile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined),
              title: const Text('Block'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Report'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onOpenProfile,
          child: bleep.avatarUrl != null
              ? CircleAvatar(
                  radius: 20,
                  backgroundColor: context.accent.withValues(alpha: 0.12),
                  backgroundImage: NetworkImage(bleep.avatarUrl!),
                )
              : const DefaultAvatar(size: 40),
        ),
        SizedBox(width: context.spacingSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onOpenProfile,
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: context.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(text: '${bleep.displayName ?? bleep.username} '),
                      TextSpan(
                        text: '@${bleep.username}',
                        style: context.bodyMedium.copyWith(
                          fontWeight: FontWeight.w400,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2),
              Text(
                '${bleep.visibility} • ${bleep.replyPermission}',
                style: context.caption.copyWith(
                  color: context.textSecondary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Text(_timeAgo(bleep.createdAt), style: context.caption),
            SizedBox(width: context.spacingSm),
            GestureDetector(
              onTap: () => _showMoreSheet(context),
              child: HugeIcon(
                icon: HugeIconsStrokeRounded.moreVerticalCircle01,
                size: 18,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
