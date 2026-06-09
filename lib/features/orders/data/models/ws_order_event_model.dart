import '../../domain/entities/ws_order_event_entity.dart';
import 'order_model.dart';

class WsOrderEventModel extends WsOrderEventEntity {
  const WsOrderEventModel({
    required super.event,
    required super.data,
  });

  factory WsOrderEventModel.fromJson(Map<String, dynamic> json) => WsOrderEventModel(
        event: json['event'] as String,
        data: OrderModel.fromJson(json['data'] as Map<String, dynamic>),
      );
}
