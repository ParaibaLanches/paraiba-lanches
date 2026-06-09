import '../../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../entities/auth_tokens_entity.dart';

abstract class IAuthRepository {
  Future<Result<UserEntity>> login(String email, String password);
  Future<Result<UserEntity>> register(Map<String, dynamic> userData);
  Future<Result<void>> logout();
  Future<Result<AuthTokensEntity?>> getSavedTokens();
  Future<Result<UserEntity?>> getCurrentUser();
  Future<Result<UserEntity>> getProfile();
  Future<Result<UserEntity>> updateProfile(Map<String, dynamic> data);
  Future<Result<String>> updateAvatar(String filePath);
}
