import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(this._tokenStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final TokenStorage _tokenStorage;
  late final Dio _dio;

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _request(() => _dio.get<dynamic>(path));
    return _responseMap(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
  }) async {
    final response = await _request(() => _dio.post<dynamic>(path, data: data));
    return _responseMap(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    dynamic data,
  }) async {
    final response = await _request(() => _dio.put<dynamic>(path, data: data));
    return _responseMap(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final response = await _request(() => _dio.delete<dynamic>(path));
    return _responseMap(response);
  }

  Future<Response<dynamic>> _request(
    Future<Response<dynamic>> Function() call,
  ) async {
    try {
      return await call();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Map<String, dynamic> _responseMap(Response<dynamic> response) {
    final data = response.data;

    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw ApiException.unexpectedResponse(response.statusCode);
  }
}
