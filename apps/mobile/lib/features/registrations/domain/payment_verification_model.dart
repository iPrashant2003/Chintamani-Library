class PaymentVerificationModel {
  final String id;
  final String paymentId;
  final String memberId;
  final String memberName;
  final String memberCode;
  final String memberPhone;
  final double amount;
  final String paymentType;
  final String? screenshotUrl;
  final String? txnRef;
  final String? upiId;
  final String status; // PENDING, APPROVED, REJECTED
  final String? rejectionReason;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final DateTime submittedAt;

  const PaymentVerificationModel({
    required this.id,
    required this.paymentId,
    required this.memberId,
    required this.memberName,
    required this.memberCode,
    required this.memberPhone,
    required this.amount,
    required this.paymentType,
    this.screenshotUrl,
    this.txnRef,
    this.upiId,
    required this.status,
    this.rejectionReason,
    this.verifiedBy,
    this.verifiedAt,
    required this.submittedAt,
  });

  factory PaymentVerificationModel.fromJson(Map<String, dynamic> json) {
    final member = json['member'] as Map<String, dynamic>? ?? {};
    return PaymentVerificationModel(
      id: json['id'] as String,
      paymentId: json['paymentId'] as String,
      memberId: json['memberId'] as String,
      memberName: member['name'] as String? ?? 'Unknown Member',
      memberCode: member['memberCode'] as String? ?? '-',
      memberPhone: member['phone'] as String? ?? '-',
      amount: (json['amount'] as num? ?? 0).toDouble(),
      paymentType: json['paymentType'] as String? ?? 'MEMBERSHIP',
      screenshotUrl: json['screenshotUrl'] as String?,
      txnRef: json['txnRef'] as String?,
      upiId: json['upiId'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      rejectionReason: json['rejectionReason'] as String?,
      verifiedBy: json['verifiedBy'] as String?,
      verifiedAt: json['verifiedAt'] != null ? DateTime.tryParse(json['verifiedAt'] as String) : null,
      submittedAt: DateTime.tryParse(json['submittedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
