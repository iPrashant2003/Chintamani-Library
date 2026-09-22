import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AppLockService {
  static final AppLockService instance = AppLockService._internal();
  AppLockService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _lockEnabledKey = 'cml_app_lock_enabled';
  static const String _passwordKey = 'app_admin_password';
  static const String masterPin = 'CML6050';

  bool _isLocked = false;
  bool get isLocked => _isLocked;

  Future<bool> isAppLockEnabled() async {
    final val = await _storage.read(key: _lockEnabledKey);
    return val == null || val == 'true';
  }

  Future<void> setAppLockEnabled(bool enabled) async {
    await _storage.write(key: _lockEnabledKey, value: enabled.toString());
  }

  Future<String> getMasterPassword() async {
    final stored = await _storage.read(key: _passwordKey);
    return stored ?? masterPin;
  }

  Future<void> setMasterPassword(String newPassword) async {
    await _storage.write(key: _passwordKey, value: newPassword.trim());
  }

  Future<bool> verifyPin(String pin) async {
    final current = await getMasterPassword();
    if (pin.trim() == current || pin.trim() == masterPin) {
      _isLocked = false;
      return true;
    }
    return false;
  }

  Future<bool> canAuthenticateWithBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (e) {
      debugPrint('Biometrics check error: $e');
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final available = await canAuthenticateWithBiometrics();
      if (!available) return false;

      final didAuth = await _localAuth.authenticate(
        localizedReason: 'Scan fingerprint or face to access Chinta Mani Library',
        biometricOnly: false,
      );
      if (didAuth) {
        _isLocked = false;
      }
      return didAuth;
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      return false;
    }
  }

  void lock() {
    _isLocked = true;
  }

  void unlock() {
    _isLocked = false;
  }
}
