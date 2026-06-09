import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/i_order_repository.dart';

class GetMyOrdersUseCase implements UseCase<List<OrderEntity>, NoParams> {
  final IOrderRepository repository;

  GetMyOrdersUseCase(this.repository);

  @override
  Future<Result<List<OrderEntity>>> call(NoParams params) async {
    return repository.getMyOrders();
  }
}
