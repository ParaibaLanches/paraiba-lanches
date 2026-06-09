import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../../../models/product.dart';

class CartController extends Notifier<List<CartItemEntity>> {
  @override
  List<CartItemEntity> build() => [];

  double get total => state.fold(0, (sum, item) => sum + item.subtotal);
  int get itemCount => state.fold(0, (sum, item) => sum + item.quantity);

  void addProduct(Product product) => addItem(product);

  void addItem(Product product, {int quantity = 1}) {
    final index = state.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      final updated = List<CartItemEntity>.from(state);
      updated[index] = updated[index].copyWith(
        quantity: updated[index].quantity + quantity,
      );
      state = updated;
    } else {
      state = [...state, CartItemEntity(product: product, quantity: quantity)];
    }
  }

  void removeProduct(int productId) {
    state = state.where((i) => i.product.id != productId).toList();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    state = state.map((i) {
      if (i.product.id == productId) {
        return i.copyWith(quantity: quantity);
      }
      return i;
    }).toList();
  }

  void updateNotes(int productId, String notes) {
    state = state.map((i) {
      if (i.product.id == productId) {
        return i.copyWith(notes: notes);
      }
      return i;
    }).toList();
  }

  void clear() => state = [];
}
