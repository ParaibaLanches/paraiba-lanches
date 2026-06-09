import '../../../../core/errors/failures.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../entities/order_entity.dart';

abstract class IOrderRepository {
  Future<Result<OrderEntity>> createOrder({
    required List<CartItemEntity> items,
    required String paymentMethod,
    required double paymentAmount,
    String orderType = 'local',
    String notes = '',
    double deliveryFee = 0,
    double discountAmount = 0,
  });

  Future<Result<List<OrderEntity>>> getMyOrders();

  Future<Result<OrderEntity>> getOrderById(int id);

  Future<Result<double>> calculateDeliveryFee(String destination);
}
