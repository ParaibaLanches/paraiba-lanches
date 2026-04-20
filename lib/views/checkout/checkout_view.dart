import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/checkout_controller.dart';
import '../../controllers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';

class CheckoutView extends ConsumerStatefulWidget {
  const CheckoutView({super.key});

  @override
  ConsumerState<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends ConsumerState<CheckoutView> {
  final _couponController = TextEditingController();
  String _orderType = 'local';
  String _paymentMethod = 'pix';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _handleValidateCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    final checkoutNotifier = ref.read(checkoutProvider.notifier);
    checkoutNotifier.setLoading(true);
    checkoutNotifier.setError(null);

    try {
      final coupon = await ref.read(couponServiceProvider).validateCoupon(code);
      checkoutNotifier.setCoupon(coupon);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cupom aplicado com sucesso!'), backgroundColor: AppColors.statusReady),
        );
      }
    } catch (e) {
      if (mounted) {
        checkoutNotifier.setError(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      checkoutNotifier.setLoading(false);
    }
  }

  Future<void> _handleCalculateDelivery(String address) async {
    if (address.isEmpty || _orderType != 'delivery') return;

    final checkoutNotifier = ref.read(checkoutProvider.notifier);
    checkoutNotifier.setLoading(true);

    try {
      final fee = await ref.read(orderServiceProvider).calculateDeliveryFee(address);
      checkoutNotifier.setDeliveryFee(fee);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppColors.error),
        );
      }
    } finally {
      checkoutNotifier.setLoading(false);
    }
  }

  Future<void> _handleSubmit() async {
    final cartItems = ref.read(cartProvider);
    final checkoutState = ref.read(checkoutProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final user = ref.read(authControllerProvider).user;
    if (cartItems.isEmpty) return;

    if (_orderType == 'delivery' && (user?.address ?? '').isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, cadastre um endereço no seu perfil'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final order = await ref.read(orderServiceProvider).createOrder(
            items: cartItems,
            paymentMethod: _paymentMethod,
            paymentAmount: checkoutState.calculateTotal(cartNotifier.total),
            orderType: _orderType,
            notes: _orderType == 'delivery' ? 'Endereço: ${user?.address}' : '',
          );
      cartNotifier.clear();
      ref.read(checkoutProvider.notifier).setCoupon(null);
      ref.read(checkoutProvider.notifier).setDeliveryFee(0);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pedido ${order.code} criado!'), backgroundColor: AppColors.primary),
        );
        context.go('/orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartNotifier = ref.read(cartProvider.notifier);
    final checkoutState = ref.watch(checkoutProvider);

    final subtotal = cartNotifier.total;
    final discount = checkoutState.appliedCoupon?.calculateDiscount(subtotal) ?? 0;
    final total = checkoutState.calculateTotal(subtotal);

    return Scaffold(
      appBar: AppBar(
        title: Text('Finalizar Pedido', style: AppTypography.headlineMedium),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/cart')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order type
            Text('Como quer receber?', style: AppTypography.headlineSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                _TypeChip(
                  label: 'Entrega',
                  value: 'delivery',
                  selected: _orderType,
                  onTap: (v) {
                    setState(() => _orderType = v);
                    if (v == 'delivery') {
                      final userAddress = ref.read(authControllerProvider).user?.address;
                      if (userAddress != null && userAddress.isNotEmpty) {
                        _handleCalculateDelivery(userAddress);
                      }
                    } else {
                      ref.read(checkoutProvider.notifier).setDeliveryFee(0);
                    }
                  },
                ),
                const SizedBox(width: 8),
                _TypeChip(label: 'Retirada', value: 'pickup', selected: _orderType, onTap: (v) => setState(() => _orderType = v)),
                const SizedBox(width: 8),
                _TypeChip(label: 'Local', value: 'local', selected: _orderType, onTap: (v) => setState(() => _orderType = v)),
              ],
            ),
            if (_orderType == 'delivery') ...[
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, _) {
                  final user = ref.watch(authControllerProvider).user;
                  final address = user?.address ?? '';

                  if (address.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Nenhum endereço cadastrado.',
                                  style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => context.go('/profile'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.error),
                                foregroundColor: AppColors.error,
                              ),
                              child: const Text('ADICIONAR ENDEREÇO NO PERFIL'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ENTREGAR EM:', style: AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                              Text(address, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 20),
                          tooltip: 'Recalcular frete',
                          onPressed: () => _handleCalculateDelivery(address),
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (checkoutState.deliveryFee > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    'Taxa de entrega: ${CurrencyFormatter.format(checkoutState.deliveryFee)}',
                    style: AppTypography.labelLarge.copyWith(color: AppColors.statusReady),
                  ),
                ),
            ],
            const SizedBox(height: 24),
            // Coupons
            Text('Tem um cupom?', style: AppTypography.headlineSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      hintText: 'Digite o código',
                      errorText: checkoutState.error,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: checkoutState.isLoading ? null : _handleValidateCoupon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Payment method
            Text('Forma de Pagamento', style: AppTypography.headlineSmall),
            const SizedBox(height: 12),
            _PaymentOption(label: 'Pix', icon: Icons.qr_code, value: 'pix', selected: _paymentMethod, onTap: (v) => setState(() => _paymentMethod = v)),
            _PaymentOption(label: 'Cartão de Crédito', icon: Icons.credit_card, value: 'credit_card', selected: _paymentMethod, onTap: (v) => setState(() => _paymentMethod = v)),
            _PaymentOption(label: 'Dinheiro', icon: Icons.payments_outlined, value: 'cash', selected: _paymentMethod, onTap: (v) => setState(() => _paymentMethod = v)),
            
            const SizedBox(height: 24),
            // Order summary
            Text('Resumo dos Valores', style: AppTypography.headlineSmall),
            const SizedBox(height: 12),
            _SummaryRow(label: 'Subtotal', value: subtotal),
            if (discount > 0)
              _SummaryRow(
                label: 'Desconto (${checkoutState.appliedCoupon!.code})',
                value: -discount,
                textColor: AppColors.statusReady,
              ),
            if (_orderType == 'delivery' && checkoutState.deliveryFee > 0)
              _SummaryRow(label: 'Taxa de Entrega', value: checkoutState.deliveryFee),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOTAL', style: AppTypography.headlineMedium),
                Text(
                  CurrencyFormatter.format(total),
                  style: AppTypography.headlineLarge.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: Container(
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
              child: ElevatedButton(
                onPressed: (_isSubmitting || checkoutState.isLoading) ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Confirmar Pedido', style: AppTypography.labelLarge.copyWith(color: AppColors.onPrimary)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final Color? textColor;

  const _SummaryRow({required this.label, required this.value, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          Text(
            CurrencyFormatter.format(value),
            style: AppTypography.bodyLarge.copyWith(color: textColor, fontWeight: textColor != null ? FontWeight.bold : null),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onTap;

  const _TypeChip({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: AppTypography.labelLarge.copyWith(color: isSelected ? AppColors.onPrimary : AppColors.onSurface)),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String selected;
  final ValueChanged<String> onTap;

  const _PaymentOption({required this.label, required this.icon, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppColors.primary, width: 2) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTypography.titleMedium)),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
