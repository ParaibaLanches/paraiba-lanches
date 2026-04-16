import '../core/constants/api_constants.dart';
import '../models/coupon.dart';
import 'api_service.dart';

class CouponService {
  final ApiService _api;

  CouponService(this._api);

  /// Fetches the list of active coupons assigned to the current customer.
  Future<List<Coupon>> getMyCoupons() async {
    final res = await _api.get(ApiConstants.coupons);
    if (res['success'] != true) throw Exception(res['error'] ?? 'Erro ao buscar cupons');
    
    return (res['data'] as List)
        .map((e) => Coupon.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Validates a coupon code for the items in the current basket.
  Future<Coupon> validateCoupon(String code) async {
    final res = await _api.post(ApiConstants.validateCoupon, data: {
      'code': code.toUpperCase(),
    });

    if (res['success'] != true) {
      throw Exception(res['error'] ?? 'Cupom inválido ou expirado');
    }

    return Coupon.fromJson(res['data'] as Map<String, dynamic>);
  }
}
