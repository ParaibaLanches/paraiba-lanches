import 'product.dart';

class PaymentIntent {
  final String id;
  final String clientSecret;
  final String status;
  final String? qrCodeUrl;
  final String? pixCopyPaste;

  PaymentIntent({
    required this.id,
    required this.clientSecret,
    required this.status,
    this.qrCodeUrl,
    this.pixCopyPaste,
  });

  factory PaymentIntent.fromJson(Map<String, dynamic> json) => PaymentIntent(
    id: json['id'] as String,
    clientSecret: json['clientSecret'] as String,
    status: json['status'] as String,
    qrCodeUrl: json['qrCodeUrl'] as String?,
    pixCopyPaste: json['pixCopyPaste'] as String?,
  );
}

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
    orderId: (json['order_id'] ?? json['orderId']) as int,
    productId: (json['product_id'] ?? json['productId']) as int,
    product: json['product'] != null ? Product.fromJson(json['product']) : null,
    quantity: json['quantity'] as int? ?? 1,
    unitPrice: double.tryParse((json['unit_price'] ?? json['unitPrice'])?.toString() ?? '0') ?? 0,
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
    amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
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
  final PaymentIntent? paymentIntent;
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
    this.paymentIntent,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as int,
    code: json['code'] as String,
    orderType: (json['order_type'] ?? json['orderType']) as String,
    status: json['status'] as String,
    total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
    subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
    deliveryFee: double.tryParse((json['delivery_fee'] ?? json['deliveryFee'])?.toString() ?? '0') ?? 0,
    discount: double.tryParse((json['discount'] ?? json['discountAmount'])?.toString() ?? '0') ?? 0,
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
    paymentIntent: (json['payment_intent'] ?? json['paymentIntent']) != null ? PaymentIntent.fromJson(json['payment_intent'] ?? json['paymentIntent']) : null,
    createdAt: (json['created_at'] ?? json['createdAt']) as String,
    updatedAt: (json['updated_at'] ?? json['updatedAt']) as String,
  );
}
