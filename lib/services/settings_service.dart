import '../core/constants/api_constants.dart';
import '../models/app_info.dart';
import '../core/network/api_service.dart';

class SettingsService {
  final ApiService _api;

  SettingsService(this._api);

  Future<AppInfo> getAppInfo() async {
    final res = await _api.get(ApiConstants.appInfo);
    if (res['success'] != true) {
      throw Exception(res['error'] ?? 'Erro ao buscar informacoes do app');
    }
    return AppInfo.fromJson(res['data'] as Map<String, dynamic>);
  }
}
