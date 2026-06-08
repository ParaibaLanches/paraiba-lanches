import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000';
  static String get sseUrl =>
      dotenv.env['SSE_URL'] ?? 'http://10.0.2.2:3000/api/customer/stream/orders';

  // Auth
  static const login = '/api/customer/auth/login';
  static const register = '/api/customer/auth/register';
  static const profile = '/api/customer/profile';
  static const updateAvatar = '/api/customer/profile';
  static const refresh = '/api/customer/auth/login'; // No refresh implemented yet

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
