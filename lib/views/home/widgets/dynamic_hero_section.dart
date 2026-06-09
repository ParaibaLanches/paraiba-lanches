import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/product.dart';
import '../../../models/merchandising_section.dart';

class DynamicHeroSection extends StatelessWidget {
  final MerchandisingSection section;
  final Function(Product, GlobalKey) onAddTap;
  final GlobalKey addButtonKey = GlobalKey();

  DynamicHeroSection({
    super.key,
    required this.section,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    // No Hero dinâmico, pegamos o primeiro produto da lista vinculada à seção
    final heroProduct = section.products.firstOrNull;
    if (heroProduct == null) return const SizedBox();

    return Container(
      width: double.infinity,
      height: 380,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(36),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -80,
            bottom: -40,
            child: heroProduct.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: ApiConstants.getImageUrl(heroProduct.imageUrl)!,
                    width: 480,
                    fit: BoxFit.contain,
                  )
                : const Icon(Icons.image_outlined, size: 200, color: Colors.white24),
          ),
          // Gradient overlay for text readability
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.0, 0.6, 1.0],
                  colors: [
                    AppColors.surfaceContainerLow.withValues(alpha: 0.95),
                    AppColors.surfaceContainerLow.withValues(alpha: 0.6),
                    AppColors.surfaceContainerLow.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (heroProduct.promotionLabel.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          heroProduct.promotionLabel.toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      section.title.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  heroProduct.name.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.displayLarge.copyWith(
                    height: 0.9,
                    letterSpacing: -1.5,
                    fontSize: heroProduct.name.length > 10 ? 32 : 40,
                    color: section.titleColor == 'white'
                        ? Colors.white
                        : (section.titleColor == 'primary'
                              ? AppColors.primary
                              : AppColors.onSurface),
                    shadows:
                        (section.titleColor == 'white' ||
                            section.titleColor == 'primary')
                        ? AppTypography.textShadows
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 200,
                  child: Text(
                    heroProduct.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      heroProduct.promotionalPrice != null
                          ? CurrencyFormatter.format(
                              heroProduct.promotionalPrice!,
                            )
                          : CurrencyFormatter.format(heroProduct.price),
                      style: AppTypography.headlineLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      key: addButtonKey,
                      onPressed: () => onAddTap(heroProduct, addButtonKey),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Icon(
                        Icons.add_shopping_cart,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
