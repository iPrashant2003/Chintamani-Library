class RegistrationModel {
  final String id;
  final String applicationId;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? photoUrl;
  final String? aadhaarFrontUrl;
  final String? planId;
  final String? planName;
  final double? planPrice;
  final String status; // PENDING, APPROVED, REJECTED
  final String? rejectionReason;
  final String? reservedSeatNumber;
  final String? branchId;
  final String? branchName;
  final DateTime submittedAt;
  final DateTime? reviewedAt;

  const RegistrationModel({
    required this.id,
    required this.applicationId,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.photoUrl,
    this.aadhaarFrontUrl,
    this.planId,
    this.planName,
    this.planPrice,
    required this.status,
    this.rejectionReason,
    this.reservedSeatNumber,
    this.branchId,
    this.branchName,
    required this.submittedAt,
    this.reviewedAt,
  });

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      id: json['id'] as String,
      applicationId: json['applicationId'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      address: json['address'] as String?,
      photoUrl: json['photoUrl'] as String?,
      aadhaarFrontUrl: json['aadhaarFrontUrl'] as String?,
      planId: json['planId'] as String?,
      planName: json['plan']?['name'] as String?,
      planPrice: (json['plan']?['price'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'PENDING',
      rejectionReason: json['rejectionReason'] as String?,
      reservedSeatNumber: json['reservedSeat']?['seatNumber'] as String?,
      branchId: json['branchId'] as String? ?? json['branch']?['id'] as String?,
      branchName: json['branch']?['name'] as String?,
      submittedAt: DateTime.tryParse(json['submittedAt'] as String? ?? '') ?? DateTime.now(),
      reviewedAt: json['reviewedAt'] != null ? DateTime.tryParse(json['reviewedAt'] as String) : null,
    );
  }
}
