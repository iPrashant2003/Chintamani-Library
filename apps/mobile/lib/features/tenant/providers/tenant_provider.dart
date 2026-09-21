import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:chintamani_library/core/models/tenant_model.dart';
import 'package:chintamani_library/core/api/api_client.dart';

final activeTenantProvider = StateNotifierProvider<ActiveTenantNotifier, TenantInfo?>((ref) {
  return ActiveTenantNotifier(ref);
});

class ActiveTenantNotifier extends StateNotifier<TenantInfo?> {
  final Ref _ref;
  static const _storageKey = 'active_tenant_data';
  final _storage = const FlutterSecureStorage();

  static const defaultTenant = TenantInfo(
    id: 'chintamani-tenant',
    name: 'Chinta Mani Library',
    code: 'CML',
    slug: 'chintamani-library',
    phone: '+91 9876543210',
    email: 'contact@chintamanilibrary.com',
    city: 'Sant Kabir Nagar',
    state: 'Uttar Pradesh',
    country: 'India',
    plan: 'OFFICIAL',
  );

  ActiveTenantNotifier(this._ref) : super(defaultTenant) {
    loadSavedTenant();
  }

  Future<void> loadSavedTenant() async {
    try {
      final data = await _storage.read(key: _storageKey);
      if (data != null) {
        state = TenantInfo.fromJson(jsonDecode(data) as Map<String, dynamic>);
      } else {
        state = defaultTenant;
      }
    } catch (_) {
      state = defaultTenant;
    }
  }

  Future<void> setTenant(TenantInfo tenant) async {
    state = tenant;
    try {
      await _storage.write(key: _storageKey, value: jsonEncode(tenant.toJson()));
    } catch (_) {}
  }

  Future<void> clearTenant() async {
    state = defaultTenant;
  }

  Future<TenantInfo?> lookupByCode(String code) async {
    try {
      final client = _ref.read(apiClientProvider);
      final response = await client.dio.get('/tenants/by-code/$code');
      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;
      final info = TenantInfo.fromJson(data as Map<String, dynamic>);
      return info;
    } catch (_) {
      return defaultTenant;
    }
  }
}
