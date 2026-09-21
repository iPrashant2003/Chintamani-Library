import 'package:chintamani_library/core/models/tenant_model.dart';

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? tenantId;
  final List<String> branchIds;
  final String? phone;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.tenantId,
    required this.branchIds,
    this.phone,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'STAFF',
      tenantId: json['tenantId'] as String?,
      branchIds: (json['branchIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['branches'] as List<dynamic>?)
              ?.map((e) => (e is Map ? e['branchId']?.toString() : e.toString()) ?? '')
              .where((s) => s.isNotEmpty)
              .toList() ??
          const [],
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'tenantId': tenantId,
      'branchIds': branchIds,
      'phone': phone,
    };
  }

  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? tenantId,
    List<String>? branchIds,
    String? phone,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      tenantId: tenantId ?? this.tenantId,
      branchIds: branchIds ?? this.branchIds,
      phone: phone ?? this.phone,
    );
  }

  bool get isOwner => role == 'OWNER';
  bool get isAdmin => role == 'ADMIN' || role == 'OWNER';
  bool get isSuperAdmin => role == 'SUPER_ADMIN';
}

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final AuthUser user;
  final TenantInfo? tenant;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.tenant,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      tenant: json['tenant'] != null
          ? TenantInfo.fromJson(json['tenant'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
      'tenant': tenant?.toJson(),
    };
  }
}
