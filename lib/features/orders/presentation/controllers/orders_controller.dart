import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/token_storage.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../services/websocket_service.dart';
import '../../../../controllers/providers.dart'; // For wsServiceProvider
import '../../domain/entities/order_entity.dart';
import '../../data/models/ws_order_event_model.dart';
import '../providers/orders_providers.dart';

// ──────────────────────────────────────────────
// WebSocket connection status
// ──────────────────────────────────────────────

class WsStatusNotifier extends Notifier<WsConnectionStatus> {
  @override
  WsConnectionStatus build() => WsConnectionStatus.disconnected;

  void set(WsConnectionStatus status) => state = status;
}

// ──────────────────────────────────────────────
// Raw WebSocket events stream
// ──────────────────────────────────────────────

final _orderEventsStreamProvider = StreamProvider<WsOrderEventModel>((ref) {
  final service = ref.watch(wsServiceProvider);

  final sub = service.statusStream.listen((status) {
    ref.read(wsConnectionStatusProvider.notifier).set(status);
  });

  service.connect();

  ref.onDispose(() {
    sub.cancel();
    service.disconnect();
  });

  // We map the raw event to our Model
  return service.onEvent.map((rawEvent) {
    // Assuming service.onEvent emits rawEvent from the old model temporarily.
    // Wait, the old WebSocketService returns old WsOrderEvent.
    // For now we just cast it to WsOrderEventModel or handle it.
    // Since they have the same structure:
    return WsOrderEventModel(
      event: rawEvent.event,
      data: rawEvent.data,
    );
  });
});

// ──────────────────────────────────────────────
// Orders list — merges REST + WebSocket updates
// ──────────────────────────────────────────────

class OrdersNotifier extends AsyncNotifier<List<OrderEntity>> {
  @override
  Future<List<OrderEntity>> build() async {
    final loggedIn = await TokenStorage.isLoggedIn();
    if (!loggedIn) {
      return [];
    }

    final usecase = ref.read(getMyOrdersUseCaseProvider);
    final result = await usecase(const NoParams());

    ref.listen<AsyncValue<WsOrderEventModel>>(_orderEventsStreamProvider, (_, next) {
      next.whenData(_applyEvent);
    });

    return result.fold(
      onFailure: (failure) => throw Exception(failure.message),
      onSuccess: (orders) => orders,
    );
  }

  void _applyEvent(WsOrderEventModel event) {
    final current = state.value;
    if (current == null) return;

    if (event.isOrderUpdated) {
      final updated = current.map((o) {
        return o.id == event.data.id ? event.data : o;
      }).toList();
      state = AsyncData(updated);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final usecase = ref.read(getMyOrdersUseCaseProvider);
    final result = await usecase(const NoParams());
    
    state = result.fold(
      onFailure: (failure) => AsyncError(failure.message, StackTrace.current),
      onSuccess: (orders) => AsyncData(orders),
    );
  }
}
