import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chintamani_library/core/auth/token_manager.dart';
import 'package:chintamani_library/features/tenant/providers/tenant_provider.dart';
import 'package:chintamani_library/core/models/tenant_model.dart';
import '../data/auth_repository.dart';
import '../domain/auth_models.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthAuthenticated extends AuthState {
  final AuthUser user;
  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AsyncData(AuthInitial())) {
    _checkStatus();
  }

  // Official Two Admin Profiles
  static const AuthUser adminManglesh = AuthUser(
    id: 'cml-manglesh-9415919277',
    name: 'Manglesh Mani Tripathi',
    email: 'manglesh@chintamanilibrary.com',
    role: 'OWNER / DIRECTOR',
    branchIds: ['chintamani-khalilabad', 'chintamani-mehdawal'],
    phone: '9415919277',
  );

  static const AuthUser adminDesk = AuthUser(
    id: 'cml-admin-7388389944',
    name: 'Chinta Mani Administrator',
    email: 'admin@chintamanilibrary.com',
    role: 'ADMINISTRATOR',
    branchIds: ['chintamani-khalilabad', 'chintamani-mehdawal'],
    phone: '7388389944',
  );

  Future<void> _checkStatus() async {
    final token = await _ref.read(tokenManagerProvider).getAccessToken();
    // Keep user logged in persistently so it does not ask for password every time,
    // UNLESS the user has explicitly signed out (token is null or empty).
    if (token != null && token.isNotEmpty) {
      if (token.contains('7388389944')) {
        state = const AsyncData(AuthAuthenticated(adminDesk));
      } else {
        state = const AsyncData(AuthAuthenticated(adminManglesh));
      }
    } else {
      state = const AsyncData(AuthUnauthenticated());
    }
  }

  Future<bool> login(String loginId, String password, {bool forceDemo = false}) async {
    state = const AsyncLoading();

    final cleanId = loginId.trim().replaceAll(RegExp(r'[^\d]'), '');
    final cleanPass = password.trim();

    // Load the current app password (may be custom or default CML6050)
    final currentPassword = await _ref.read(tokenManagerProvider).getAppPassword();

    if (cleanPass == currentPassword || forceDemo) {
      if (cleanId == '9415919277' || loginId.contains('9415919277') || (forceDemo && cleanId.isEmpty)) {
        await _ref.read(tokenManagerProvider).saveTokens(
          accessToken: 'cml-session-9415919277',
          refreshToken: 'cml-refresh-9415919277',
        );
        state = const AsyncData(AuthAuthenticated(adminManglesh));
        return true;
      } else if (cleanId == '7388389944' || loginId.contains('7388389944')) {
        await _ref.read(tokenManagerProvider).saveTokens(
          accessToken: 'cml-session-7388389944',
          refreshToken: 'cml-refresh-7388389944',
        );
        state = const AsyncData(AuthAuthenticated(adminDesk));
        return true;
      } else if (cleanId.isEmpty && forceDemo) {
        // fallback for demo tap with no ID
        await _ref.read(tokenManagerProvider).saveTokens(
          accessToken: 'cml-session-7388389944',
          refreshToken: 'cml-refresh-7388389944',
        );
        state = const AsyncData(AuthAuthenticated(adminDesk));
        return true;
      }
    }

    // Invalid credentials
    state = const AsyncData(AuthUnauthenticated());
    return false;
  }

  /// Change admin password — validates old password, saves new one persistently
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final currentPassword = await _ref.read(tokenManagerProvider).getAppPassword();
    if (oldPassword.trim() != currentPassword) return false;
    await _ref.read(tokenManagerProvider).saveAppPassword(newPassword.trim());
    return true;
  }

  Future<void> signup({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? branch,
  }) async {
    state = const AsyncLoading();

    await _ref.read(tokenManagerProvider).saveTokens(
      accessToken: 'cml-session-7388389944',
      refreshToken: 'cml-refresh-7388389944',
    );

    final user = AuthUser(
      id: 'cml-user-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Chinta Mani Scholar' : name.trim(),
      email: email.trim().isEmpty ? 'scholar@chintamanilibrary.com' : email.trim(),
      role: 'SCHOLAR',
      branchIds: ['chintamani-khalilabad', 'chintamani-mehdawal'],
      phone: phone.trim(),
    );

    state = AsyncData(AuthAuthenticated(user));
  }

  Future<void> logout() async {
    await _ref.read(tokenManagerProvider).clearTokens();
    state = const AsyncData(AuthUnauthenticated());
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>((ref) {
  return AuthNotifier(ref);
});
