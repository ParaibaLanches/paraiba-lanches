class PaymentIntentEntity {
  final String id;
  final String clientSecret;
  final String status;
  final String? qrCodeUrl;
  final String? pixCopyPaste;

  const PaymentIntentEntity({
    required this.id,
    required this.clientSecret,
    required this.status,
    this.qrCodeUrl,
    this.pixCopyPaste,
  });
}
