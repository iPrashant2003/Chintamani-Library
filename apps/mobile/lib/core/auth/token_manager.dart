import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final tokenManagerProvider = Provider<TokenManager>((ref) => TokenManager());

class TokenManager {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _refreshTokenKey = 'jwt_refresh_token';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<String?> getAccessToken() async => getToken();

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
}

