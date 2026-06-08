import 'package:flutter/material.dart';

class AppShadows {
  static const soft = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static const card = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];
}
