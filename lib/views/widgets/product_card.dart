import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/product.dart';
import '../../models/merchandising_section.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final MerchandisingLayoutType layoutType;
  final Function(GlobalKey)? onAddTap;
  final VoidCallback? onTap;
  final Color? textColor;
  final String? heroTag;
  final GlobalKey addButtonKey = GlobalKey();

  ProductCard({
    super.key,
    required this.product,
    this.layoutType = MerchandisingLayoutType.horizontalList,
    this.onAddTap,
    this.onTap,
    this.textColor,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final isGrid = layoutType == MerchandisingLayoutType.grid;

    return GestureDetector(
      onTap: () => context.push('/product', extra: {
        'product': product,
        'heroTag': heroTag ?? 'product_image_${product.id}',
      }),
      child: Container(
        margin: EdgeInsets.only(bottom: isGrid ? 0 : 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.1),
          ),
        ),
        child: isGrid ? _buildVerticalLayout() : _buildHorizontalLayout(),
      ),
    );
  }

  Widget _buildHorizontalLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildImage(80, 80),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTitle(centered: false),
              _buildDescription(centered: false),
              const SizedBox(height: 4),
              _buildPrice(),
            ],
          ),
        ),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildVerticalLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildImage(double.infinity, double.infinity)),
        const SizedBox(height: 12),
        _buildTitle(centered: false),
        const SizedBox(height: 4),
        _buildDescription(centered: false),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPrice(),
            _buildAddButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildImage(double width, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: width,
        height: height,
        child: Hero(
          tag: heroTag ?? 'product_image_${product.id}',
          child: product.imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: ApiConstants.getImageUrl(product.imageUrl)!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: AppColors.surfaceContainer),
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
    );
  }

  Widget _buildTitle({bool centered = false}) {
    final color = textColor ?? AppColors.onSurface;
    final isWhite = color == Colors.white;

    return Text(
      product.name,
      style: AppTypography.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: color,
        shadows: isWhite ? AppTypography.textShadows : null,
      ),
      textAlign: centered ? TextAlign.center : TextAlign.start,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription({bool centered = false}) {
    return Text(
      product.description,
      style: AppTypography.bodySmall,
      textAlign: centered ? TextAlign.center : TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPrice() {
    if (product.promotionalPrice != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
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
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.secondary,
            ),
          ),
        ],
      );
    }
    return Text(
      CurrencyFormatter.format(product.price),
      style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
    );
  }

  Widget _buildAddButton() {
    return IconButton(
      key: addButtonKey,
      onPressed: () => onAddTap?.call(addButtonKey),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add, size: 18),
      ),
    );
  }
}
