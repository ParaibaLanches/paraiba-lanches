import '../core/constants/api_constants.dart';
import '../models/merchandising_section.dart';
import 'api_service.dart';

class MerchandisingService {
  final ApiService _api;

  MerchandisingService(this._api);

  Future<List<MerchandisingSection>> getHomeData() async {
    try {
      final response = await _api.get(ApiConstants.home);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data.map((item) => MerchandisingSection.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      // Re-throw or handle as needed
      rethrow;
    }
  }
}
