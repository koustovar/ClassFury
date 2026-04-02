import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme  => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    // ── Convenience aliases ───────────────────────────────────────────────
    final bg       = isDark ? AppColors.backgroundDark : AppColors.background;
    final surface  = isDark ? AppColors.surfaceDark    : AppColors.surface;
    final cardBg   = isDark ? AppColors.cardDark       : AppColors.card;
    final primary  = isDark ? AppColors.primaryDarkTheme   : AppColors.primary;
    final secondary= isDark ? AppColors.secondaryDarkTheme : AppColors.secondary;
    final divider  = isDark ? AppColors.dividerDark    : AppColors.divider;
    final border   = isDark ? AppColors.borderDark     : AppColors.border;
    final txtPri   = isDark ? AppColors.textPrimaryDark   : AppColors.textPrimary;
    final txtSec   = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final txtHint  = isDark ? AppColors.textHintDark      : AppColors.textPlaceholder;

    return ThemeData(
      useMaterial3: true,

      // ── Color Scheme ────────────────────────────────────────────────────
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: isDark ? const Color(0xFF4C0519) : AppColors.primaryLight,
        onPrimaryContainer: isDark ? AppColors.secondaryDarkTheme : Colors.white,
        secondary: secondary,
        onSecondary: isDark ? AppColors.backgroundDark : Colors.white,
        secondaryContainer: isDark ? const Color(0xFF431407) : AppColors.secondaryLight,
        onSecondaryContainer: isDark ? AppColors.secondaryDarkTheme : Colors.white,
        surface: surface,
        onSurface: txtPri,
        onSurfaceVariant: txtSec,
        error: AppColors.error,
        onError: Colors.white,
        outline: border,
        outlineVariant: divider,
        shadow: Colors.black,
        scrim: Colors.black54,
        inverseSurface: isDark ? AppColors.surface : AppColors.backgroundDark,
        onInverseSurface: isDark ? AppColors.textPrimary : Colors.white,
        inversePrimary: isDark ? AppColors.primaryDarkTheme : AppColors.primaryLight,
      ),

      scaffoldBackgroundColor: bg,
      fontFamily: AppTypography.fontFamily,

      // ── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(
          color: isDark ? AppColors.secondaryDarkTheme : Colors.white,
        ),
        titleTextStyle: AppTypography.h3.copyWith(color: Colors.white),
      ),

      // ── Bottom Navigation ────────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        selectedItemColor: primary,
        unselectedItemColor: txtSec,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        indicatorColor: isDark
            ? AppColors.primaryDarkTheme.withOpacity(0.2)
            : AppColors.primaryLight.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary);
          }
          return IconThemeData(color: txtSec);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.bodySmall.copyWith(
              color: primary,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.bodySmall.copyWith(color: txtSec);
        }),
      ),

      // ── Cards ────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: divider),
        ),
      ),

      // ── Buttons ──────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: isDark
              ? AppColors.primaryDarkTheme.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTypography.labelLarge.copyWith(color: Colors.white),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: primary, width: 1.5),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // ── FAB ──────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ── Input Fields ─────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: txtHint),
        labelStyle: AppTypography.bodyMedium.copyWith(color: txtSec),
        floatingLabelStyle: AppTypography.bodyMedium.copyWith(color: primary),
        prefixIconColor: txtSec,
        suffixIconColor: txtSec,
      ),

      // ── Divider ──────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),

      // ── Chips ────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.background,
        selectedColor: isDark
            ? AppColors.primaryDarkTheme.withOpacity(0.25)
            : AppColors.primaryLight.withOpacity(0.15),
        labelStyle: AppTypography.bodySmall.copyWith(color: txtPri),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // ── Switch / Checkbox / Radio ─────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return isDark ? AppColors.textSecondaryDark : AppColors.textPlaceholder;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return isDark ? AppColors.borderDark : AppColors.border;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return border;
        }),
      ),

      // ── ListTile ──────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: isDark
            ? AppColors.primaryDarkTheme.withOpacity(0.12)
            : AppColors.primaryLight.withOpacity(0.08),
        iconColor: isDark ? AppColors.secondaryDarkTheme : AppColors.primary,
        textColor: txtPri,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // ── Progress Indicator ────────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: isDark ? AppColors.borderDark : AppColors.border,
        circularTrackColor: isDark ? AppColors.borderDark : AppColors.border,
      ),

      // ── Snack Bar ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.textPrimary,
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: Colors.white),
        actionTextColor: isDark ? AppColors.secondaryDarkTheme : AppColors.accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.cardDark : AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: AppTypography.title.copyWith(color: txtPri),
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: txtSec),
      ),

      // ── Bottom Sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: isDark ? AppColors.borderDark : AppColors.border,
        elevation: 0,
      ),

      // ── Typography (TextTheme) ────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge:  AppTypography.h1.copyWith(color: txtPri),
        displayMedium: AppTypography.h2.copyWith(color: txtPri),
        displaySmall:  AppTypography.h3.copyWith(color: txtPri),
        headlineLarge: AppTypography.h1.copyWith(color: txtPri),
        headlineMedium:AppTypography.h2.copyWith(color: txtPri),
        headlineSmall: AppTypography.h3.copyWith(color: txtPri),
        titleLarge:    AppTypography.title.copyWith(color: txtPri),
        titleMedium:   AppTypography.title.copyWith(
                         fontSize: 16, color: txtPri),
        titleSmall:    AppTypography.labelLarge.copyWith(color: txtPri),
        bodyLarge:     AppTypography.bodyLarge.copyWith(color: txtPri),
        bodyMedium:    AppTypography.bodyMedium.copyWith(color: txtPri),
        bodySmall:     AppTypography.bodySmall.copyWith(color: txtSec),
        labelLarge:    AppTypography.labelLarge.copyWith(color: txtPri),
        labelMedium:   AppTypography.bodySmall.copyWith(
                         fontWeight: FontWeight.w500, color: txtSec),
        labelSmall:    AppTypography.bodySmall.copyWith(
                         fontSize: 10, color: txtHint),
      ),
    );
  }
}