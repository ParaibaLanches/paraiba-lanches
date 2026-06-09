import '../../domain/entities/payment_intent_entity.dart';

class PaymentIntentModel extends PaymentIntentEntity {
  const PaymentIntentModel({
    required super.id,
    required super.clientSecret,
    required super.status,
    super.qrCodeUrl,
    super.pixCopyPaste,
  });

  factory PaymentIntentModel.fromJson(Map<String, dynamic> json) => PaymentIntentModel(
        id: json['id'] as String,
        clientSecret: json['clientSecret'] as String,
        status: json['status'] as String,
        qrCodeUrl: json['qrCodeUrl'] as String?,
        pixCopyPaste: json['pixCopyPaste'] as String?,
      );
}
