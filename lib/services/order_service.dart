import '../core/constants/api_constants.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../core/network/api_service.dart';

class OrderService {
  final ApiService _api;

  OrderService(this._api);

  Future<Order> createOrder({
    required List<CartItem> items,
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
    return Order.fromJson(res['data']);
  }

  Future<List<Order>> getMyOrders() async {
    final res = await _api.get(ApiConstants.orders);
    if (res['success'] != true) {
      throw Exception(res['error'] ?? 'Erro ao buscar pedidos');
    }
    return (res['data'] as List).map((e) => Order.fromJson(e)).toList();
  }

  Future<Order> getOrderById(int id) async {
    final res = await _api.get('${ApiConstants.orders}/$id');
    if (res['success'] != true) {
      throw Exception(res['error'] ?? 'Erro ao buscar pedido');
    }
    return Order.fromJson(res['data']);
  }

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
