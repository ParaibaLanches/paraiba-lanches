import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/menu_controller.dart' as mc;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/product.dart';

class MenuView extends ConsumerWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(mc.menuProvider);
    final categoriesAsync = ref.watch(mc.categoriesProvider);
    final selectedCategory = ref.watch(mc.selectedCategoryProvider);
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('PARAIBA LANCHES', style: AppTypography.headlineSmall.copyWith(color: AppColors.primary)),
        actions: [
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.shopping_cart_outlined), onPressed: () => context.go('/cart')),
              if (cartNotifier.itemCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: Text('${cartNotifier.itemCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: menuAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Erro: $err')),
        data: (products) {
          final categories = categoriesAsync.value ?? [];
          final filtered = selectedCategory == null ? products : products.where((p) => p.categoryId == selectedCategory).toList();

          return CustomScrollView(
            slivers: [
              // Categories chips
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: const Text('Todos'),
                          selected: selectedCategory == null,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(color: selectedCategory == null ? Colors.white : AppColors.onSurface),
                          onSelected: (_) => ref.read(mc.selectedCategoryProvider.notifier).select(null),
                        ),
                      ),
                      ...categories.map((cat) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(cat.name[0].toUpperCase() + cat.name.substring(1)),
                              selected: selectedCategory == cat.id,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(color: selectedCategory == cat.id ? Colors.white : AppColors.onSurface),
                              onSelected: (_) => ref.read(mc.selectedCategoryProvider.notifier).select(cat.id),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(top: 16)),
              // Products grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ProductCard(
                      product: filtered[index],
                      onAdd: () => cartNotifier.addProduct(filtered[index]),
                      onTap: () => context.go('/product/${filtered[index].id}'),
                    ),
                    childCount: filtered.length,
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          );
        },
      ),
      // Floating cart bar
      bottomSheet: cart.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), offset: const Offset(0, -8), blurRadius: 24)],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => context.go('/cart'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${ref.read(cartProvider.notifier).itemCount} itens', style: AppTypography.labelLarge.copyWith(color: AppColors.onPrimary)),
                        Text(CurrencyFormatter.format(ref.read(cartProvider.notifier).total), style: AppTypography.titleMedium.copyWith(color: AppColors.onPrimary)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onAdd, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80,
                height: 80,
                child: product.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: AppColors.surfaceContainerLow,
                          highlightColor: AppColors.surfaceContainerLowest,
                          child: Container(color: AppColors.surfaceContainerLow),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.surfaceContainerLow,
                          child: const Icon(Icons.lunch_dining, color: AppColors.onSurfaceVariant),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceContainerLow,
                        child: const Icon(Icons.lunch_dining, color: AppColors.onSurfaceVariant),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: AppTypography.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (product.description.isNotEmpty)
                    Text(product.description, style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(CurrencyFormatter.format(product.price), style: AppTypography.headlineSmall.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
            IconButton(
              onPressed: onAdd,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.add, color: AppColors.onPrimary, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
