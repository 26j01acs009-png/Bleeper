import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import '../../../../core/theme/app_theme_data.dart';
import '../../../../features/home/domain/entities/bleep.dart';

class BleepCardActions extends StatelessWidget {
  const BleepCardActions({
    super.key,
    required this.bleep,
    required this.onAppreciate,
    required this.onDiscuss,
    required this.onReshare,
  });

  final Bleep bleep;
  final VoidCallback onAppreciate;
  final VoidCallback onDiscuss;
  final VoidCallback onReshare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: HugeIconsStrokeRounded.bubbleChat,
            count: bleep.discussesCount,
            label: 'Discuss',
            onTap: onDiscuss,
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
            icon: HugeIconsStrokeRounded.eye,
            count: bleep.viewsCount,
            label: 'Views',
            onTap: () {},
          ),
        ),
        Expanded(
          child: IconButton(
            onPressed: () {},
            icon: HugeIcon(icon: HugeIconsStrokeRounded.share01, size: 18),
            color: context.textSecondary,
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
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
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(_ActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active && widget.active) {
      _controller.forward(from: 0).then((_) {
        if (mounted) _controller.reverse();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0).then((_) {
      if (mounted) _controller.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = ScaleTransition(
      scale: _animation,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: HugeIcon(
          key: ValueKey(widget.active),
          icon: widget.icon,
          size: 17,
          color: widget.active ? context.error : context.textSecondary,
        ),
      ),
    );

    return GestureDetector(
      onTap: _handleTap,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              iconWidget,
              if (widget.label.isNotEmpty) ...[
                const SizedBox(width: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    '${widget.count}',
                    key: ValueKey(widget.count),
                    style: context.caption.copyWith(
                      color: widget.active ? context.error : null,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
