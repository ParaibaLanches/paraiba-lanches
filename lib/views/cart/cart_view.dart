import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../controllers/cart_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';

class CartView extends ConsumerWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Seu Carrinho', style: AppTypography.headlineMedium),
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () => cartNotifier.clear(),
              child: Text('Limpar', style: AppTypography.bodySmall.copyWith(color: AppColors.error)),
            ),
        ],
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('Carrinho vazio', style: AppTypography.headlineMedium.copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text('Adicione itens do cardapio', style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 60,
                                height: 60,
                                child: item.product.imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: item.product.imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Shimmer.fromColors(
                                          baseColor: AppColors.surfaceContainerLow,
                                          highlightColor: AppColors.surfaceContainerLowest,
                                          child: Container(color: AppColors.surfaceContainerLow),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          color: AppColors.surfaceContainerLow,
                                          child: const Icon(Icons.lunch_dining, color: AppColors.onSurfaceVariant, size: 28),
                                        ),
                                      )
                                    : Container(
                                        color: AppColors.surfaceContainerLow,
                                        child: const Icon(Icons.lunch_dining, color: AppColors.onSurfaceVariant, size: 28),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.name, style: AppTypography.titleMedium),
                                  Text(CurrencyFormatter.format(item.subtotal), style: AppTypography.bodySmall.copyWith(color: AppColors.primary)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => cartNotifier.updateQuantity(item.product.id, item.quantity - 1),
                                  icon: const Icon(Icons.remove_circle_outline, size: 22),
                                ),
                                Text('${item.quantity}', style: AppTypography.titleMedium),
                                IconButton(
                                  onPressed: () => cartNotifier.updateQuantity(item.product.id, item.quantity + 1),
                                  icon: const Icon(Icons.add_circle_outline, size: 22),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), offset: const Offset(0, -8), blurRadius: 24)],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Coupon Input Field
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Cupom de Desconto',
                                  hintStyle: AppTypography.labelLarge.copyWith(color: AppColors.outline),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  filled: true,
                                  fillColor: AppColors.surfaceContainerHigh,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: AppColors.onSecondary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              ),
                              child: const Text('Aplicar'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.outlineVariant),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total', style: AppTypography.headlineMedium),
                            Text(CurrencyFormatter.format(cartNotifier.total), style: AppTypography.headlineLarge.copyWith(color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => context.go('/checkout'),
                            child: Text('Finalizar Pedido', style: AppTypography.labelLarge.copyWith(color: AppColors.onPrimary)),
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
