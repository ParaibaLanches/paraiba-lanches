import 'order_entity.dart';

class WsOrderEventEntity {
  final String event;
  final OrderEntity data;

  const WsOrderEventEntity({
    required this.event,
    required this.data,
  });

  bool get isNewOrder => event == 'new_order';
  bool get isOrderUpdated => event == 'order_updated';
}
