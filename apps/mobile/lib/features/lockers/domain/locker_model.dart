class Locker {
  final String id;
  final String lockerNumber;
  final String status; // AVAILABLE, OCCUPIED, RESERVED, MAINTENANCE
  final String branchId;
  final String? currentMemberName;
  final String? currentMemberId;

  const Locker({
    required this.id,
    required this.lockerNumber,
    required this.status,
    required this.branchId,
    this.currentMemberName,
    this.currentMemberId,
  });

  factory Locker.fromJson(Map<String, dynamic> json) {
    String? memberName;
    String? memberId;

    if (json['subscriptions'] is List && (json['subscriptions'] as List).isNotEmpty) {
      final sub = (json['subscriptions'] as List).first as Map<String, dynamic>;
      if (sub['member'] is Map) {
        memberName = sub['member']['name'] as String?;
        memberId = sub['member']['id'] as String?;
      }
    }
    memberName ??= json['currentMemberName'] as String?;
    memberId ??= json['currentMemberId'] as String?;

    String status = json['status'] as String? ?? 'AVAILABLE';
    final hasActiveMember = memberName != null && memberName.trim().isNotEmpty;
    if (status == 'OCCUPIED' && !hasActiveMember) {
      status = 'AVAILABLE';
    }

    return Locker(
      id: json['id'] as String? ?? '',
      lockerNumber: json['lockerNumber'] as String? ?? '',
      status: status,
      branchId: json['branchId'] as String? ?? '',
      currentMemberName: memberName,
      currentMemberId: memberId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lockerNumber': lockerNumber,
      'status': status,
      'branchId': branchId,
      'currentMemberName': currentMemberName,
      'currentMemberId': currentMemberId,
    };
  }

  bool get isAvailable => status == 'AVAILABLE';
  bool get isOccupied => status == 'OCCUPIED';
  bool get isReserved => status == 'RESERVED';
}
