import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    ref.watch(orderEventsProvider);

    final ordersAsync = ref.watch(myOrdersProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Meus Pedidos', style: AppTypography.headlineMedium),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.outline,
            tabs: const [
              Tab(text: 'Em andamento'),
              Tab(text: 'Histórico'),
            ],
          ),
        ),
        body: ordersAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, _) => Center(child: Text('Erro: $err')),
          data: (orders) {
            final activeOrders = orders
                .where(
                  (o) =>
                      o.status == 'pending' ||
                      o.status == 'preparing' ||
                      o.status == 'ready',
                )
                .toList();

            final historicalOrders = orders
                .where(
                  (o) => o.status == 'delivered' || o.status == 'cancelled',
                )
                .toList();

            return TabBarView(
              children: [
                _OrderList(
                  orders: activeOrders,
                  emptyLabel: 'Nenhum pedido em andamento',
                  ref: ref,
                ),
                _OrderList(
                  orders: historicalOrders,
                  emptyLabel: 'Seu histórico está vazio',
                  ref: ref,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<Order> orders;
  final String emptyLabel;
  final WidgetRef ref;

  const _OrderList({
    required this.orders,
    required this.emptyLabel,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              emptyLabel,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(myOrdersProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: orders.length,
        separatorBuilder: (_, _) => const SizedBox(height: 0),
        itemBuilder: (context, index) => _OrderCard(order: orders[index]),
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

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _opacity = Tween<double>(
      begin: 0.35,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
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
    final isActive =
        widget.status == WsConnectionStatus.connected ||
        widget.status == WsConnectionStatus.connecting;

    return Tooltip(
      message: _tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            FadeTransition(opacity: _opacity, child: _dot())
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
    return InkWell(
      onTap: () => context.push('/order-detail', extra: order),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        order.code,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _statusLabel().toUpperCase(),
                          style: TextStyle(
                            color: _statusColor(),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.items.length} ite${order.items.length == 1 ? 'm' : 'ns'} • ${order.orderType == 'delivery' ? 'Entrega' : 'Retirada'}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              CurrencyFormatter.format(order.total),
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: AppColors.outlineVariant,
            ),
          ],
        ),
      ),
    );
  }
}
