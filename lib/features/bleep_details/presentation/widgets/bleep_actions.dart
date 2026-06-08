import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_data.dart';
import '../../../../features/home/domain/entities/bleep.dart';

class BleepActions extends StatelessWidget {
  const BleepActions({
    super.key,
    required this.bleep,
    required this.onAppreciate,
    required this.onReshare,
  });

  final Bleep bleep;
  final VoidCallback onAppreciate;
  final VoidCallback onReshare;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              icon: bleep.isAppreciatedByMe
                  ? Icons.favorite
                  : Icons.favorite_border,
              count: bleep.appreciatesCount,
              label: 'Appreciations',
              active: bleep.isAppreciatedByMe,
              onTap: onAppreciate,
            ),
            _StatItem(
              icon: Icons.repeat,
              count: bleep.resharesCount,
              label: 'Reshares',
              active: bleep.isResharedByMe,
              onTap: onReshare,
            ),
            _StatItem(
              icon: Icons.visibility_outlined,
              count: bleep.viewsCount,
              label: 'Views',
              onTap: () {},
            ),
          ],
        ),
        SizedBox(height: context.spacingSm),
        Divider(height: 1, thickness: 0.3, color: context.divider),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.count,
    required this.label,
    this.active = false,
    required this.onTap,
  });

  final IconData icon;
  final int count;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                key: ValueKey(active),
                icon,
                size: 18,
                color: active ? context.error : context.textSecondary,
              ),
            ),
            SizedBox(width: context.spacingXs),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Text(
                '$count',
                key: ValueKey(count),
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
            ),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: context.caption.copyWith(color: context.textTertiary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
