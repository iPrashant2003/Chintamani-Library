import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final tokenManagerProvider = Provider<TokenManager>((ref) => TokenManager());

class TokenManager {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _tokenKey = 'jwt_token';
  static const _refreshTokenKey = 'jwt_refresh_token';

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey).timeout(const Duration(seconds: 2));
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey).timeout(const Duration(seconds: 2));
    } catch (_) {}
  }

  Future<String?> getAccessToken() async => getToken();

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    try {
      await _storage.write(key: _tokenKey, value: accessToken).timeout(const Duration(seconds: 3));
      if (refreshToken != null) {
        await _storage.write(key: _refreshTokenKey, value: refreshToken).timeout(const Duration(seconds: 3));
      }
    } catch (_) {}
  }

  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _tokenKey).timeout(const Duration(seconds: 2));
      await _storage.delete(key: _refreshTokenKey).timeout(const Duration(seconds: 2));
    } catch (_) {}
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey).timeout(const Duration(seconds: 2));
    } catch (_) {
      return null;
    }
  }

  // ── Custom App Password (changeable by admin) ────────────────────────────
  static const _appPasswordKey = 'app_admin_password';
  static const _defaultPassword = 'CML6050';

  Future<String> getAppPassword() async {
    try {
      final stored = await _storage.read(key: _appPasswordKey).timeout(const Duration(seconds: 2));
      return stored ?? _defaultPassword;
    } catch (_) {
      return _defaultPassword;
    }
  }

  Future<void> saveAppPassword(String newPassword) async {
    try {
      await _storage.write(key: _appPasswordKey, value: newPassword).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }
}
