import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme_data.dart';

class BleeperLoadingIndicator extends StatefulWidget {
  final bool showText;
  final double size;

  const BleeperLoadingIndicator({
    super.key,
    this.showText = false,
    this.size = 120,
  });

  @override
  State<BleeperLoadingIndicator> createState() =>
      _BleeperLoadingIndicatorState();
}

class _BleeperLoadingIndicatorState extends State<BleeperLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat();

  static const _wavePoints = [
    Offset(22, 64),
    Offset(38, 48),
    Offset(48, 64),
    Offset(62, 40),
    Offset(76, 76),
    Offset(94, 76),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _getPositionOnWave(double t) {
    final points = _wavePoints;
    final totalSegments = points.length - 1;
    final scaledT = t * totalSegments;
    final index = scaledT.clamp(0, totalSegments - 1).floor();
    final segmentT = scaledT - index;

    final start = points[index];
    final end = points[index + 1];
    return Offset(
      start.dx + (end.dx - start.dx) * segmentT,
      start.dy + (end.dy - start.dy) * segmentT,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dotRadius = 6.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            children: [
              SvgPicture.asset(
                'assets/logo.svg',
                width: widget.size,
                height: widget.size,
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final pos = _getPositionOnWave(_controller.value);
                  final scale = widget.size / 120;
                  return Positioned(
                    left: pos.dx * scale - dotRadius,
                    top: pos.dy * scale - dotRadius,
                    child: Container(
                      width: dotRadius * 2,
                      height: dotRadius * 2,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        if (widget.showText) ...[
          const SizedBox(height: 24),
          Text(
            'Loading...',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}
