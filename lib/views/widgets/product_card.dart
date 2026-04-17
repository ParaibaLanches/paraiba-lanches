import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onAddTap;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onAddTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 80,
                height: 80,
                child: product.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: ApiConstants.getImageUrl(product.imageUrl)!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: AppColors.surfaceContainer),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surfaceContainer,
                          child: const Icon(Icons.broken_image, size: 24),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceContainer,
                        child: const Icon(Icons.lunch_dining, size: 24),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    product.description,
                    style: AppTypography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product.promotionalPrice != null) ...[
                    Row(
                      children: [
                        Text(
                          CurrencyFormatter.format(product.price),
                          style: AppTypography.bodySmall.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.outline,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          CurrencyFormatter.format(product.promotionalPrice!),
                          style: AppTypography.titleLarge.copyWith(color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      CurrencyFormatter.format(product.price),
                      style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
                    ),
                  ]
                ],
              ),
            ),
            IconButton(
              onPressed: onAddTap,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
