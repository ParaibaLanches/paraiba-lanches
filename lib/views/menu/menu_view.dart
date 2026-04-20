import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/menu_controller.dart' as mc;
import '../../controllers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/cart_animation_helper.dart';
import '../../core/utils/currency_formatter.dart';
import '../widgets/app_button.dart';
import '../widgets/product_card.dart';

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
              IconButton(
                key: ref.watch(cartIconKeyProvider),
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => context.go('/cart'),
              ),
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
                    (context, index) => ProductCard(
                      product: filtered[index],
                      onAddTap: (key) {
                        cartNotifier.addProduct(filtered[index]);
                        final cartKey = ref.read(cartIconKeyProvider);
                        CartAnimationHelper.runFlyToCartAnimation(
                          context: context,
                          sourceKey: key,
                          destKey: cartKey,
                          imageUrl: filtered[index].imageUrl,
                        );
                      },
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
                    child: AppButton(
                      onPressed: () => context.go('/cart'),
                      label: '${ref.read(cartProvider.notifier).itemCount} itens  •  ${CurrencyFormatter.format(ref.read(cartProvider.notifier).total)}',
                    ),
              ),
            ),
    );
  }
}
