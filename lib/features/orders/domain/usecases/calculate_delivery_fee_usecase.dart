import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_order_repository.dart';

class CalculateDeliveryFeeParams {
  final String destination;
  const CalculateDeliveryFeeParams(this.destination);
}

class CalculateDeliveryFeeUseCase implements UseCase<double, CalculateDeliveryFeeParams> {
  final IOrderRepository repository;

  CalculateDeliveryFeeUseCase(this.repository);

  @override
  Future<Result<double>> call(CalculateDeliveryFeeParams params) async {
    return repository.calculateDeliveryFee(params.destination);
  }
}
