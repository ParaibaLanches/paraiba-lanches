import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const primary = Color(0xFF9E3D00);
  static const primaryContainer = Color(0xFFFF7A35);
  static const primaryDim = Color(0xFF8A3400);
  static const onPrimary = Color(0xFFFFF0EA);
  static const onPrimaryContainer = Color(0xFF2E0F00);

  // Secondary
  static const secondary = Color(0xFF735700);
  static const secondaryContainer = Color(0xFFFFCA3F);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onSecondaryContainer = Color(0xFF241A00);

  // Tertiary
  static const tertiary = Color(0xFF825000);
  static const tertiaryContainer = Color(0xFFF8A018);

  // Surface & Background
  static const background = Color(0xFFF9F6F5);
  static const surface = Color(0xFFF9F6F5);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF3F0F0);
  static const surfaceContainer = Color(0xFFEAE8E7);
  static const surfaceContainerHigh = Color(0xFFE4E2E1);
  static const surfaceContainerHighest = Color(0xFFDEDCDC);
  static const surfaceDim = Color(0xFFD6D4D4);

  // Text
  static const onSurface = Color(0xFF2F2F2F);
  static const onSurfaceVariant = Color(0xFF5C5B5B);
  static const onBackground = Color(0xFF2F2F2F);

  // Error
  static const error = Color(0xFFB31B25);
  static const errorContainer = Color(0xFFFB5151);

  // Outline
  static const outline = Color(0xFF777676);
  static const outlineVariant = Color(0xFFAEADAC);

  // Inverse
  static const inverseSurface = Color(0xFF0E0E0E);
  static const inversePrimary = Color(0xFFFC7127);

  // Gradient
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
  );

  // Order Status
  static const statusPending = Color(0xFFF59E0B); // amber
  static const statusPreparing = Color(0xFF3B82F6); // blue
  static const statusReady = Color(0xFF22C55E); // green
  static const statusDelivered = Color(0xFF6B7280); // gray
  static const statusCancelled = Color(0xFFEF4444); // red
}
