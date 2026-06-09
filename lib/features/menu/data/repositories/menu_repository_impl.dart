import '../../../../core/errors/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/i_menu_repository.dart';
import '../datasources/menu_remote_data_source.dart';

class MenuRepositoryImpl implements IMenuRepository {
  final IMenuRemoteDataSource remoteDataSource;

  MenuRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<ProductEntity>>> getMenu() async {
    try {
      final result = await remoteDataSource.getMenu();
      return Result.success(result);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<CategoryEntity>>> getCategories() async {
    try {
      final result = await remoteDataSource.getCategories();
      return Result.success(result);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
