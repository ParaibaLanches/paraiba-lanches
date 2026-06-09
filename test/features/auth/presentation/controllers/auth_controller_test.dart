import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:paraiba_lanches/core/errors/failures.dart';
import 'package:paraiba_lanches/features/auth/domain/entities/user_entity.dart';
import 'package:paraiba_lanches/features/auth/domain/usecases/login_usecase.dart';
import 'package:paraiba_lanches/features/auth/presentation/controllers/auth_controller.dart';
import 'package:paraiba_lanches/features/auth/presentation/providers/auth_providers.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late ProviderContainer container;
  late MockLoginUseCase mockLoginUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    
    // Register fallbacks for mocktail
    registerFallbackValue(const LoginParams(email: '', password: ''));

    // Override the provider with our mock
    container = ProviderContainer(
      overrides: [
        loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUser = UserEntity(
    id: 1,
    name: 'Test User',
    email: tEmail,
  );

  test('o estado inicial deve ser AuthState()', () {
    final state = container.read(authControllerProvider);
    expect(state.isLoading, false);
    expect(state.isAuthenticated, false);
    expect(state.user, isNull);
    expect(state.error, isNull);
  });

  test('deve atualizar o estado para autenticado quando o login for sucesso', () async {
    // Arrange
    when(() => mockLoginUseCase(any())).thenAnswer((_) async => const Result.success(tUser));

    // Act
    await container.read(authControllerProvider.notifier).login(tEmail, tPassword);

    // Assert
    final state = container.read(authControllerProvider);
    expect(state.isLoading, false);
    expect(state.isAuthenticated, true);
    expect(state.user, tUser);
    expect(state.error, isNull);
    
    verify(() => mockLoginUseCase(any())).called(1);
  });

  test('deve atualizar o estado com erro quando o login falhar', () async {
    // Arrange
    const tErrorMessage = 'Credenciais inválidas';
    when(() => mockLoginUseCase(any())).thenAnswer((_) async => const Result.failure(ServerFailure(tErrorMessage)));

    // Act
    await container.read(authControllerProvider.notifier).login(tEmail, tPassword);

    // Assert
    final state = container.read(authControllerProvider);
    expect(state.isLoading, false);
    expect(state.isAuthenticated, false);
    expect(state.user, isNull);
    expect(state.error, tErrorMessage);
    
    verify(() => mockLoginUseCase(any())).called(1);
  });
}
