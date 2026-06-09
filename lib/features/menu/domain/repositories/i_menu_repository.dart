import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';
import '../entities/category_entity.dart';

abstract class IMenuRepository {
  Future<Result<List<ProductEntity>>> getMenu();
  Future<Result<List<CategoryEntity>>> getCategories();
}
