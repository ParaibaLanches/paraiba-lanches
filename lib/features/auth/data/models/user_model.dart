import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone = '',
    super.document = '',
    super.address = '',
    super.cep = '',
    super.street = '',
    super.number = '',
    super.neighborhood = '',
    super.city = '',
    super.state = '',
    super.complement = '',
    super.avatarUrl = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        email: json['email'] as String,
        phone: json['phone'] as String? ?? '',
        document: json['document'] as String? ?? '',
        address: json['address'] as String? ?? '',
        cep: json['cep'] as String? ?? '',
        street: json['street'] as String? ?? '',
        number: json['number'] as String? ?? '',
        neighborhood: json['neighborhood'] as String? ?? '',
        city: json['city'] as String? ?? '',
        state: json['state'] as String? ?? '',
        complement: json['complement'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'document': document,
        'address': address,
        'cep': cep,
        'street': street,
        'number': number,
        'neighborhood': neighborhood,
        'city': city,
        'state': state,
        'complement': complement,
        'avatar_url': avatarUrl,
      };
}
