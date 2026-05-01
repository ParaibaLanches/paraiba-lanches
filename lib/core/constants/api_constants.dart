import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080';
  static String get wsUrl =>
      dotenv.env['WS_URL'] ?? 'ws://10.0.2.2:8080/ws/orders';

  // Auth
  static const login = '/api/customer/login';
  static const register = '/api/customer/register';
  static const profile = '/api/customer/profile';
  static const updateAvatar = '/api/customer/profile/image';
  static const refresh = '/api/auth/refresh';

  // Menu
  static const home = '/api/customer/home';
  static const menu = '/api/customer/menu';

  // Orders
  static const orders = '/api/customer/orders';
  static const calculateDelivery = '/api/customer/calculate-delivery';

  // Coupons
  static const coupons = '/api/customer/coupons';
  static const validateCoupon = '/api/customer/coupons/validate';
  static const appInfo = '/api/customer/app-info';

  static const products = '/api/products';
  static const categories = '/api/categories';

  static String? getImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;

    // Remove leading slash if present to avoid double slashes
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl/$cleanPath';
  }
}
