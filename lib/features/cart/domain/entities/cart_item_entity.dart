import '../../../../features/menu/domain/entities/product_entity.dart';

class CartItemEntity {
  final ProductEntity product;
  final int quantity;
  final String notes;

  const CartItemEntity({
    required this.product,
    this.quantity = 1,
    this.notes = '',
  });

  double get subtotal => product.price * quantity;

  CartItemEntity copyWith({
    ProductEntity? product,
    int? quantity,
    String? notes,
  }) {
    return CartItemEntity(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }
}
