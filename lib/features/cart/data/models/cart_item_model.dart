import '../../domain/entities/cart_item_entity.dart';
import '../../../../features/menu/data/models/product_model.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.product,
    super.quantity = 1,
    super.notes = '',
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        product: ProductModel.fromJson(json['product']),
        quantity: json['quantity'] as int? ?? 1,
        notes: json['notes'] as String? ?? '',
      );

  // Note: we're using the old Product's toJson logic if needed, but the old product didn't have toJson.
  // This is okay since we don't serialize cart items back to the server.
}
