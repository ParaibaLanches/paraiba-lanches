import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/cart_controller.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/ingredient.dart';
import '../../models/product.dart';

class ProductDetailView extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailView({super.key, required this.product});

  @override
  ConsumerState<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends ConsumerState<ProductDetailView> {
  int _quantity = 1;

  void _increment() => setState(() => _quantity++);
  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  void _addToCart() {
    ref
        .read(cartProvider.notifier)
        .addItem(widget.product, quantity: _quantity);
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} adicionado ao carrinho!'),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildDescriptionSection(),
                  if (widget.product.ingredients.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildIngredientsSection(),
                  ],
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
        style: IconButton.styleFrom(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product_image_${widget.product.id}',
          child: widget.product.imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: ApiConstants.getImageUrl(widget.product.imageUrl)!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: AppColors.surfaceContainer),
                )
              : Container(
                  color: AppColors.surfaceContainer,
                  child: const Icon(
                    Icons.lunch_dining,
                    size: 80,
                    color: AppColors.outline,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final price = widget.product.promotionalPrice ?? widget.product.price;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.product.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.product.category!.name.toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.name,
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                CurrencyFormatter.format(price),
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        if (widget.product.promotionalPrice != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'De ${CurrencyFormatter.format(widget.product.price)}',
              style: AppTypography.bodyMedium.copyWith(
                decoration: TextDecoration.lineThrough,
                color: AppColors.outline,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descrição',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.product.description.isNotEmpty
              ? widget.product.description
              : 'Nenhuma descrição disponível para este item.',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Ingredientes',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 12,
          children: widget.product.ingredients
              .map((ing) => _buildIngredientChip(ing))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildIngredientChip(Ingredient ing) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIngredientIcon(ing.icon),
            size: 16,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            ing.name,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIngredientIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'bread':
        return Icons.bakery_dining;
      case 'beef':
        return Icons.kebab_dining;
      case 'cheese':
        return Icons.lunch_dining;
      case 'pig':
        return Icons.set_meal; // Or custom icon
      case 'leaf':
        return Icons.eco;
      case 'apple':
        return Icons.radio_button_checked; // Tomato
      case 'droplet':
        return Icons.opacity;
      case 'circle':
        return Icons.trip_origin; // Onion
      default:
        return Icons.check_circle_outline;
    }
  }

  Widget _buildBottomBar() {
    final totalPrice =
        (widget.product.promotionalPrice ?? widget.product.price) * _quantity;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _decrement,
                  icon: const Icon(Icons.remove, size: 20),
                ),
                Text(
                  _quantity.toString().padLeft(2, '0'),
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _increment,
                  icon: const Icon(Icons.add, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _addToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_basket_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Adicionar • ${CurrencyFormatter.format(totalPrice)}',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
