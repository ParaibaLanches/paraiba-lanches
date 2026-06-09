import '../../../../core/errors/failures.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/i_order_repository.dart';
import '../datasources/order_remote_data_source.dart';

class OrderRepositoryImpl implements IOrderRepository {
  final IOrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<OrderEntity>> createOrder({
    required List<CartItemEntity> items,
    required String paymentMethod,
    required double paymentAmount,
    String orderType = 'local',
    String notes = '',
    double deliveryFee = 0,
    double discountAmount = 0,
  }) async {
    try {
      final result = await remoteDataSource.createOrder(
        items: items,
        paymentMethod: paymentMethod,
        paymentAmount: paymentAmount,
        orderType: orderType,
        notes: notes,
        deliveryFee: deliveryFee,
        discountAmount: discountAmount,
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<OrderEntity>>> getMyOrders() async {
    try {
      final result = await remoteDataSource.getMyOrders();
      return Result.success(result);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<OrderEntity>> getOrderById(int id) async {
    try {
      final result = await remoteDataSource.getOrderById(id);
      return Result.success(result);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<double>> calculateDeliveryFee(String destination) async {
    try {
      final result = await remoteDataSource.calculateDeliveryFee(destination);
      return Result.success(result);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
