import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../entities/order_entity.dart';
import '../repositories/i_order_repository.dart';

class CreateOrderParams {
  final List<CartItemEntity> items;
  final String paymentMethod;
  final double paymentAmount;
  final String orderType;
  final String notes;
  final double deliveryFee;
  final double discountAmount;

  const CreateOrderParams({
    required this.items,
    required this.paymentMethod,
    required this.paymentAmount,
    this.orderType = 'local',
    this.notes = '',
    this.deliveryFee = 0,
    this.discountAmount = 0,
  });
}

class CreateOrderUseCase implements UseCase<OrderEntity, CreateOrderParams> {
  final IOrderRepository repository;

  CreateOrderUseCase(this.repository);

  @override
  Future<Result<OrderEntity>> call(CreateOrderParams params) async {
    return repository.createOrder(
      items: params.items,
      paymentMethod: params.paymentMethod,
      paymentAmount: params.paymentAmount,
      orderType: params.orderType,
      notes: params.notes,
      deliveryFee: params.deliveryFee,
      discountAmount: params.discountAmount,
    );
  }
}
