class Coupon {
  final int id;
  final String code;
  final String type; // 'percentage', 'fixed'
  final double value;
  final double minPurchase;
  final DateTime expiresAt;
  final bool isActive;

  Coupon({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.minPurchase = 0,
    required this.expiresAt,
    this.isActive = true,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as int,
      code: json['code'] as String,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      minPurchase: (json['min_purchase'] as num? ?? 0).toDouble(),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  double calculateDiscount(double subtotal) {
    if (subtotal < minPurchase) return 0;

    if (type == 'percentage') {
      return subtotal * (value / 100);
    } else {
      return value;
    }
  }

  bool get isPercentage => type == 'percentage';
}
