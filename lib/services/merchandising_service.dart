import '../core/constants/api_constants.dart';
import '../models/merchandising_section.dart';
import '../core/network/api_service.dart';

class MerchandisingService {
  final ApiService _api;

  MerchandisingService(this._api);

  Future<List<MerchandisingSection>> getHomeData() async {
    try {
      final response = await _api.get(ApiConstants.home);

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        
        // Convert the "featured_products" list from Next.js into a MerchandisingSection
        final featuredProductsJson = data['featured_products'] is List 
            ? data['featured_products'] as List<dynamic>
            : [];
        
        final heroProducts = featuredProductsJson.where((p) => p['featured_slot'] == 'hero').toList();
        final bentoProducts = featuredProductsJson.where((p) => p['featured_slot'] == 'bento_1').toList();
        final otherProducts = featuredProductsJson.where((p) => p['featured_slot'] == 'none' || p['featured_slot'] == null).toList();

        final sections = <MerchandisingSection>[];

        if (heroProducts.isNotEmpty) {
          sections.add(MerchandisingSection.fromJson({
            'id': 1,
            'title': 'Oferta Imperdível',
            'layout_type': 'hero',
            'products': heroProducts,
          }));
        }

        if (bentoProducts.isNotEmpty) {
          sections.add(MerchandisingSection.fromJson({
            'id': 2,
            'title': 'Destaques',
            'subtitle': 'Escolhidos para você',
            'layout_type': 'bento',
            'products': bentoProducts,
          }));
        }

        if (otherProducts.isNotEmpty) {
          sections.add(MerchandisingSection.fromJson({
            'id': 3,
            'title': 'Mais Pedidos',
            'layout_type': 'horizontal_list',
            'products': otherProducts,
          }));
        }

        return sections;
      }
      return [];
    } catch (e) {
      // Re-throw or handle as needed
      rethrow;
    }
  }
}
