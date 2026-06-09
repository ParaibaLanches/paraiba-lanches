import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category_entity.dart';
import '../repositories/i_menu_repository.dart';

class GetCategoriesUseCase implements UseCase<List<CategoryEntity>, NoParams> {
  final IMenuRepository repository;

  GetCategoriesUseCase(this.repository);

  @override
  Future<Result<List<CategoryEntity>>> call(NoParams params) async {
    return repository.getCategories();
  }
}
