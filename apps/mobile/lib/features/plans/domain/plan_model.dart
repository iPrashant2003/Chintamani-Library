class MembershipPlan {
  final String id;
  final String branchId;
  final String name;
  final int durationDays;
  final double price;
  final bool includesSeat;
  final bool includesLocker;
  final bool isActive;

  const MembershipPlan({
    required this.id,
    required this.branchId,
    required this.name,
    required this.durationDays,
    required this.price,
    this.includesSeat = true,
    this.includesLocker = false,
    this.isActive = true,
  });

  factory MembershipPlan.fromJson(Map<String, dynamic> json) {
    return MembershipPlan(
      id: json['id'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 30,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      includesSeat: json['includesSeat'] as bool? ?? true,
      includesLocker: json['includesLocker'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branchId': branchId,
      'name': name,
      'durationDays': durationDays,
      'price': price,
      'includesSeat': includesSeat,
      'includesLocker': includesLocker,
      'isActive': isActive,
    };
  }

  MembershipPlan copyWith({
    String? id,
    String? branchId,
    String? name,
    int? durationDays,
    double? price,
    bool? includesSeat,
    bool? includesLocker,
    bool? isActive,
  }) {
    return MembershipPlan(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      name: name ?? this.name,
      durationDays: durationDays ?? this.durationDays,
      price: price ?? this.price,
      includesSeat: includesSeat ?? this.includesSeat,
      includesLocker: includesLocker ?? this.includesLocker,
      isActive: isActive ?? this.isActive,
    );
  }
}
