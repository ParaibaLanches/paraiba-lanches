import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/i_order_repository.dart';

class GetOrderByIdParams {
  final int id;
  const GetOrderByIdParams(this.id);
}

class GetOrderByIdUseCase implements UseCase<OrderEntity, GetOrderByIdParams> {
  final IOrderRepository repository;

  GetOrderByIdUseCase(this.repository);

  @override
  Future<Result<OrderEntity>> call(GetOrderByIdParams params) async {
    return repository.getOrderById(params.id);
  }
}
