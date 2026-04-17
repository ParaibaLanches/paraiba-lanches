import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/menu_controller.dart' as mc;
import '../../controllers/providers.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/product.dart';
import '../widgets/app_button.dart';
import '../widgets/product_card.dart';
import '../widgets/section_header.dart';
import 'widgets/section_factory.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(mc.menuProvider);
    final categoriesAsync = ref.watch(mc.categoriesProvider);
    final selectedCategory = ref.watch(mc.selectedCategoryProvider);
    final appInfoAsync = ref.watch(appInfoProvider);
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    void addToCart(Product product) {
      cartNotifier.addProduct(product);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} adicionado ao carrinho!'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'VER CARRINHO',
            onPressed: () => context.go('/cart'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Custom Header
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 100,
            toolbarHeight: 64,
            backgroundColor: AppColors.background.withValues(alpha: 0.9),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 64, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      appInfoAsync.when(
                        data: (info) => Text(
                          info.description,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.outline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        loading: () => const SizedBox(),
                        error: (_, _) => Text(
                          'Os Brutos de Cabedelo 🍔',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.outline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                appInfoAsync.when(
                  data: (info) => info.logoUrl != null && info.logoUrl!.isNotEmpty
                      ? SizedBox(
                          height: 32,
                          width: 32,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: ApiConstants.getImageUrl(info.logoUrl)!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : const Icon(Icons.lunch_dining, size: 28, color: AppColors.primary),
                  loading: () => const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2)),
                  error: (_, _) => const Icon(Icons.lunch_dining, size: 28, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                appInfoAsync.when(
                  data: (info) => Text(
                    info.appName,
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  loading: () => const Text('Carregando...'),
                  error: (_, _) => const Text('Paraíba Lanches'),
                ),
              ],
            ),
            actions: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary),
                    onPressed: () => context.go('/cart'),
                  ),
                  if (cart.isNotEmpty)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cartNotifier.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.search, color: AppColors.primary),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Merchandising Sections (Dynamic)
          ref.watch(homeDataProvider).when(
            data: (sections) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    ...sections.map((section) => SectionFactory(
                      section: section,
                      onAddTap: addToCart,
                    )),
                  ],
                ),
              ),
            ),
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (err, stack) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Não foi possível carregar os destaques.\n$err',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall,
                      ),
                      TextButton(
                        onPressed: () => ref.refresh(homeDataProvider),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Search, Categories and General List (Fixed atbottom)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _CategoriesBar(
                    categoriesAsync: categoriesAsync,
                    selectedId: selectedCategory,
                    onSelect: (id) => ref.read(mc.selectedCategoryProvider.notifier).select(id),
                  ),
                  const SizedBox(height: 32),
                  const SectionHeader(title: 'Nosso Cardápio Completo', subtitle: 'Tudo o que você precisa'),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Menu Items List
          menuAsync.when(
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            data: (products) {
              final filtered = selectedCategory == null 
                  ? products 
                  : products.where((p) => p.categoryId == selectedCategory).toList();
              
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ProductCard(
                      product: filtered[index],
                      onAddTap: () => addToCart(filtered[index]),
                    ),
                    childCount: filtered.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomSheet: cart.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    offset: const Offset(0, -8),
                    blurRadius: 24,
                  )
                ],
              ),
              child: SafeArea(
                child: AppButton(
                  onPressed: () => context.go('/cart'),
                  label: '${cartNotifier.itemCount} itens  •  ${CurrencyFormatter.format(cartNotifier.total)}',
                ),
              ),
            ),
    );
  }
}

// Widgets _HeroSection e _BentoGrid foram removidos pois foram migrados para o sistema dinâmico

class _CategoriesBar extends StatelessWidget {
  final AsyncValue categoriesAsync;
  final int? selectedId;
  final Function(int?) onSelect;

  const _CategoriesBar({required this.categoriesAsync, required this.selectedId, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return categoriesAsync.when(
      loading: () => const SizedBox(height: 40),
      error: (_, _) => const SizedBox(),
      data: (categories) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _CategoryChip(
              label: 'Todos',
              isSelected: selectedId == null,
              onTap: () => onSelect(null),
            ),
            ...categories.map((cat) => _CategoryChip(
                  label: cat.name[0].toUpperCase() + cat.name.substring(1),
                  isSelected: selectedId == cat.id,
                  onTap: () => onSelect(cat.id),
                )),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected 
                ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))] 
                : null,
          ),
          child: Text(
            label,
            style: AppTypography.labelLarge.copyWith(
              color: isSelected ? Colors.white : AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
