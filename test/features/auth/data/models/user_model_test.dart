import 'package:flutter_test/flutter_test.dart';
import 'package:paraiba_lanches/features/auth/data/models/user_model.dart';
import 'package:paraiba_lanches/features/auth/domain/entities/user_entity.dart';

void main() {
  const tUserModel = UserModel(
    id: 1,
    name: 'Test',
    email: 'test@email.com',
  );

  test('deve ser uma subclasse de UserEntity', () async {
    expect(tUserModel, isA<UserEntity>());
  });

  group('fromJson', () {
    test('deve retornar um modelo válido quando o JSON contiver os dados necessários', () async {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 1,
        'name': 'Test',
        'email': 'test@email.com',
        'phone': '',
        'document': '',
        'address': '',
        'cep': '',
        'street': '',
        'number': '',
        'neighborhood': '',
        'city': '',
        'state': '',
        'complement': '',
        'avatar_url': '',
      };

      // Act
      final result = UserModel.fromJson(jsonMap);

      // Assert
      // We haven't implemented equatable, so we check properties.
      expect(result.id, tUserModel.id);
      expect(result.name, tUserModel.name);
      expect(result.email, tUserModel.email);
    });
  });
}
