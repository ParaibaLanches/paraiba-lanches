import 'package:shared_preferences/shared_preferences.dart';

/// Centralizes all token persistence logic.
/// Single source of truth for access_token and refresh_token storage.
class TokenStorage {
  TokenStorage._();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, accessToken);
    await prefs.setString(_refreshKey, refreshToken);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
  }
}
