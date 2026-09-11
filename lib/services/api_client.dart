import 'package:dio/dio.dart';
import '../config/env.dart';
import 'api_exceptions.dart';

/// Cliente Dio singleton con interceptores para Bearer token y manejo de errores
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio _dio;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://back-challenge.ideasconluzpropia.com.ar',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Interceptor para agregar Bearer token a todos los requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = Env.apiToken;
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Convertir DioException a nuestras excepciones custom
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: NetworkException('Tiempo de espera agotado'),
              ),
            );
          }

          if (error.type == DioExceptionType.connectionError) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: NetworkException('Error de conexión'),
              ),
            );
          }

          if (error.response != null) {
            final statusCode = error.response!.statusCode ?? 0;
            final data = error.response!.data;
            
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                error: ApiException.fromResponse(statusCode, data),
              ),
            );
          }

          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: NetworkException(error.message ?? 'Error de conexión'),
            ),
          );
        },
      ),
    );
  }

  Dio get dio => _dio;
}
