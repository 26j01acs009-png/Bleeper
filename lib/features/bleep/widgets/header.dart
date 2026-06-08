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
    this.currentUserId,
    this.isFollowing = false,
  });

  final Bleep bleep;
  final VoidCallback onOpenProfile;
  final VoidCallback? onMore;
  final String? currentUserId;
  final bool isFollowing;

  bool get isOwnPost => currentUserId != null && bleep.userId == currentUserId;

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
            if (isOwnPost) ...[
              _SheetTile(
                icon: Icons.edit_outlined,
                label: 'Edit',
                onTap: () => Navigator.pop(ctx),
              ),
              _SheetTile(
                icon: Icons.delete_outline,
                label: 'Delete',
                onTap: () => Navigator.pop(ctx),
              ),
            ] else ...[
              _SheetTile(
                icon: isFollowing
                    ? Icons.person_2_outlined
                    : Icons.person_add_outlined,
                label: isFollowing ? 'Unfollow' : 'Follow',
                onTap: () => Navigator.pop(ctx),
              ),
              _SheetTile(
                icon: Icons.volume_off_outlined,
                label: 'Mute',
                onTap: () => Navigator.pop(ctx),
              ),
              _SheetTile(
                icon: Icons.block_outlined,
                label: 'Block',
                onTap: () => Navigator.pop(ctx),
              ),
              _SheetTile(
                icon: Icons.flag_outlined,
                label: 'Report',
                onTap: () => Navigator.pop(ctx),
              ),
            ],
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

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: context.textPrimary),
            const SizedBox(width: 12),
            Text(label, style: context.bodyMedium),
          ],
        ),
      ),
    );
  }
}
