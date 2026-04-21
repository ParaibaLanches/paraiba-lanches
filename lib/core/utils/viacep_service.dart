import 'package:dio/dio.dart';

class ViaCepService {
  static final _dio = Dio(BaseOptions(
    baseUrl: 'https://viacep.com.br/ws/',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  static Future<Map<String, dynamic>?> fetchCep(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'\D'), '');
    if (cleanCep.length != 8) return null;

    try {
      final response = await _dio.get('$cleanCep/json/');
      if (response.data == null || response.data['erro'] == true) {
        return null;
      }
      return response.data as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
