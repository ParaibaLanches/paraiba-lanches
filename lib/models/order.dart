import 'product.dart';

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final Product? product;
  final int quantity;
  final double unitPrice;
  final String notes;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    this.product,
    required this.quantity,
    required this.unitPrice,
    this.notes = '',
  });

  double get subtotal => quantity * unitPrice;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'] as int,
    orderId: json['order_id'] as int,
    productId: json['product_id'] as int,
    product: json['product'] != null ? Product.fromJson(json['product']) : null,
    quantity: json['quantity'] as int,
    unitPrice: (json['unit_price'] as num).toDouble(),
    notes: json['notes'] as String? ?? '',
  );
}

class Payment {
  final int id;
  final String method;
  final double amount;

  Payment({required this.id, required this.method, required this.amount});

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'] as int,
    method: json['method'] as String,
    amount: (json['amount'] as num).toDouble(),
  );
}

class Order {
  final int id;
  final String code;
  final String orderType;
  final String status;
  final double total;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final String notes;
  final List<OrderItem> items;
  final List<Payment> payments;
  final String createdAt;
  final String updatedAt;

  Order({
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as int,
    code: json['code'] as String,
    orderType: json['order_type'] as String,
    status: json['status'] as String,
    total: (json['total'] as num).toDouble(),
    subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
    deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
    discount: (json['discount'] as num?)?.toDouble() ?? 0,
    notes: json['notes'] as String? ?? '',
    items:
        (json['items'] as List<dynamic>?)
            ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    payments:
        (json['payments'] as List<dynamic>?)
            ?.map((e) => Payment.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    createdAt: json['created_at'] as String,
    updatedAt: json['updated_at'] as String,
  );
}
