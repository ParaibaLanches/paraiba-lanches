class CustomerProfile {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String document;
  final String address;
  final String cep;
  final String street;
  final String number;
  final String neighborhood;
  final String city;
  final String state;
  final String complement;
  final String avatarUrl;

  CustomerProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.document = '',
    this.address = '',
    this.cep = '',
    this.street = '',
    this.number = '',
    this.neighborhood = '',
    this.city = '',
    this.state = '',
    this.complement = '',
    this.avatarUrl = '',
  });

  String get fullAddress {
    List<String> parts = [];
    if (street.isNotEmpty) parts.add(street);
    if (number.isNotEmpty) parts.add(number);
    if (neighborhood.isNotEmpty) parts.add(neighborhood);
    
    String result = parts.join(', ');
    
    if (city.isNotEmpty && state.isNotEmpty) {
      if (result.isNotEmpty) result += ' - ';
      result += '$city/$state';
    } else if (city.isNotEmpty) {
      if (result.isNotEmpty) result += ' - ';
      result += city;
    }
    
    if (cep.isNotEmpty) {
      if (result.isNotEmpty) result += ' - CEP: ';
      result += cep;
    }

    if (complement.isNotEmpty) {
      if (result.isNotEmpty) result += '\n';
      result += 'Complemento: $complement';
    }

    if (result.isEmpty && address.isNotEmpty) {
      return address;
    }

    return result;
  }

  factory CustomerProfile.fromJson(Map<String, dynamic> json) =>
      CustomerProfile(
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
