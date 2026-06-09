import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/check_auth_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/update_avatar_usecase.dart';
import '../providers/auth_providers.dart';

class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final bool isInitialized;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.isInitialized = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    bool? isInitialized,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await ref.read(loginUseCaseProvider)(LoginParams(email: email, password: password));
    
    result.fold(
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      onSuccess: (user) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      },
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? document,
    String? address,
    String? cep,
    String? street,
    String? number,
    String? neighborhood,
    String? city,
    String? stateAbbreviation,
    String? complement,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final params = RegisterParams({
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'document': document,
      'address': address,
      'cep': cep,
      'street': street,
      'number': number,
      'neighborhood': neighborhood,
      'city': city,
      'state': stateAbbreviation,
      'complement': complement,
    });

    final result = await ref.read(registerUseCaseProvider)(params);

    result.fold(
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      onSuccess: (user) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      },
    );
  }

  Future<void> loadSession() async {
    final result = await ref.read(checkAuthUseCaseProvider)(const NoParams());
    
    result.fold(
      onFailure: (failure) async {
        debugPrint('[Auth] Erro ao carregar perfil: ${failure.message}');
        await logout();
      },
      onSuccess: (user) {
        if (user != null) {
          state = state.copyWith(
            user: user,
            isAuthenticated: true,
            isInitialized: true,
          );
        } else {
          state = state.copyWith(isInitialized: true);
        }
      },
    );
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider)(const NoParams());
    state = const AuthState(isInitialized: true);
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? document,
    String? address,
    String? cep,
    String? street,
    String? number,
    String? neighborhood,
    String? city,
    String? stateAbbreviation,
    String? complement,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final params = UpdateProfileParams({
      'name': name,
      'phone': phone,
      'document': document,
      'address': address,
      'cep': cep,
      'street': street,
      'number': number,
      'neighborhood': neighborhood,
      'city': city,
      'state': stateAbbreviation,
      'complement': complement,
    });

    final result = await ref.read(updateProfileUseCaseProvider)(params);

    result.fold(
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      onSuccess: (user) {
        state = state.copyWith(user: user, isLoading: false);
      },
    );
  }

  Future<void> updateAvatar(String filePath) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await ref.read(updateAvatarUseCaseProvider)(UpdateAvatarParams(filePath));

    result.fold(
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      onSuccess: (avatarUrl) {
        // We only get the URL back. We need to update the user entity.
        if (state.user != null) {
          // Since UserEntity is final, we might need a copyWith on UserEntity if we wanted full immutability.
          // But since the repository.updateAvatar doesn't return the full profile, we could trigger a checkAuth or getProfile.
          // For now, let's just reload the session to fetch the updated profile.
          loadSession();
        } else {
          state = state.copyWith(isLoading: false);
        }
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
