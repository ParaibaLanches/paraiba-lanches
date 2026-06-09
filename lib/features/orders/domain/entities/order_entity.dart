import 'order_item_entity.dart';
import 'payment_entity.dart';
import 'payment_intent_entity.dart';

class OrderEntity {
  final int id;
  final String code;
  final String orderType;
  final String status;
  final double total;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final String notes;
  final List<OrderItemEntity> items;
  final List<PaymentEntity> payments;
  final PaymentIntentEntity? paymentIntent;
  final String createdAt;
  final String updatedAt;

  const OrderEntity({
    required this.id,
    required this.code,
    required this.orderType,
    required this.status,
    required this.total,
    this.subtotal = 0,
    this.deliveryFee = 0,
    this.discount = 0,
    this.notes = '',
    this.items = const [],
    this.payments = const [],
    this.paymentIntent,
    required this.createdAt,
    required this.updatedAt,
  });
}
