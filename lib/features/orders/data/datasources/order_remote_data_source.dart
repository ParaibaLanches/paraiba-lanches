import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../models/order_model.dart';

abstract class IOrderRemoteDataSource {
  Future<OrderModel> createOrder({
    required List<CartItemEntity> items,
    required String paymentMethod,
    required double paymentAmount,
    String orderType = 'local',
    String notes = '',
    double deliveryFee = 0,
    double discountAmount = 0,
  });

  Future<List<OrderModel>> getMyOrders();
  Future<OrderModel> getOrderById(int id);
  Future<double> calculateDeliveryFee(String destination);
}

class OrderRemoteDataSource implements IOrderRemoteDataSource {
  final ApiService _api;

  OrderRemoteDataSource(this._api);

  @override
  Future<OrderModel> createOrder({
    required List<CartItemEntity> items,
    required String paymentMethod,
    required double paymentAmount,
    String orderType = 'local',
    String notes = '',
    double deliveryFee = 0,
    double discountAmount = 0,
  }) async {
    final res = await _api.post(
      ApiConstants.orders,
      data: {
        'order_type': orderType,
        'notes': notes,
        'delivery_fee': deliveryFee,
        'discount_amount': discountAmount,
        'items': items
            .map(
              (i) => {
                'product_id': i.product.id,
                'quantity': i.quantity,
                'notes': i.notes,
              },
            )
            .toList(),
        'payments': [
          {'method': paymentMethod, 'amount': paymentAmount},
        ],
      },
    );
    if (res['success'] != true) {
      throw Exception(res['error'] ?? 'Erro ao criar pedido');
    }
    return OrderModel.fromJson(res['data']);
  }

  @override
  Future<List<OrderModel>> getMyOrders() async {
    final res = await _api.get(ApiConstants.orders);
    if (res['success'] != true) {
      throw Exception(res['error'] ?? 'Erro ao buscar pedidos');
    }
    return (res['data'] as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  @override
  Future<OrderModel> getOrderById(int id) async {
    final res = await _api.get('${ApiConstants.orders}/$id');
    if (res['success'] != true) {
      throw Exception(res['error'] ?? 'Erro ao buscar pedido');
    }
    return OrderModel.fromJson(res['data']);
  }

  @override
  Future<double> calculateDeliveryFee(String destination) async {
    final res = await _api.get(
      ApiConstants.calculateDelivery,
      params: {'destination': destination},
    );

    if (res['success'] != true) {
      throw Exception(res['error'] ?? 'Erro ao calcular frete');
    }

    final data = res['data'];
    if (data is Map) {
      return (data['fee'] as num).toDouble();
    }

    return (data as num).toDouble();
  }
}
