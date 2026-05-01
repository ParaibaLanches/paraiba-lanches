import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/app_info.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // Headline font defaults to Epilogue
  static TextStyle displayLarge = _getHeadlineStyle(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
  );
  static TextStyle displayMedium = _getHeadlineStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
  );
  static TextStyle headlineLarge = _getHeadlineStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
  );
  static TextStyle headlineMedium = _getHeadlineStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );
  static TextStyle headlineSmall = _getHeadlineStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  // Body font defaults to Plus Jakarta Sans
  static TextStyle titleLarge = _getBodyStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  static TextStyle titleMedium = _getBodyStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static TextStyle bodyLarge = _getBodyStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  static TextStyle bodyMedium = _getBodyStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
  static TextStyle bodySmall = _getBodyStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );
  static TextStyle labelLarge = _getBodyStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
  static TextStyle labelMedium = _getBodyStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );
  static TextStyle labelSmall = _getBodyStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurfaceVariant,
    letterSpacing: 1.0,
  );

  // Shadows for readability on complex backgrounds
  static List<Shadow> get textShadows => [
    Shadow(
      offset: const Offset(0, 1),
      blurRadius: 4.0,
      color: Colors.black.withValues(alpha: 0.3),
    ),
    Shadow(
      offset: const Offset(0, 2),
      blurRadius: 8.0,
      color: Colors.black.withValues(alpha: 0.1),
    ),
  ];

  static void init(AppInfo info) {
    if (info.headlineFont != null && info.headlineFont!.isNotEmpty) {
      displayLarge = _getHeadlineStyle(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
        fontFamily: info.headlineFont,
      );
      displayMedium = _getHeadlineStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        fontFamily: info.headlineFont,
      );
      headlineLarge = _getHeadlineStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        fontFamily: info.headlineFont,
      );
      headlineMedium = _getHeadlineStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        fontFamily: info.headlineFont,
      );
      headlineSmall = _getHeadlineStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFamily: info.headlineFont,
      );
    }

    if (info.bodyFont != null && info.bodyFont!.isNotEmpty) {
      titleLarge = _getBodyStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: info.bodyFont,
      );
      titleMedium = _getBodyStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: info.bodyFont,
      );
      bodyLarge = _getBodyStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontFamily: info.bodyFont,
      );
      bodyMedium = _getBodyStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: info.bodyFont,
      );
      bodySmall = _getBodyStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
        fontFamily: info.bodyFont,
      );
      labelLarge = _getBodyStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        fontFamily: info.bodyFont,
      );
      labelMedium = _getBodyStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        fontFamily: info.bodyFont,
      );
      labelSmall = _getBodyStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 1.0,
        fontFamily: info.bodyFont,
      );
    }
  }

  static TextStyle _getHeadlineStyle({
    required double fontSize,
    required FontWeight fontWeight,
    double? letterSpacing,
    String? fontFamily,
  }) {
    try {
      return GoogleFonts.getFont(
        fontFamily ?? 'Epilogue',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: AppColors.onSurface,
        letterSpacing: letterSpacing,
      );
    } catch (e) {
      return GoogleFonts.epilogue(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: AppColors.onSurface,
        letterSpacing: letterSpacing,
      );
    }
  }

  static TextStyle _getBodyStyle({
    required double fontSize,
    required FontWeight fontWeight,
    double? letterSpacing,
    Color? color,
    String? fontFamily,
  }) {
    try {
      return GoogleFonts.getFont(
        fontFamily ?? 'Plus Jakarta Sans',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? AppColors.onSurface,
        letterSpacing: letterSpacing,
      );
    } catch (e) {
      return GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? AppColors.onSurface,
        letterSpacing: letterSpacing,
      );
    }
  }
}
