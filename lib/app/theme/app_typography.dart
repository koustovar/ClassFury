import 'package:flutter/material.dart';

class AppTypography {
  static const String fontFamily = 'Poppins';

  // ── Base Styles (Color Neutral) ──────────────────────────────────────────
  // These should NOT have a color property so they can be themed via ThemeData

  static TextStyle get h1 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle get h3 => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get title => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get labelLarge => const TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  // Legacy names for compatibility
  static TextStyle get headline6 => h3;
  static TextStyle get bodyText1 => bodyLarge;
  static TextStyle get bodyText2 => bodyMedium;
}
