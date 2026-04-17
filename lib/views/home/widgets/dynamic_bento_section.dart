import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/product.dart';
import '../../../models/merchandising_section.dart';
import '../../widgets/section_header.dart';

class DynamicBentoSection extends StatelessWidget {
  final MerchandisingSection section;
  final Function(Product) onAddTap;

  const DynamicBentoSection({
    super.key,
    required this.section,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    if (section.products.isEmpty) return const SizedBox();

    final item1 = section.products.firstOrNull;
    final item2 = section.products.length > 1 ? section.products[1] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: section.title,
          subtitle: section.subtitle.isNotEmpty ? section.subtitle : null,
        ),
        const SizedBox(height: 16),
        if (item1 != null)
          _BentoCard(
            title: item1.name,
            subtitle: item1.promotionLabel.isNotEmpty ? item1.promotionLabel : 'DESTAQUE',
            description: item1.description,
            price: item1.promotionalPrice != null 
                ? CurrencyFormatter.format(item1.promotionalPrice!) 
                : CurrencyFormatter.format(item1.price),
            imageUrl: ApiConstants.getImageUrl(item1.imageUrl) ?? '',
            color: AppColors.surfaceContainerLow,
            onAddTap: () => onAddTap(item1),
          ),
        if (item2 != null) ...[
          const SizedBox(height: 16),
          _BentoCard(
            title: item2.name,
            subtitle: item2.promotionLabel.isNotEmpty ? item2.promotionLabel : 'RECOMENDADO',
            description: item2.description,
            price: item2.promotionalPrice != null 
                ? CurrencyFormatter.format(item2.promotionalPrice!) 
                : CurrencyFormatter.format(item2.price),
            imageUrl: ApiConstants.getImageUrl(item2.imageUrl) ?? '',
            color: AppColors.primary,
            onPrimary: true,
            onAddTap: () => onAddTap(item2),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}

class _BentoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String price;
  final String imageUrl;
  final Color color;
  final bool onPrimary;
  final VoidCallback onAddTap;

  const _BentoCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.color,
    this.onPrimary = false,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = onPrimary ? Colors.white : AppColors.onSurface;
    final secondaryTextColor = onPrimary ? Colors.white70 : AppColors.onSurfaceVariant;

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: imageUrl.isNotEmpty 
              ? CachedNetworkImage(imageUrl: imageUrl, width: 220, fit: BoxFit.contain)
              : const SizedBox(),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: onPrimary ? Colors.white24 : AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    subtitle.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 8,
                      color: onPrimary ? Colors.white : AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title.toUpperCase(), 
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.w900, 
                    color: textColor,
                    letterSpacing: -0.5,
                  )
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 140,
                  child: Text(
                    description, 
                    style: AppTypography.bodySmall.copyWith(color: secondaryTextColor), 
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(price, style: AppTypography.titleLarge.copyWith(color: textColor)),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onAddTap,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
                        child: Icon(Icons.add, color: color, size: 16),
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
