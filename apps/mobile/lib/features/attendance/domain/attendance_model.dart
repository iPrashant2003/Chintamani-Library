class Attendance {
  final String id;
  final String memberId;
  final String branchId;
  final DateTime checkIn;
  final DateTime? checkOut;
  final String method; // MANUAL, QR
  final String? memberName;
  final String? memberCode;

  const Attendance({
    required this.id,
    required this.memberId,
    required this.branchId,
    required this.checkIn,
    this.checkOut,
    this.method = 'MANUAL',
    this.memberName,
    this.memberCode,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    String? name;
    String? code;
    if (json['member'] is Map) {
      name = json['member']['name'] as String?;
      code = json['member']['memberCode'] as String?;
    }

    return Attendance(
      id: json['id'] as String? ?? '',
      memberId: json['memberId'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      checkIn: json['checkIn'] != null
          ? DateTime.tryParse(json['checkIn'].toString()) ?? DateTime.now()
          : DateTime.now(),
      checkOut: json['checkOut'] != null
          ? DateTime.tryParse(json['checkOut'].toString())
          : null,
      method: json['method'] as String? ?? 'MANUAL',
      memberName: name ?? json['memberName'] as String?,
      memberCode: code ?? json['memberCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'branchId': branchId,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'method': method,
      'memberName': memberName,
      'memberCode': memberCode,
    };
  }

  bool get isCurrentlyInside => checkOut == null;
}
