import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/orders_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/order.dart';
import '../../services/websocket_service.dart';

class OrdersView extends ConsumerWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure the WebSocket events stream is active while this view is alive
    ref.watch(orderEventsProvider);

    final ordersAsync = ref.watch(myOrdersProvider);
    final connStatus = ref.watch(wsConnectionStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Pedidos', style: AppTypography.headlineMedium),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _LiveBadge(status: connStatus),
          ),
        ],
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Erro: $err')),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('Nenhum pedido ainda', style: AppTypography.headlineMedium.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => ref.read(myOrdersProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _OrderCard(order: orders[index]),
            ),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────
// _LiveBadge — connection status indicator
// ──────────────────────────────────────────────

class _LiveBadge extends StatefulWidget {
  final WsConnectionStatus status;

  const _LiveBadge({required this.status});

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Color get _dotColor {
    switch (widget.status) {
      case WsConnectionStatus.connected:
        return AppColors.statusReady; // green
      case WsConnectionStatus.connecting:
        return AppColors.statusPending; // amber
      case WsConnectionStatus.disconnected:
        return AppColors.onSurfaceVariant; // gray
    }
  }

  String get _tooltip {
    switch (widget.status) {
      case WsConnectionStatus.connected:
        return 'Atualização em tempo real ativa';
      case WsConnectionStatus.connecting:
        return 'Conectando...';
      case WsConnectionStatus.disconnected:
        return 'Sem conexão em tempo real';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.status == WsConnectionStatus.connected ||
        widget.status == WsConnectionStatus.connecting;

    return Tooltip(
      message: _tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            FadeTransition(
              opacity: _opacity,
              child: _dot(),
            )
          else
            _dot(),
          const SizedBox(width: 4),
          Text(
            'AO VIVO',
            style: AppTypography.labelSmall.copyWith(
              color: _dotColor,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot() => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: _dotColor, shape: BoxShape.circle),
      );
}

// ──────────────────────────────────────────────
// _OrderCard
// ──────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  Color _statusColor() {
    switch (order.status) {
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

  String _statusLabel() {
    switch (order.status) {
      case 'pending':
        return 'Pendente';
      case 'preparing':
        return 'Preparando';
      case 'ready':
        return 'Pronto';
      case 'delivered':
        return 'Entregue';
      case 'cancelled':
        return 'Cancelado';
      default:
        return order.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.code, style: AppTypography.headlineMedium),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _statusColor(), borderRadius: BorderRadius.circular(20)),
                child: Text(_statusLabel(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text('${item.quantity}x ${item.product?.name ?? "Produto"}', style: AppTypography.bodySmall),
              )),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total do Pedido', style: AppTypography.bodySmall),
              Text(CurrencyFormatter.format(order.total), style: AppTypography.titleMedium.copyWith(color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}
