import '../../../../../core/errors/failures.dart';
import '../../../../../core/storage/token_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/auth_tokens_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<UserEntity>> login(String email, String password) async {
    try {
      final tokens = await remoteDataSource.login(email, password);
      await TokenStorage.saveTokens(tokens.accessToken, tokens.refreshToken);
      final profile = await remoteDataSource.getProfile();
      return Result.success(profile);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> register(Map<String, dynamic> userData) async {
    try {
      await remoteDataSource.register(userData);
      return await login(userData['email'], userData['password']);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await TokenStorage.clearTokens();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<AuthTokensEntity?>> getSavedTokens() async {
    try {
      final isLogged = await TokenStorage.isLoggedIn();
      if (!isLogged) return const Result.success(null);
      
      // Ideally we would return the tokens from TokenStorage if we exposed them.
      // For now, just returning a dummy entity to represent true if isLoggedIn.
      // We'll skip actual token retrieval unless we implement it in TokenStorage.
      return const Result.success(AuthTokensEntity(accessToken: '', refreshToken: ''));
    } catch (e) {
      return Result.failure(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final isLogged = await TokenStorage.isLoggedIn();
      if (!isLogged) return const Result.success(null);

      final profile = await remoteDataSource.getProfile();
      return Result.success(profile);
    } catch (e) {
      return const Result.success(null); // Return null on failure to allow app to start unauthenticated
    }
  }

  @override
  Future<Result<UserEntity>> getProfile() async {
    try {
      final profile = await remoteDataSource.getProfile();
      return Result.success(profile);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> updateProfile(Map<String, dynamic> data) async {
    try {
      await remoteDataSource.updateProfile(data);
      final profile = await remoteDataSource.getProfile();
      return Result.success(profile);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
  @override
  Future<Result<String>> updateAvatar(String filePath) async {
    try {
      final avatarUrl = await remoteDataSource.updateAvatar(filePath);
      return Result.success(avatarUrl);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
