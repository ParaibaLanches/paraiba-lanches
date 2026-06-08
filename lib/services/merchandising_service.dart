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
        final data = response['data'] as Map<String, dynamic>;
        
        // Convert the "featured_products" list from Next.js into a MerchandisingSection
        final featuredProductsJson = data['featured_products'] as List<dynamic>? ?? [];
        
        if (featuredProductsJson.isEmpty) return [];

        final section = MerchandisingSection.fromJson({
          'id': 1,
          'title': 'Destaques',
          'subtitle': 'Os mais pedidos',
          'layout_type': 'horizontal_list',
          'products': featuredProductsJson,
        });

        return [section];
      }
      return [];
    } catch (e) {
      // Re-throw or handle as needed
      rethrow;
    }
  }
}
