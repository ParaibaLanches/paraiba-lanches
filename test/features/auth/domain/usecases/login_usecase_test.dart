import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:paraiba_lanches/core/errors/failures.dart';
import 'package:paraiba_lanches/features/auth/domain/entities/user_entity.dart';
import 'package:paraiba_lanches/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:paraiba_lanches/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUseCase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUser = UserEntity(
    id: 1,
    name: 'Test User',
    email: tEmail,
  );

  test('deve retornar UserEntity do repositório quando o login for bem-sucedido', () async {
    // Arrange
    when(() => mockAuthRepository.login(any(), any()))
        .thenAnswer((_) async => const Result.success(tUser));

    // Act
    final result = await usecase(const LoginParams(email: tEmail, password: tPassword));

    // Assert
    expect(result.isSuccess, true);
    expect(result.value, tUser);
    verify(() => mockAuthRepository.login(tEmail, tPassword)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('deve retornar ServerFailure quando o login falhar', () async {
    // Arrange
    when(() => mockAuthRepository.login(any(), any()))
        .thenAnswer((_) async => const Result.failure(ServerFailure()));

    // Act
    final result = await usecase(const LoginParams(email: tEmail, password: tPassword));

    // Assert
    expect(result.isFailure, true);
    expect(result.failure, isA<ServerFailure>());
    verify(() => mockAuthRepository.login(tEmail, tPassword)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
