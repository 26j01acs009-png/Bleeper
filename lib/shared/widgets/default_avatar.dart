import 'package:flutter/material.dart';

class DefaultAvatar extends StatelessWidget {
  const DefaultAvatar({
    super.key,
    this.size = 32,
    this.iconSize,
  });

  final double size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFE5E7EB),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: iconSize ?? size * 0.55,
        color: const Color(0xFF6B7280),
      ),
    );
  }
}
