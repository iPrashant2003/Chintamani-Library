import 'dart:convert';
import '../../seats/domain/seat_model.dart';
import '../../lockers/domain/locker_model.dart';
import '../../plans/domain/plan_model.dart';

class Member {
  final String id;
  final String memberCode;
  final String name;
  final String? fatherName;
  final String? phone;
  final String? email;
  final String? address;
  final String? gender;
  final DateTime? dob;
  final String? photoUrl;
  final String? institute;
  final String? course;
  final String? batch;
  final String? emergencyContact;
  final String? aadhaar;
  final String? notes;
  final String branchId;
  final bool isActive;
  final List<Subscription> subscriptions;

  const Member({
    required this.id,
    required this.memberCode,
    required this.name,
    this.fatherName,
    this.phone,
    this.email,
    this.address,
    this.gender,
    this.dob,
    this.photoUrl,
    this.institute,
    this.course,
    this.batch,
    this.emergencyContact,
    this.aadhaar,
    this.notes,
    required this.branchId,
    required this.isActive,
    this.subscriptions = const [],
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> academicData = {};
    if (json['academicInfo'] != null) {
      if (json['academicInfo'] is String) {
        try {
          academicData = jsonDecode(json['academicInfo'] as String) as Map<String, dynamic>;
        } catch (_) {}
      } else if (json['academicInfo'] is Map) {
        academicData = json['academicInfo'] as Map<String, dynamic>;
      }
    }

    final subsList = (json['subscriptions'] as List<dynamic>?)
            ?.map((e) => Subscription.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];

    return Member(
      id: json['id'] as String? ?? '',
      memberCode: json['memberCode'] as String? ?? '',
      name: json['name'] as String? ?? '',
      fatherName: json['fatherName'] as String? ?? academicData['fatherName'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      gender: json['gender'] as String? ?? academicData['gender'] as String?,
      dob: json['dob'] != null ? DateTime.tryParse(json['dob'].toString()) : null,
      photoUrl: json['photoUrl'] as String? ?? academicData['photoUrl'] as String?,
      institute: json['institute'] as String? ?? academicData['institute'] as String?,
      course: json['course'] as String? ?? academicData['course'] as String?,
      batch: json['batch'] as String? ?? academicData['batch'] as String?,
      emergencyContact: json['emergencyContact'] as String? ?? academicData['emergencyContact'] as String?,
      aadhaar: json['aadhaar'] as String? ?? academicData['aadhaar'] as String?,
      notes: json['notes'] as String? ?? academicData['notes'] as String?,
      branchId: json['branchId'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      subscriptions: subsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberCode': memberCode,
      'name': name,
      'fatherName': fatherName,
      'phone': phone,
      'email': email,
      'address': address,
      'gender': gender,
      'dob': dob?.toIso8601String(),
      'photoUrl': photoUrl,
      'institute': institute,
      'course': course,
      'batch': batch,
      'emergencyContact': emergencyContact,
      'aadhaar': aadhaar,
      'notes': notes,
      'branchId': branchId,
      'isActive': isActive,
    };
  }

  Subscription? get activeSubscription {
    try {
      return subscriptions.firstWhere((s) => s.isActive);
    } catch (_) {
      return subscriptions.isNotEmpty ? subscriptions.first : null;
    }
  }

  String get currentPlanName => activeSubscription?.plan?.name ?? 'No Plan';
  String? get currentSeatNumber => activeSubscription?.seat?.seatNumber;
  String? get currentLockerNumber => activeSubscription?.locker?.lockerNumber;

  int? get daysRemaining {
    final sub = activeSubscription;
    if (sub == null) return null;
    final diff = sub.endDate.difference(DateTime.now()).inDays;
    return diff >= 0 ? diff : 0;
  }
}

class Subscription {
  final String id;
  final String memberId;
  final String planId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String? assignedSeatId;
  final String? assignedLockerId;
  final MembershipPlan? plan;
  final Seat? seat;
  final Locker? locker;

  const Subscription({
    required this.id,
    required this.memberId,
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.assignedSeatId,
    this.assignedLockerId,
    this.plan,
    this.seat,
    this.locker,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String? ?? '',
      memberId: json['memberId'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: json['status'] as String? ?? 'ACTIVE',
      assignedSeatId: json['assignedSeatId'] as String?,
      assignedLockerId: json['assignedLockerId'] as String?,
      plan: json['plan'] is Map ? MembershipPlan.fromJson(json['plan'] as Map<String, dynamic>) : null,
      seat: json['seat'] is Map ? Seat.fromJson(json['seat'] as Map<String, dynamic>) : null,
      locker: json['locker'] is Map ? Locker.fromJson(json['locker'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'planId': planId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'assignedSeatId': assignedSeatId,
      'assignedLockerId': assignedLockerId,
    };
  }

  bool get isActive => status == 'ACTIVE' && endDate.isAfter(DateTime.now());
  bool get isExpired => status == 'EXPIRED' || endDate.isBefore(DateTime.now());
}
