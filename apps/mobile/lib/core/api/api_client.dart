import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/token_manager.dart';
import 'api_endpoints.dart';
import '../error/app_exception.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref));

class ApiClient {
  final Ref _ref;
  late final Dio dio;

  ApiClient(this._ref) {
    dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
    ));

    // Configure SSL bypass on mobile to prevent carrier interception handshake errors
    if (!kIsWeb) {
      try {
        final adapter = dio.httpClientAdapter;
        if (adapter is IOHttpClientAdapter) {
          adapter.createHttpClient = () {
            final client = HttpClient();
            client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
            return client;
          };
        }
      } catch (_) {}
    }

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers['Bypass-Tunnel-Reminder'] = 'true';
        final token = await _ref.read(tokenManagerProvider).getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Token refresh logic would go here
        }
        final exception = _mapException(e);
        return handler.reject(DioException(requestOptions: e.requestOptions, error: exception));
      },
    ));
    
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  AppException _mapException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout || e.type == DioExceptionType.connectionError) {
      return const NetworkException('Network error, please check your connection');
    }
    if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
      return const AuthException('Authentication failed');
    }
    if (e.response?.statusCode == 404) {
      return const NotFoundException('Resource not found');
    }
    if (e.response?.statusCode == 422 || e.response?.statusCode == 400) {
      return ValidationException(e.response?.data['message'] ?? 'Validation failed');
    }
    return ServerException(e.response?.data['message'] ?? 'An unexpected error occurred');
  }
}
