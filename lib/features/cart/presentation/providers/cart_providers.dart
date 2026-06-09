import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../controllers/cart_controller.dart';

final cartProvider = NotifierProvider<CartController, List<CartItemEntity>>(
  CartController.new,
);
