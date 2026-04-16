import '../../controllers/menu_controller.dart' as mc;
import '../../controllers/providers.dart';
import '../../core/constants/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(mc.menuProvider);
    final categoriesAsync = ref.watch(mc.categoriesProvider);
    final selectedCategory = ref.watch(mc.selectedCategoryProvider);
    final appInfoAsync = ref.watch(appInfoProvider);

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
              IconButton(
                icon: const Icon(Icons.search, color: AppColors.primary),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          menuAsync.when(
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Erro: $err'))),
            data: (products) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    
                    // Hero Section
                    _HeroSection(products: products),
                    
                    const SizedBox(height: 32),
                    
                    // Categories Bar
                    _CategoriesBar(
                      categoriesAsync: categoriesAsync,
                      selectedId: selectedCategory,
                      onSelect: (id) => ref.read(mc.selectedCategoryProvider.notifier).select(id),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Bento Grid Section
                    _SectionHeader(title: 'Destaques e Gigantes', subtitle: 'Os mais recomendados pela casa'),
                    const SizedBox(height: 16),
                    _BentoGrid(products: products),
                    
                    const SizedBox(height: 32),
                    
                    // Classics Section
                    _SectionHeader(title: 'Clássicos da Casa'),
                    const SizedBox(height: 16),
                  ],
                ),
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
                    (context, index) => _ProductCard(product: filtered[index]),
                    childCount: filtered.length,
                  ),
                ),
              );
            },
          ),
          
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final List<Product> products;

  const _HeroSection({required this.products});

  @override
  Widget build(BuildContext context) {
    // Busca o produto especificamente marcado para o Hero
    final heroProduct = products.where((p) => p.featuredSlot == 'hero').firstOrNull ?? 
                        products.where((p) => p.isFeatured).firstOrNull ?? 
                        products.firstOrNull;

    if (heroProduct == null) return const SizedBox();

    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(40),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -80,
            bottom: -40,
            child: Hero(
              tag: 'hero-burger',
              child: heroProduct.imageUrl.isNotEmpty 
                ? CachedNetworkImage(
                    imageUrl: ApiConstants.getImageUrl(heroProduct.imageUrl)!,
                    width: 500,
                    fit: BoxFit.contain,
                  )
                : const Icon(Icons.fastfood, size: 200, color: Colors.white24),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium, size: 14, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        'Destaque do Dia'.toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  heroProduct.name.toUpperCase(),
                  style: AppTypography.displayLarge.copyWith(
                    height: 0.9,
                    letterSpacing: -2,
                    fontSize: heroProduct.name.length > 10 ? 48 : 56,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 200,
                  child: Text(
                    heroProduct.description,
                    style: AppTypography.bodySmall,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      heroProduct.promotionalPrice != null 
                        ? CurrencyFormatter.format(heroProduct.promotionalPrice!)
                        : CurrencyFormatter.format(heroProduct.price),
                      style: AppTypography.headlineLarge.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Icon(Icons.add_shopping_cart, size: 20),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTypography.headlineLarge),
            Text('Ver todos', style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
          ],
        ),
        if (subtitle != null)
          Text(subtitle!, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _BentoGrid extends StatelessWidget {
  final List<Product> products;

  const _BentoGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    // Filtra produtos pelos slots fixos da grade
    final item1 = products.where((p) => p.featuredSlot == 'bento_1').firstOrNull;
    final item2 = products.where((p) => p.featuredSlot == 'bento_2').firstOrNull;

    if (item1 == null && item2 == null) return const SizedBox();

    return Column(
      children: [
        if (item1 != null) ...[
          // Large Featured Item
          _BentoCard(
            title: item1.name,
            subtitle: 'DESTAQUE',
            description: item1.description,
            price: item1.promotionalPrice != null ? CurrencyFormatter.format(item1.promotionalPrice!) : CurrencyFormatter.format(item1.price),
            imageUrl: ApiConstants.getImageUrl(item1.imageUrl) ?? '',
            color: AppColors.surfaceContainerLow,
          ),
        ],
        if (item2 != null) ...[
          const SizedBox(height: 16),
          // Secondary Featured Item
          _BentoCard(
            title: item2.name,
            subtitle: 'RECOMENDADO',
            description: item2.description,
            price: item2.promotionalPrice != null ? CurrencyFormatter.format(item2.promotionalPrice!) : CurrencyFormatter.format(item2.price),
            imageUrl: ApiConstants.getImageUrl(item2.imageUrl) ?? '',
            color: AppColors.primary,
            onPrimary: true,
          ),
        ]
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

  const _BentoCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.color,
    this.onPrimary = false,
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
                    subtitle,
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 8,
                      color: onPrimary ? Colors.white : AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(title, style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w900, color: textColor)),
                const SizedBox(height: 4),
                SizedBox(
                  width: 140,
                  child: Text(description, style: AppTypography.bodySmall.copyWith(color: secondaryTextColor), maxLines: 2),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(price, style: AppTypography.titleLarge.copyWith(color: textColor)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
                      child: Icon(Icons.add, color: color, size: 16),
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

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  ? CachedNetworkImage(imageUrl: ApiConstants.getImageUrl(product.imageUrl)!, fit: BoxFit.cover)
                  : Container(color: AppColors.surfaceContainer, child: const Icon(Icons.lunch_dining)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                Text(product.description, style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                if (product.promotionalPrice != null) ...[
                  Row(
                    children: [
                      Text(CurrencyFormatter.format(product.price), style: AppTypography.bodySmall.copyWith(decoration: TextDecoration.lineThrough, color: AppColors.outline)),
                      const SizedBox(width: 8),
                      Text(CurrencyFormatter.format(product.promotionalPrice!), style: AppTypography.titleLarge.copyWith(color: AppColors.secondary)),
                    ],
                  ),
                ] else ...[
                  Text(CurrencyFormatter.format(product.price), style: AppTypography.titleLarge.copyWith(color: AppColors.primary)),
                ]
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.add, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
