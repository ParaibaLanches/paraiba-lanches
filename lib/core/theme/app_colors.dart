import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - Pleasant, balanced orange
  static const primary = Color(0xFFF97316); // Tailwind Orange 500
  static const primaryContainer = Color(0xFFFFEDD5); // Tailwind Orange 100
  static const primaryDim = Color(0xFFEA580C); // Tailwind Orange 600
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFF9A3412); // Tailwind Orange 800

  // Secondary - High contrast dark for elegance
  static const secondary = Color(0xFF212121);
  static const secondaryContainer = Color(0xFFF5F5F5);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onSecondaryContainer = Color(0xFF121212);

  // Tertiary
  static const tertiary = Color(0xFFFFC107);
  static const tertiaryContainer = Color(0xFFFFF8E1);

  // Surface & Background - Pure and clean
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF8F9FA);
  static const surfaceContainer = Color(0xFFF1F3F5);
  static const surfaceContainerHigh = Color(0xFFE9ECEF);
  static const surfaceContainerHighest = Color(0xFFDEE2E6);
  static const surfaceDim = Color(0xFFE0E0E0);

  // Text - Crisp slate grays
  static const onSurface = Color(0xFF1E1E1E);
  static const onSurfaceVariant = Color(0xFF6C757D);
  static const onBackground = Color(0xFF1E1E1E);

  // Error
  static const error = Color(0xFFE53935);
  static const errorContainer = Color(0xFFFFEBEE);

  // Outline - Extremely subtle
  static const outline = Color(0xFFCED4DA);
  static const outlineVariant = Color(0xFFE9ECEF);

  // Inverse
  static const inverseSurface = Color(0xFF212529);
  static const inversePrimary = Color(0xFFFFDBCF);

  // Gradient
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6D3B), Color(0xFFFF4800)],
  );

  // Order Status
  static const statusPending = Color(0xFFF59E0B);
  static const statusPreparing = Color(0xFF3B82F6);
  static const statusReady = Color(0xFF10B981);
  static const statusDelivered = Color(0xFF6B7280);
  static const statusCancelled = Color(0xFFEF4444);
}
