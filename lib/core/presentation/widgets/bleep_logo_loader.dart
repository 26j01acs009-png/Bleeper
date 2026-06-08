import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BleepLogoLoader extends StatefulWidget {
  const BleepLogoLoader({super.key, this.size = 80});

  final double size;

  @override
  State<BleepLogoLoader> createState() => _BleepLogoLoaderState();
}

class _BleepLogoLoaderState extends State<BleepLogoLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  late final Animation<double> _scaleAnimation = Tween<double>(
    begin: 0.9,
    end: 1.1,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  ));

  late final Animation<double> _rotateAnimation = Tween<double>(
    begin: -0.05,
    end: 0.05,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  ));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotateAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: SvgPicture.asset(
        'assets/logo.svg',
        width: widget.size,
        height: widget.size,
      ),
    );
  }
}