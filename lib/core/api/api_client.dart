import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';
import 'api_log_interceptor.dart';
import 'mock_api_interceptor.dart';

class ApiClient {
  final Dio dio;

  ApiClient({required this.dio});

  static ApiClient create({bool enableMockFallback = true, bool enableLogging = true}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Auth & Token Injection Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // If unauthorized, could notify auth provider or clear tokens
          return handler.next(e);
        },
      ),
    );

    // Formatted API Logging Interceptor (prints request/response/error details & keeps history)
    if (enableLogging) {
      dio.interceptors.add(ApiLogInterceptor());
    }

    // Enable Mock Fallback Interceptor so Invox works seamlessly offline/standalone
    if (enableMockFallback) {
      dio.interceptors.add(MockApiInterceptor());
    }

    return ApiClient(dio: dio);
  }

  /// Convenience GET request wrapper with unified exception handling
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Convenience POST request wrapper with unified exception handling
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}
