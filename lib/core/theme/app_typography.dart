import 'package:flutter/material.dart';

class AppTypography {
  static const font = 'Inter';

  // DISPLAY
  static TextStyle display(Color c) => TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: c,
      );

  // HEADINGS
  static TextStyle h1(Color c) => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: c,
      );

  static TextStyle h2(Color c) => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: c,
      );

  static TextStyle h3(Color c) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: c,
      );

  // BODY
  static TextStyle body(Color c) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: c,
      );

  static TextStyle bodyMedium(Color c) => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: c,
      );

  static TextStyle bodySmall(Color c) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: c,
      );

  // CAPTION / META
  static TextStyle caption(Color c) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: c,
      );

  static TextStyle label(Color c) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: c,
      );
}
