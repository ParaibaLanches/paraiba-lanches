import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paraiba_lanches/features/cart/presentation/controllers/cart_controller.dart';
import 'package:paraiba_lanches/features/cart/presentation/providers/cart_providers.dart';
import 'package:paraiba_lanches/features/cart/domain/entities/cart_item_entity.dart';
import 'package:paraiba_lanches/features/menu/domain/entities/product_entity.dart';

void main() {
  late ProviderContainer container;
  final mockProduct = ProductEntity(
    id: 1,
    name: 'Hamburger',
    price: 10.0,
    categoryId: 1,
  );

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state is empty', () {
    final cart = container.read(cartProvider);
    expect(cart.isEmpty, true);
  });

  test('addItem adds a new item', () {
    final cartNotifier = container.read(cartProvider.notifier);
    
    cartNotifier.addItem(mockProduct);
    
    final cart = container.read(cartProvider);
    expect(cart.length, 1);
    expect(cart.first.product.id, mockProduct.id);
    expect(cart.first.quantity, 1);
  });

  test('addItem increments quantity if item already exists', () {
    final cartNotifier = container.read(cartProvider.notifier);
    
    cartNotifier.addItem(mockProduct);
    cartNotifier.addItem(mockProduct);
    
    final cart = container.read(cartProvider);
    expect(cart.length, 1);
    expect(cart.first.quantity, 2);
  });

  test('removeItem removes the item', () {
    final cartNotifier = container.read(cartProvider.notifier);
    
    cartNotifier.addItem(mockProduct);
    cartNotifier.removeProductEntity(mockProduct.id);
    
    final cart = container.read(cartProvider);
    expect(cart.isEmpty, true);
  });

  test('updateQuantity updates the quantity', () {
    final cartNotifier = container.read(cartProvider.notifier);
    
    cartNotifier.addItem(mockProduct);
    cartNotifier.updateQuantity(mockProduct.id, 5);
    
    final cart = container.read(cartProvider);
    expect(cart.first.quantity, 5);
  });

  test('total getter calculates correctly', () {
    final cartNotifier = container.read(cartProvider.notifier);
    
    cartNotifier.addItem(mockProduct);
    cartNotifier.addItem(mockProduct); // quantity 2, price 10 = 20
    
    final total = cartNotifier.total;
    expect(total, 20.0);
  });

  test('clear empties the cart', () {
    final cartNotifier = container.read(cartProvider.notifier);
    
    cartNotifier.addItem(mockProduct);
    cartNotifier.clear();
    
    final cart = container.read(cartProvider);
    expect(cart.isEmpty, true);
  });
}
