import '../../domain/entities/order_entity.dart';
import 'order_item_model.dart';
import 'payment_model.dart';
import 'payment_intent_model.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.code,
    required super.orderType,
    required super.status,
    required super.total,
    super.subtotal = 0,
    super.deliveryFee = 0,
    super.discount = 0,
    super.notes = '',
    super.items = const [],
    super.payments = const [],
    super.paymentIntent,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as int,
        code: json['code'] as String,
        orderType: (json['order_type'] ?? json['orderType']) as String,
        status: json['status'] as String,
        total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
        subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
        deliveryFee: double.tryParse((json['delivery_fee'] ?? json['deliveryFee'])?.toString() ?? '0') ?? 0,
        discount: double.tryParse((json['discount'] ?? json['discountAmount'])?.toString() ?? '0') ?? 0,
        notes: json['notes'] as String? ?? '',
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        payments: (json['payments'] as List<dynamic>?)
                ?.map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        paymentIntent: (json['payment_intent'] ?? json['paymentIntent']) != null
            ? PaymentIntentModel.fromJson(json['payment_intent'] ?? json['paymentIntent'])
            : null,
        createdAt: (json['created_at'] ?? json['createdAt']) as String,
        updatedAt: (json['updated_at'] ?? json['updatedAt']) as String,
      );
}
