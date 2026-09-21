import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chintamani_library/core/api/api_client.dart';
import 'package:chintamani_library/core/api/api_endpoints.dart';
import '../domain/auth_models.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(apiClientProvider));
});

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<LoginResponse> login(String email, String password) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    final data = response.data is Map && response.data['data'] != null
        ? response.data['data']
        : response.data;
    return LoginResponse.fromJson(data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } catch (_) {}
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _apiClient.dio.post(ApiEndpoints.forgotPassword, data: {'email': email});
    } catch (_) {}
  }

  Future<void> resetPassword(String token, String password) async {
    try {
      await _apiClient.dio.post(ApiEndpoints.resetPassword, data: {'token': token, 'password': password});
    } catch (_) {}
  }
}
