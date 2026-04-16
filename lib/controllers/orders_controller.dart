import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/token_storage.dart';
import '../models/order.dart';
import '../models/ws_order_event.dart';
import '../services/websocket_service.dart';
import 'providers.dart';

// ──────────────────────────────────────────────
// WebSocket connection status
// ──────────────────────────────────────────────

class WsStatusNotifier extends Notifier<WsConnectionStatus> {
  @override
  WsConnectionStatus build() => WsConnectionStatus.disconnected;

  void set(WsConnectionStatus status) => state = status;
}

final wsConnectionStatusProvider =
    NotifierProvider<WsStatusNotifier, WsConnectionStatus>(WsStatusNotifier.new);

// ──────────────────────────────────────────────
// Raw WebSocket events stream
// ──────────────────────────────────────────────

final orderEventsProvider = StreamProvider<WsOrderEvent>((ref) {
  final service = ref.watch(wsServiceProvider);

  // Mirror connection status into the StateProvider so the UI can react
  final sub = service.statusStream.listen((status) {
    ref.read(wsConnectionStatusProvider.notifier).set(status);
  });

  service.connect();

  ref.onDispose(() {
    sub.cancel();
    service.disconnect();
  });

  return service.onEvent;
});

// ──────────────────────────────────────────────
// Orders list — merges REST + WebSocket updates
// ──────────────────────────────────────────────

class OrdersNotifier extends AsyncNotifier<List<Order>> {
  @override
  Future<List<Order>> build() async {
    // 0. Ensure we have a token before fetching
    final loggedIn = await TokenStorage.isLoggedIn();
    if (!loggedIn) {
      return []; // Return empty list or wait for session load
    }

    // 1. Load the initial list from REST
    final orders = await ref.read(orderServiceProvider).getMyOrders();

    // 2. Listen to real-time WebSocket events and merge into state
    ref.listen<AsyncValue<WsOrderEvent>>(orderEventsProvider, (_, next) {
      next.whenData(_applyEvent);
    });

    return orders;
  }

  void _applyEvent(WsOrderEvent event) {
    final current = state.value;
    if (current == null) return;

    if (event.isOrderUpdated) {
      // Replace the existing order with the same id
      final updated = current.map((o) {
        return o.id == event.data.id ? event.data : o;
      }).toList();
      state = AsyncData(updated);
    }
    // new_order is not inserted automatically — customer will see it
    // upon next navigation to /orders (REST load) or manual refresh.
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(orderServiceProvider).getMyOrders(),
    );
  }
}

final myOrdersProvider =
    AsyncNotifierProvider<OrdersNotifier, List<Order>>(OrdersNotifier.new);

// ──────────────────────────────────────────────
// Order detail (unchanged)
// ──────────────────────────────────────────────

final orderDetailProvider = FutureProvider.family<Order, int>((ref, id) async {
  return ref.read(orderServiceProvider).getOrderById(id);
});
