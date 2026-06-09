import '../../domain/entities/order_item_entity.dart';
import '../../../../models/product.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.orderId,
    required super.productId,
    super.product,
    required super.quantity,
    required super.unitPrice,
    super.notes = '',
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        id: json['id'] as int,
        orderId: (json['order_id'] ?? json['orderId']) as int,
        productId: (json['product_id'] ?? json['productId']) as int,
        product: json['product'] != null ? Product.fromJson(json['product']) : null,
        quantity: json['quantity'] as int? ?? 1,
        unitPrice: double.tryParse((json['unit_price'] ?? json['unitPrice'])?.toString() ?? '0') ?? 0,
        notes: json['notes'] as String? ?? '',
      );
}
