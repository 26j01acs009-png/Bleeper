import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
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
            Expanded(
              child: _ActionButton(
                icon: bleep.isAppreciatedByMe
                    ? HugeIconsStrokeRounded.strokeRoundedHeartCheck
                    : HugeIconsStrokeRounded.heartAdd,
                count: bleep.appreciatesCount,
                label: 'Appreciations',
                active: bleep.isAppreciatedByMe,
                onTap: onAppreciate,
              ),
            ),
            Expanded(
              child: _ActionButton(
                icon: HugeIconsStrokeRounded.repeat,
                count: bleep.resharesCount,
                label: 'Reshares',
                active: bleep.isResharedByMe,
                onTap: onReshare,
              ),
            ),
            Expanded(
              child: _ActionButton(
                icon: HugeIconsStrokeRounded.eye,
                count: bleep.viewsCount,
                label: 'Views',
                onTap: () {},
              ),
            ),
          ],
        ),
        SizedBox(height: context.spacingSm),
        Divider(height: 1, thickness: 0.3, color: context.divider),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.count,
    required this.label,
    this.active = false,
    required this.onTap,
  });

  final List<List<dynamic>> icon;
  final int count;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(
                icon: icon,
                size: 17,
                color: active ? context.error : context.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: context.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: active ? context.error : null,
                ),
              ),
              const SizedBox(width: 4),
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
      ),
    );
  }
}
