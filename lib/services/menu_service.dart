import '../core/constants/api_constants.dart';
import '../models/product.dart';
import '../core/network/api_service.dart';

class MenuService {
  final ApiService _api;

  MenuService(this._api);

  Future<List<Product>> getMenu() async {
    final res = await _api.get(ApiConstants.menu);
    if (res['success'] != true) {
      throw Exception(res['error'] ?? 'Erro ao buscar cardapio');
    }
    return (res['data'] as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Category>> getCategories() async {
    final res = await _api.get(ApiConstants.categories);
    if (res['success'] != true) {
      throw Exception(res['error'] ?? 'Erro ao buscar categorias');
    }
    return (res['data'] as List).map((e) => Category.fromJson(e)).toList();
  }
}
