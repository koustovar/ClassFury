import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static const String fontFamily = 'Poppins';

  // ── Light Mode Styles ────────────────────────────────────────────────────

  static TextStyle get h1 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get h3 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get title => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelLarge => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // ── Dark Mode Styles ─────────────────────────────────────────────────────
  // Use these when you need explicit dark-mode overrides outside ThemeData.

  static TextStyle get h1Dark => h1.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get h2Dark => h2.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get h3Dark => h3.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get titleDark => title.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get bodyLargeDark => bodyLarge.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get bodyMediumDark => bodyMedium.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get bodySmallDark => bodySmall.copyWith(color: AppColors.textSecondaryDark);
  static TextStyle get labelLargeDark => labelLarge.copyWith(color: AppColors.textPrimaryDark);

  // ── Accent / Brand Dark styles ────────────────────────────────────────────
  /// Red-tinted heading — great for section titles in dark mode.
  static TextStyle get h2DarkAccent =>
      h2Dark.copyWith(color: AppColors.primaryDarkTheme);

  /// Orange-tinted label — good for tags, badges, CTAs in dark mode.
  static TextStyle get labelOrange =>
      labelLarge.copyWith(color: AppColors.secondaryDarkTheme);
}