import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/storage/token_storage.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        } else {
          // Log only in debug mode to avoid cluttering production logs
          if (kDebugMode) {
            print('[API] Aviso: Token ausente para a rota: ${options.path}');
          }
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshToken = await TokenStorage.getRefreshToken();
          
          if (refreshToken != null) {
            try {
              // Create a clean Dio instance for refresh to avoid interceptor loop
              final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
              final res = await refreshDio.post(ApiConstants.refresh, data: {
                'refresh_token': refreshToken,
              });

              if (res.data['success'] == true) {
                final newAccessToken = res.data['data']['access_token'];
                final newRefreshToken = res.data['data']['refresh_token'];
                
                await TokenStorage.saveTokens(newAccessToken, newRefreshToken);

                // Retry original request with new token
                final opts = error.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newAccessToken';
                
                final retryRes = await _dio.fetch(opts);
                return handler.resolve(retryRes);
              }
            } catch (e) {
              // Refresh failed
              await TokenStorage.clearTokens();
            }
          } else {
            // No refresh token available
            await TokenStorage.clearTokens();
          }
        }
        return handler.next(error);
      },
    ));

    // Logger interceptor SHOULD BE LAST to see manipulated headers
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(path, queryParameters: params);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
      throw Exception('Falha na conexão com o servidor [${e.requestOptions.path}]. Verifique se o backend está rodando e reinicie se necessário.');
    }

    // Repassa os erros de regra de negócio do back-end ou fallback
    String msg = e.response?.data?['error'] ?? 'Erro de rede em: ${e.requestOptions.path}';

    // Mapeamento de mensagens "fofas"
    final friendlyMessages = {
      'credenciais invalidas': 'Ops! O e-mail ou a senha estão incorretos. 🍔',
      'muitas tentativas invalidas. conta bloqueada temporariamente':
          'Muitas tentativas! Que tal respirar um pouco e tentar daqui a pouco? ⏳',
      'email ja cadastrado': 'Esse e-mail já faz parte da nossa família! ❤️',
      'usuario nao encontrado': 'Não encontramos você por aqui... Que tal se cadastrar? ✨',
      'senha atual incorreta': 'A senha atual não confere, vamos tentar de novo? 📝',
      'token invalido ou expirado': 'Ops! Sua sessão expirou. Que tal entrar de novo? 🔑',
      'pedido deve conter ao menos um item': 'Seu carrinho está vazio! Vamos escolher algo gostoso? 🛒',
      'metodo de pagamento invalido': 'Ops! Esse meio de pagamento não está disponível agora. 💳',
      'restaurante nao esta aceitando pedidos': 'O restaurante está descansando agora. Volte em breve! 😴',
    };

    final normalizedMsg = msg
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ã', 'a')
        .replaceAll('õ', 'o')
        .replaceAll('ç', 'c');

    if (friendlyMessages.containsKey(normalizedMsg)) {
      msg = friendlyMessages[normalizedMsg]!;
    }

    throw Exception(msg);
  }
}

