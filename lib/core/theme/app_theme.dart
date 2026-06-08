import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    textTheme: GoogleFonts.interTextTheme(),
    scaffoldBackgroundColor: AppColors.bg,

    colorScheme: const ColorScheme.light(
      primary: AppColors.accent,
      surface: AppColors.surface,
    ),

    dividerColor: AppColors.divider,

    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    textTheme: GoogleFonts.interTextTheme(),
    scaffoldBackgroundColor: AppColors.darkBg,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkAccent,
      surface: AppColors.darkSurface,
    ),

    dividerColor: AppColors.darkDivider,

    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.darkTextPrimary,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
  );
}
