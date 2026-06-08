import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';
import 'app_radii.dart';

extension AppThemeExtension on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get bg => isDark ? AppColors.darkBg : AppColors.bg;
  Color get surface => isDark ? AppColors.darkSurface : AppColors.surface;
  Color get surfaceAlt => isDark ? AppColors.darkSurfaceAlt : AppColors.surfaceAlt;

  Color get textPrimary => isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
  Color get textSecondary => isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get textTertiary => isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;

  Color get divider => isDark ? AppColors.darkDivider : AppColors.divider;
  Color get accent => isDark ? AppColors.darkAccent : AppColors.accent;
  Color get error => AppColors.error;
  Color get success => AppColors.success;
}

extension AppSpacingExtension on BuildContext {
  double get spacingXs => AppSpacing.xs;
  double get spacingSm => AppSpacing.sm;
  double get spacingMd => AppSpacing.md;
  double get spacingLg => AppSpacing.lg;
  double get spacingXl => AppSpacing.xl;
  double get spacingXxl => AppSpacing.xxl;
  double get screenPadding => AppSpacing.screenPadding;
  double get cardPadding => AppSpacing.cardPadding;
  double get sectionGap => AppSpacing.sectionGap;
  double get elementGap => AppSpacing.elementGap;
}

extension AppTypographyExtension on BuildContext {
  TextStyle get h1 => AppTypography.h1(textPrimary);
  TextStyle get h2 => AppTypography.h2(textPrimary);
  TextStyle get h3 => AppTypography.h3(textPrimary);
  TextStyle get body => AppTypography.body(textPrimary);
  TextStyle get bodyMedium => AppTypography.bodyMedium(textPrimary);
  TextStyle get bodySmall => AppTypography.bodySmall(textPrimary);
  TextStyle get caption => AppTypography.caption(textSecondary);
  TextStyle get label => AppTypography.label(textSecondary);
}

extension AppRadiiExtension on BuildContext {
  double get radiusXs => AppRadii.xs;
  double get radiusSm => AppRadii.sm;
  double get radiusMd => AppRadii.md;
  double get radiusLg => AppRadii.lg;
  double get radiusXl => AppRadii.xl;
  double get radiusRound => AppRadii.round;
}