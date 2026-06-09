import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.method,
    required super.amount,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json['id'] as int,
        method: json['method'] as String,
        amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      );
}
