class CustomerProfile {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String document;
  final String address;

  CustomerProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.document = '',
    this.address = '',
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) => CustomerProfile(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        email: json['email'] as String,
        phone: json['phone'] as String? ?? '',
        document: json['document'] as String? ?? '',
        address: json['address'] as String? ?? '',
      );
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  AuthTokens({required this.accessToken, required this.refreshToken});

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
      );
}
