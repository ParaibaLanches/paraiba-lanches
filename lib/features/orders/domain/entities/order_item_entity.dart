import '../../../../features/menu/domain/entities/product_entity.dart';

class OrderItemEntity {
  final int id;
  final int orderId;
  final int productId;
  final ProductEntity? product;
  final int quantity;
  final double unitPrice;
  final String notes;

  const OrderItemEntity({
    required this.id,
    required this.orderId,
    required this.productId,
    this.product,
    required this.quantity,
    required this.unitPrice,
    this.notes = '',
  });

  double get subtotal => quantity * unitPrice;
}
