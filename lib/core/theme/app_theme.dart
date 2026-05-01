import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/app_info.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData createTheme(AppInfo? info) {
    final hFont = info?.headlineFont ?? 'Epilogue';
    final bFont = info?.bodyFont ?? 'Plus Jakarta Sans';

    // Helper to get Google Font safely
    TextStyle getH(
      double size,
      FontWeight weight, {
      double? spacing,
      Color? color,
    }) {
      try {
        return GoogleFonts.getFont(
          hFont,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: spacing,
          color: color,
        );
      } catch (e) {
        return GoogleFonts.epilogue(
          fontSize: size,
          fontWeight: weight,
          letterSpacing: spacing,
          color: color,
        );
      }
    }

    TextStyle getB(
      double size,
      FontWeight weight, {
      double? spacing,
      Color? color,
    }) {
      try {
        return GoogleFonts.getFont(
          bFont,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: spacing,
          color: color,
        );
      } catch (e) {
        return GoogleFonts.plusJakartaSans(
          fontSize: size,
          fontWeight: weight,
          letterSpacing: spacing,
          color: color,
        );
      }
    }

    TextTheme getTextTheme() {
      try {
        return GoogleFonts.getTextTheme(bFont);
      } catch (e) {
        return GoogleFonts.plusJakartaSansTextTheme();
      }
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryContainer,
        tertiary: AppColors.tertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        surface: AppColors.surface,
        error: AppColors.error,
        errorContainer: AppColors.errorContainer,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
        onSurface: AppColors.onSurface,
        onError: Colors.white,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        inverseSurface: AppColors.inverseSurface,
        inversePrimary: AppColors.inversePrimary,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
      ),
      textTheme: getTextTheme().copyWith(
        displayLarge: getH(36, FontWeight.w900),
        displayMedium: getH(30, FontWeight.w800),
        headlineLarge: getH(24, FontWeight.w800),
        headlineMedium: getH(20, FontWeight.w700),
        headlineSmall: getH(18, FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: getH(20, FontWeight.w800, color: AppColors.onSurface),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: getB(16, FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: getB(
          12,
          FontWeight.w800,
          spacing: 1.5,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        selectedColor: AppColors.primary,
        labelStyle: getB(13, FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.surfaceContainer,
        space: 24,
        thickness: 1,
      ),
    );
  }
}
