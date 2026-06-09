class PaymentEntity {
  final int id;
  final String method;
  final double amount;

  const PaymentEntity({
    required this.id,
    required this.method,
    required this.amount,
  });
}
