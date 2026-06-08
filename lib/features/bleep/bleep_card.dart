import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../features/home/domain/entities/bleep.dart';
import 'widgets/header.dart';
import 'widgets/content.dart';
import 'widgets/actions.dart';

class BleepCard extends StatelessWidget {
  const BleepCard({
    super.key,
    required this.bleep,
    required this.onAppreciate,
    required this.onDiscuss,
    required this.onReshare,
    required this.onOpenProfile,
    this.onMore,
    this.onTap,
    this.showBottomBorder = true,
    this.borderWidth = 0.5,
    this.borderColor,
    this.currentUserId,
  });

  final Bleep bleep;
  final VoidCallback onAppreciate;
  final VoidCallback onDiscuss;
  final VoidCallback onReshare;
  final VoidCallback onOpenProfile;
  final VoidCallback? onMore;
  final VoidCallback? onTap;
  final bool showBottomBorder;
  final double borderWidth;
  final Color? borderColor;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
        decoration: BoxDecoration(
          color: context.bg,
          borderRadius: BorderRadius.circular(context.radiusSm),
          border: showBottomBorder
              ? Border(
                  bottom: BorderSide(
                    color: borderColor ?? context.divider,
                    width: borderWidth,
                  ),
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BleepCardHeader(
              bleep: bleep,
              onOpenProfile: onOpenProfile,
              onMore: onMore,
              currentUserId: currentUserId,
            ),
            SizedBox(height: context.spacingSm),
            BleepCardContent(bleep: bleep),
            SizedBox(height: context.spacingXs),
            BleepCardActions(
              bleep: bleep,
              onAppreciate: onAppreciate,
              onDiscuss: onDiscuss,
              onReshare: onReshare,
            ),
          ],
        ),
      ),
    );
  }
}
