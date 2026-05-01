import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? double.infinity;

    return SizedBox(
      width: effectiveWidth,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          gradient: (onPressed == null || isLoading || isSecondary)
              ? null
              : AppColors.primaryGradient,
          color: isSecondary
              ? Colors.transparent
              : (onPressed == null || isLoading
                    ? AppColors.outlineVariant.withValues(alpha: 0.3)
                    : null),
          borderRadius: BorderRadius.circular(16),
          border: isSecondary
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: isSecondary
                ? AppColors.primary
                : AppColors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isSecondary ? AppColors.primary : Colors.white,
                  ),
                )
              : Text(
                  label.toUpperCase(),
                  style: AppTypography.labelLarge.copyWith(
                    color: isSecondary
                        ? AppColors.primary
                        : AppColors.onPrimary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
        ),
      ),
    );
  }
}
