class Seat {
  final String id;
  final String seatNumber;
  final String floor;
  final String status; // AVAILABLE, OCCUPIED, RESERVED, MAINTENANCE
  final String branchId;
  final String? currentMemberName;
  final String? currentMemberId;
  final String? currentPlanName;

  const Seat({
    required this.id,
    required this.seatNumber,
    required this.floor,
    required this.status,
    required this.branchId,
    this.currentMemberName,
    this.currentMemberId,
    this.currentPlanName,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    String? memberName;
    String? memberId;
    String? planName;

    if (json['subscriptions'] is List && (json['subscriptions'] as List).isNotEmpty) {
      final sub = (json['subscriptions'] as List).first as Map<String, dynamic>;
      if (sub['member'] is Map) {
        memberName = sub['member']['name'] as String?;
        memberId = sub['member']['id'] as String?;
      }
      if (sub['plan'] is Map) {
        planName = sub['plan']['name'] as String?;
      }
    }

    return Seat(
      id: json['id'] as String? ?? '',
      seatNumber: json['seatNumber'] as String? ?? '',
      floor: json['floor'] as String? ?? 'A',
      status: json['status'] as String? ?? 'AVAILABLE',
      branchId: json['branchId'] as String? ?? '',
      currentMemberName: memberName ?? json['currentMemberName'] as String?,
      currentMemberId: memberId ?? json['currentMemberId'] as String?,
      currentPlanName: planName ?? json['currentPlanName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seatNumber': seatNumber,
      'floor': floor,
      'status': status,
      'branchId': branchId,
      'currentMemberName': currentMemberName,
      'currentMemberId': currentMemberId,
      'currentPlanName': currentPlanName,
    };
  }

  bool get isAvailable => status == 'AVAILABLE';
  bool get isOccupied => status == 'OCCUPIED';
  bool get isReserved => status == 'RESERVED';
  bool get isMaintenance => status == 'MAINTENANCE';
}
