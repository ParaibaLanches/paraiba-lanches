import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // Headline font — Epilogue (bold, industrial)
  static TextStyle displayLarge = GoogleFonts.epilogue(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: AppColors.onSurface,
    letterSpacing: -0.5,
  );

  static TextStyle displayMedium = GoogleFonts.epilogue(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
    letterSpacing: -0.3,
  );

  static TextStyle headlineLarge = GoogleFonts.epilogue(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
  );

  static TextStyle headlineMedium = GoogleFonts.epilogue(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static TextStyle headlineSmall = GoogleFonts.epilogue(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  // Body font — Plus Jakarta Sans
  static TextStyle titleLarge = GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle titleMedium = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle bodyLarge = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  static TextStyle bodyMedium = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  static TextStyle bodySmall = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle labelLarge = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    letterSpacing: 0.5,
  );

  static TextStyle labelMedium = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    letterSpacing: 0.8,
  );

  static TextStyle labelSmall = GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurfaceVariant,
    letterSpacing: 1.0,
  );
}
