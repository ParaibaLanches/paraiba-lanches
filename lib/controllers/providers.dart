import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/coupon_service.dart';
import '../services/menu_service.dart';
import '../services/order_service.dart';
import '../services/settings_service.dart';
import '../services/websocket_service.dart';
import '../models/app_info.dart';

// Services
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(apiServiceProvider));
});

final menuServiceProvider = Provider<MenuService>((ref) {
  return MenuService(ref.read(apiServiceProvider));
});

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(ref.read(apiServiceProvider));
});

final couponServiceProvider = Provider<CouponService>((ref) {
  return CouponService(ref.read(apiServiceProvider));
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService(ref.read(apiServiceProvider));
});

final appInfoProvider = FutureProvider<AppInfo>((ref) async {
  return ref.read(settingsServiceProvider).getAppInfo();
});

final wsServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(service.dispose);
  return service;
});
