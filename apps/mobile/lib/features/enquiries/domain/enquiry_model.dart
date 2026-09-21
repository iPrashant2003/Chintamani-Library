class Enquiry {
  final String id;
  final String branchId;
  final String name;
  final String phone;
  final String? email;
  final String status; // NEW, CONTACTED, INTERESTED, CONVERTED, NOT_INTERESTED
  final DateTime? followUpDate;
  final String? notes;
  final DateTime createdAt;

  const Enquiry({
    required this.id,
    required this.branchId,
    required this.name,
    required this.phone,
    this.email,
    this.status = 'NEW',
    this.followUpDate,
    this.notes,
    required this.createdAt,
  });

  factory Enquiry.fromJson(Map<String, dynamic> json) {
    return Enquiry(
      id: json['id'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      status: json['status'] as String? ?? 'NEW',
      followUpDate: json['followUpDate'] != null
          ? DateTime.tryParse(json['followUpDate'].toString())
          : null,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branchId': branchId,
      'name': name,
      'phone': phone,
      'email': email,
      'status': status,
      'followUpDate': followUpDate?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static const List<String> statuses = [
    'NEW',
    'CONTACTED',
    'INTERESTED',
    'CONVERTED',
    'NOT_INTERESTED',
  ];
}
