import '../core/constants/api_constants.dart';
import '../core/storage/token_storage.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api;

  AuthService(this._api);

  Future<AuthTokens> login(String email, String password) async {
    final res = await _api.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    if (res['success'] != true) {
      throw Exception(res['error'] ?? 'Erro ao fazer login');
    }

    final tokens = AuthTokens.fromJson(res['data']);
    await TokenStorage.saveTokens(tokens.accessToken, tokens.refreshToken);
    return tokens;
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
    String? state,
    String? complement,
  }) async {
    final res = await _api.post(
      ApiConstants.register,
      data: {
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
        'state': state,
        'complement': complement,
      },
    );
    if (res['success'] != true) {
      throw Exception(res['error'] ?? 'Erro ao cadastrar');
    }
  }

  Future<CustomerProfile> getProfile() async {
    final res = await _api.get(ApiConstants.profile);
    if (res['success'] != true) {
      throw Exception(res['error'] ?? 'Erro ao buscar perfil');
    }
    return CustomerProfile.fromJson(res['data']);
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
    String? state,
    String? complement,
  }) async {
    final res = await _api.put(
      ApiConstants.profile,
      data: {
        'name': name,
        'phone': phone,
        'document': document,
        'address': address,
        'cep': cep,
        'street': street,
        'number': number,
        'neighborhood': neighborhood,
        'city': city,
        'state': state,
        'complement': complement,
      },
    );
    if (res['success'] != true) {
      throw Exception(res['error'] ?? 'Erro ao atualizar');
    }
  }

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

  Future<void> logout() async {
    await TokenStorage.clearTokens();
  }

  Future<bool> isLoggedIn() async {
    return TokenStorage.isLoggedIn();
  }
}
