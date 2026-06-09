import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

abstract class IMenuRemoteDataSource {
  Future<List<ProductModel>> getMenu();
  Future<List<CategoryModel>> getCategories();
}

class MenuRemoteDataSource implements IMenuRemoteDataSource {
  final ApiService _api;

  MenuRemoteDataSource(this._api);

  @override
  Future<List<ProductModel>> getMenu() async {
    final res = await _api.get(ApiConstants.menu);
    if (res['success'] != true) {
      throw Exception(res['error'] ?? 'Erro ao buscar cardápio');
    }
    return (res['data'] as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final res = await _api.get(ApiConstants.categories);
    if (res['success'] != true) {
      throw Exception(res['error'] ?? 'Erro ao buscar categorias');
    }
    return (res['data'] as List).map((e) => CategoryModel.fromJson(e)).toList();
  }
}
