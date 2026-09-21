class TenantInfo {
  final String id;
  final String name;
  final String code;
  final String slug;
  final String? logo;
  final String? phone;
  final String? email;
  final String? city;
  final String? state;
  final String? country;
  final String? plan;

  const TenantInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.slug,
    this.logo,
    this.phone,
    this.email,
    this.city,
    this.state,
    this.country,
    this.plan,
  });

  factory TenantInfo.fromJson(Map<String, dynamic> json) {
    return TenantInfo(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      logo: json['logo']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString() ?? 'India',
      plan: json['plan']?.toString() ?? 'STANDARD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'slug': slug,
      'logo': logo,
      'phone': phone,
      'email': email,
      'city': city,
      'state': state,
      'country': country,
      'plan': plan,
    };
  }

  String get initials {
    if (name.isEmpty) return 'LIB';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 3 ? 3 : parts[0].length).toUpperCase();
    }
    return parts.take(2).map((p) => p[0]).join().toUpperCase();
  }
}
