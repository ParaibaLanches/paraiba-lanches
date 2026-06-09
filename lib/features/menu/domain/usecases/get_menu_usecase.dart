import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/i_menu_repository.dart';

class GetMenuUseCase implements UseCase<List<ProductEntity>, NoParams> {
  final IMenuRepository repository;

  GetMenuUseCase(this.repository);

  @override
  Future<Result<List<ProductEntity>>> call(NoParams params) async {
    return repository.getMenu();
  }
}
