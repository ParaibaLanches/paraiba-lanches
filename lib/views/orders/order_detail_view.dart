import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/orders_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/order.dart';

class OrderDetailView extends ConsumerWidget {
  final Order order;

  const OrderDetailView({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for updates on this specific order if possible,
    // or just rely on the parent's update since it's passed as object.
    // However, if we refresh, we might want the latest data.
    final orderAsync = ref.watch(orderDetailProvider(order.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Detalhes do Pedido', style: AppTypography.titleLarge),
        centerTitle: true,
      ),
      body: orderAsync.when(
        data: (liveOrder) => _buildContent(context, liveOrder),
        loading: () => _buildContent(context, order, isLoading: true),
        error: (err, _) => _buildContent(context, order, error: err.toString()),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Order currentOrder, {
    bool isLoading = false,
    String? error,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusHeader(currentOrder),
          const SizedBox(height: 32),
          _buildStatusTimeline(currentOrder),
          const SizedBox(height: 32),
          _buildItemsSection(currentOrder),
          const SizedBox(height: 32),
          _buildSummarySection(currentOrder),
          const SizedBox(height: 32),
          _buildInfoSection(currentOrder),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(Order currentOrder) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Código do Pedido',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.outline,
                ),
              ),
              Text(
                currentOrder.code,
                style: AppTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          _StatusBadge(status: currentOrder.status),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(Order currentOrder) {
    final steps = ['pending', 'preparing', 'ready', 'delivered'];
    final currentStepIndex = steps.indexOf(currentOrder.status);

    if (currentOrder.status == 'cancelled') {
      return Center(
        child: Text(
          'PEDIDO CANCELADO',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.statusCancelled,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acompanhamento',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(steps.length, (index) {
            final isCompleted = index <= currentStepIndex;
            final isLast = index == steps.length - 1;
            final isFirst = index == 0;

            return Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      // Line before
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isFirst
                              ? Colors.transparent
                              : (isCompleted
                                  ? AppColors.primary
                                  : AppColors.outlineVariant),
                        ),
                      ),
                      // Circle
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.primary
                              : AppColors.outlineVariant,
                          shape: BoxShape.circle,
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      // Line after
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isLast
                              ? Colors.transparent
                              : (index < currentStepIndex
                                  ? AppColors.primary
                                  : AppColors.outlineVariant),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStatusStepLabel(steps[index]),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isCompleted ? FontWeight.bold : null,
                      color: isCompleted
                          ? AppColors.onSurface
                          : AppColors.outline,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  String _getStatusStepLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Recebido';
      case 'preparing':
        return 'Cozinha';
      case 'ready':
        return 'Pronto';
      case 'delivered':
        return 'Entregue';
      default:
        return '';
    }
  }

  Widget _buildItemsSection(Order currentOrder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Itens do Pedido',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...currentOrder.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.quantity}x',
                    style: AppTypography.labelLarge,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product?.name ?? 'Produto',
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (item.notes.isNotEmpty)
                        Text(
                          item.notes,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.format(item.subtotal),
                  style: AppTypography.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(Order currentOrder) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', currentOrder.subtotal),
          if (currentOrder.deliveryFee > 0)
            _buildSummaryRow('Taxa de Entrega', currentOrder.deliveryFee),
          if (currentOrder.discount > 0)
            _buildSummaryRow(
              'Desconto',
              -currentOrder.discount,
              color: Colors.green,
            ),
          const Divider(height: 24),
          _buildSummaryRow('Total', currentOrder.total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double value, {
    bool isTotal = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal ? AppTypography.titleLarge : AppTypography.bodyLarge,
          ),
          Text(
            CurrencyFormatter.format(value),
            style:
                (isTotal ? AppTypography.titleLarge : AppTypography.bodyLarge)
                    .copyWith(
                      color: color ?? (isTotal ? AppColors.primary : null),
                      fontWeight: isTotal ? FontWeight.bold : null,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Order currentOrder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informações Adicionais',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          Icons.payment,
          'Pagamento',
          currentOrder.payments.isNotEmpty
              ? _getPaymentMethodLabel(currentOrder.payments.first.method)
              : 'N/A',
        ),
        _buildInfoRow(
          Icons.location_on_outlined,
          'Tipo',
          currentOrder.orderType == 'delivery' ? 'Entrega' : 'Retirada / Local',
        ),
        if (currentOrder.notes.isNotEmpty)
          _buildInfoRow(Icons.notes, 'Observações', currentOrder.notes),
      ],
    );
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'pix':
        return 'Pix';
      case 'credit_card':
        return 'Cartão de Crédito';
      case 'debit_card':
        return 'Cartão de Débito';
      case 'cash':
        return 'Dinheiro';
      default:
        return method;
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.outline),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.outline,
                  ),
                ),
                Text(value, style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  Color _color() {
    switch (status) {
      case 'pending':
        return AppColors.statusPending;
      case 'preparing':
        return AppColors.statusPreparing;
      case 'ready':
        return AppColors.statusReady;
      case 'delivered':
        return AppColors.statusDelivered;
      case 'cancelled':
        return AppColors.statusCancelled;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  String _label() {
    switch (status) {
      case 'pending':
        return 'PENDENTE';
      case 'preparing':
        return 'PREPARANDO';
      case 'ready':
        return 'PRONTO';
      case 'delivered':
        return 'ENTREGUE';
      case 'cancelled':
        return 'CANCELADO';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _label(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
