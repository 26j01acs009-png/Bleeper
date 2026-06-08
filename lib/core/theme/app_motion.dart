import 'package:flutter/material.dart';

class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);

  static const ease = Curves.easeOut;
  static const spring = Curves.easeOutCubic;
}
