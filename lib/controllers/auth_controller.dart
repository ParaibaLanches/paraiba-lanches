import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import 'providers.dart';

class AuthState {
  final CustomerProfile? user;
  final bool isLoading;
  final bool isInitialized;
  final bool isAuthenticated;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.isInitialized = false, this.isAuthenticated = false, this.error});

  AuthState copyWith({CustomerProfile? user, bool? isLoading, bool? isInitialized, bool? isAuthenticated, String? error}) {
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
    try {
      await ref.read(authServiceProvider).login(email, password);
      final profile = await ref.read(authServiceProvider).getProfile();
      state = state.copyWith(user: profile, isAuthenticated: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
    }
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
    try {
      await ref.read(authServiceProvider).register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        document: document,
        address: address,
        cep: cep,
        street: street,
        number: number,
        neighborhood: neighborhood,
        city: city,
        state: stateAbbreviation,
        complement: complement,
      );
      await login(email, password);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> loadSession() async {
    final isLoggedIn = await ref.read(authServiceProvider).isLoggedIn();
    if (!isLoggedIn) {
      state = state.copyWith(isInitialized: true);
      return;
    }
    try {
      final profile = await ref.read(authServiceProvider).getProfile();
      state = state.copyWith(user: profile, isAuthenticated: true, isInitialized: true);
    } catch (e) {
      debugPrint('[Auth] Erro ao carregar perfil: $e');
      await ref.read(authServiceProvider).logout();
      state = state.copyWith(isInitialized: true, isAuthenticated: false);
    }
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
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
    try {
      await ref.read(authServiceProvider).updateProfile(
        name: name,
        phone: phone,
        document: document,
        address: address,
        cep: cep,
        street: street,
        number: number,
        neighborhood: neighborhood,
        city: city,
        state: stateAbbreviation,
        complement: complement,
      );
      final profile = await ref.read(authServiceProvider).getProfile();
      state = state.copyWith(user: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> updateAvatar(String filePath) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ref.read(authServiceProvider).updateAvatar(filePath);
      final profile = await ref.read(authServiceProvider).getProfile();
      state = state.copyWith(user: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);
