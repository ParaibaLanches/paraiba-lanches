import '../../../../../core/network/api_service.dart';
import '../../../../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/auth_tokens_model.dart';

abstract class IAuthRemoteDataSource {
  Future<AuthTokensModel> login(String email, String password);
  Future<void> register(Map<String, dynamic> data);
  Future<UserModel> getProfile();
  Future<void> updateProfile(Map<String, dynamic> data);
  Future<String> updateAvatar(String filePath);
}

class AuthRemoteDataSourceImpl implements IAuthRemoteDataSource {
  final ApiService _api;

  AuthRemoteDataSourceImpl(this._api);

  @override
  Future<AuthTokensModel> login(String email, String password) async {
    final res = await _api.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    if (res['success'] != true) {
      throw Exception(res['error'] ?? 'Erro ao fazer login');
    }
    return AuthTokensModel.fromJson(res['data']);
  }

  @override
  Future<void> register(Map<String, dynamic> data) async {
    final res = await _api.post(
      ApiConstants.register,
      data: data,
    );
    if (res['success'] != true) {
      throw Exception(res['error'] ?? 'Erro ao cadastrar');
    }
  }

  @override
  Future<UserModel> getProfile() async {
    final res = await _api.get(ApiConstants.profile);
    if (res['success'] != true) {
      throw Exception(res['error'] ?? 'Erro ao buscar perfil');
    }
    return UserModel.fromJson(res['data']);
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> data) async {
    final res = await _api.put(
      ApiConstants.profile,
      data: data,
    );
    if (res['success'] != true) {
      throw Exception(res['error'] ?? 'Erro ao atualizar perfil');
    }
  }

  @override
  Future<String> updateAvatar(String filePath) async {
    final res = await _api.upload(
      ApiConstants.updateAvatar,
      filePath,
      fileKey: 'image',
    );
    if (res['success'] != true) {
      throw Exception(res['error'] ?? 'Erro ao enviar imagem');
    }
    return res['data']['avatar_url'] as String;
  }
}
