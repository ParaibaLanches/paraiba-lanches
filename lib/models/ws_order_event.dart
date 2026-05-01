import 'order.dart';

/// Represents a real-time event received from the WebSocket `/ws/orders` endpoint.
///
/// Backend payload contract:
/// ```json
/// { "event": "new_order" | "order_updated", "data": { ...Order } }
/// ```
class WsOrderEvent {
  final String event;
  final Order data;

  const WsOrderEvent({required this.event, required this.data});

  factory WsOrderEvent.fromJson(Map<String, dynamic> json) => WsOrderEvent(
    event: json['event'] as String,
    data: Order.fromJson(json['data'] as Map<String, dynamic>),
  );

  bool get isNewOrder => event == 'new_order';
  bool get isOrderUpdated => event == 'order_updated';
}
