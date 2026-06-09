import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../features/cart/presentation/providers/cart_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../widgets/app_button.dart';
import '../widgets/empty_state.dart';

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
              child: Text(
                'Limpar',
                style: AppTypography.bodySmall.copyWith(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: cart.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Carrinho vazio',
              description:
                  'Adicione itens deliciosos do nosso cardápio para continuar.',
              buttonLabel: 'Ir para o cardápio',
              onButtonPressed: () => context.go('/home'),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: cart.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 0),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.outlineVariant.withValues(alpha: 0.15),
                            ),
                          ),
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
                                        placeholder: (context, url) =>
                                            Shimmer.fromColors(
                                              baseColor:
                                                  AppColors.surfaceContainerLow,
                                              highlightColor: AppColors
                                                  .surfaceContainerLowest,
                                              child: Container(
                                                color: AppColors
                                                    .surfaceContainerLow,
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                              color:
                                                  AppColors.surfaceContainerLow,
                                              child: const Icon(
                                                Icons.lunch_dining,
                                                color:
                                                    AppColors.onSurfaceVariant,
                                                size: 28,
                                              ),
                                            ),
                                      )
                                    : Container(
                                        color: AppColors.surfaceContainerLow,
                                        child: const Icon(
                                          Icons.lunch_dining,
                                          color: AppColors.onSurfaceVariant,
                                          size: 28,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: AppTypography.titleMedium,
                                  ),
                                  Text(
                                    CurrencyFormatter.format(item.subtotal),
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => cartNotifier.updateQuantity(
                                    item.product.id,
                                    item.quantity - 1,
                                  ),
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    size: 22,
                                  ),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: AppTypography.titleMedium,
                                ),
                                IconButton(
                                  onPressed: () => cartNotifier.updateQuantity(
                                    item.product.id,
                                    item.quantity + 1,
                                  ),
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    size: 22,
                                  ),
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
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total', style: AppTypography.headlineMedium),
                            Text(
                              CurrencyFormatter.format(cartNotifier.total),
                              style: AppTypography.headlineLarge.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          label: 'Finalizar Pedido',
                          onPressed: () => context.go('/checkout'),
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
