class Payment {
  final String id;
  final String memberId;
  final double amount;
  final String method; // CASH, UPI, CARD, BANK, OTHER
  final String status; // PAID, PENDING, FAILED
  final String verificationStatus; // APPROVED, PENDING_VERIFICATION, DISAPPROVED
  final DateTime? paidAt;
  final DateTime? dueDate;
  final String? txnRef;
  final String? memberName;
  final String? memberCode;
  final String? memberPhone;
  final String? planName;

  const Payment({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.method,
    required this.status,
    this.verificationStatus = 'APPROVED',
    this.paidAt,
    this.dueDate,
    this.txnRef,
    this.memberName,
    this.memberCode,
    this.memberPhone,
    this.planName,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    String? name;
    String? code;
    String? phone;
    if (json['member'] is Map) {
      name = json['member']['name'] as String?;
      code = json['member']['memberCode'] as String?;
      phone = json['member']['phone'] as String?;
    }

    final rawStatus = json['status'] as String? ?? 'PAID';
    final rawVerif = json['verificationStatus'] as String? ??
        (rawStatus == 'PAID' ? 'APPROVED' : (rawStatus == 'PENDING' ? 'PENDING_VERIFICATION' : 'DISAPPROVED'));

    return Payment(
      id: json['id'] as String? ?? '',
      memberId: json['memberId'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      method: json['method'] as String? ?? 'UPI',
      status: rawStatus,
      verificationStatus: rawVerif,
      paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt'].toString()) : null,
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate'].toString()) : null,
      txnRef: json['txnRef'] as String?,
      memberName: name ?? json['memberName'] as String?,
      memberCode: code ?? json['memberCode'] as String?,
      memberPhone: phone ?? json['memberPhone'] as String? ?? json['phone'] as String?,
      planName: json['planName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'amount': amount,
      'method': method,
      'status': status,
      'verificationStatus': verificationStatus,
      'paidAt': paidAt?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'txnRef': txnRef,
      'memberName': memberName,
      'memberCode': memberCode,
      'memberPhone': memberPhone,
      'planName': planName,
    };
  }

  Payment copyWith({
    String? id,
    String? memberId,
    double? amount,
    String? method,
    String? status,
    String? verificationStatus,
    DateTime? paidAt,
    DateTime? dueDate,
    String? txnRef,
    String? memberName,
    String? memberCode,
    String? memberPhone,
    String? planName,
  }) {
    return Payment(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      paidAt: paidAt ?? this.paidAt,
      dueDate: dueDate ?? this.dueDate,
      txnRef: txnRef ?? this.txnRef,
      memberName: memberName ?? this.memberName,
      memberCode: memberCode ?? this.memberCode,
      memberPhone: memberPhone ?? this.memberPhone,
      planName: planName ?? this.planName,
    );
  }

  bool get isPaid => status == 'PAID' || verificationStatus == 'APPROVED';
  bool get isPending => status == 'PENDING' || verificationStatus == 'PENDING_VERIFICATION';
  bool get isApproved => verificationStatus == 'APPROVED';
  bool get isDisapproved => verificationStatus == 'DISAPPROVED';

  int get daysOverdue {
    final refDate = dueDate ?? paidAt ?? DateTime.now();
    final diff = DateTime.now().difference(refDate).inDays;
    return diff > 0 ? diff : 1;
  }

  /// Generates the automated WhatsApp reminder message based on overdue cadence:
  /// Day 1 (Expired), Day 3 (Urgent), Day 5 (Critical Warning), or > 5 Days (24-Hour Automated Notice)
  String generateWhatsAppMessage({required String branchName}) {
    final sName = memberName ?? 'Scholar';
    final amt = amount > 0 ? amount.toInt() : 600;
    final code = memberCode ?? 'CML-${id.substring(0, 6).toUpperCase()}';
    final overdue = daysOverdue;
    final uploadUrl = 'https://chintamani.atulresidency.in/student/verify-pay?id=$code&amt=$amt';

    if (overdue <= 1) {
      // ── Stage 1: Day 1 — Membership Expiry & Renewal Notice ──
      return Uri.encodeComponent(
        '🏛️ *CHINTA MANI LIBRARY* 🏛️\n'
        '━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
        '📢 *MEMBERSHIP EXPIRATION NOTICE (DAY 1)*\n\n'
        'Dear *$sName*,\n'
        'Your active study membership at *Chinta Mani Library ($branchName)* has expired today.\n\n'
        '📋 *MEMBERSHIP DETAILS:*\n'
        '• Scholar ID: `$code`\n'
        '• Study Plan: ${planName ?? "Dedicated Scholar Plan"}\n'
        '• Due Amount: *₹$amt*\n'
        '• Status: *Seat On Hold (Day 1)*\n\n'
        '━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
        '💳 *1-TAP PAYMENT UPI:*\n'
        '👉 *9415919277@upi*\n'
        '_(Pay via GPay / PhonePe / Paytm / BHIM)_\n\n'
        '━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
        '📤 *UPLOAD PAYMENT SCREENSHOT (MANDATORY):*\n'
        'Tap the portal link below to upload your payment screenshot & Txn ID for instant seat renewal approval:\n'
        '🔗 $uploadUrl\n\n'
        '━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
        '📞 *Director Helpline:* +91 9415919277\n'
        '📍 *Infinity under a roof • Chinta Mani Library*',
      );
    } else if (overdue <= 3) {
      // ── Stage 2: Day 3 — 3rd Day Urgent Warning ──
      return Uri.encodeComponent(
        '⚠️ *CHINTA MANI LIBRARY - URGENT 3RD DAY NOTICE* ⚠️\n'
        '━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
        '🚨 *FEE OVERDUE: $overdue DAYS*\n\n'
        'Dear *$sName*,\n'
        'This is an urgent reminder that your library fee of *₹$amt* is now *3 days overdue* at Chinta Mani Library ($branchName).\n\n'
        '⚠️ *WARNING:* According to library policy, unpaid allocated seats and locker keys are prioritized for waiting candidates on Day 3.\n\n'
        '📋 *STUDENT RECORD:*\n'
        '• Scholar ID: `$code`\n'
        '• Outstanding: *₹$amt*\n'
        '• Priority: *HIGH (Action Required Today)*\n\n'
        '━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
        '💳 *INSTANT UPI ID:*\n'
        '👉 *9415919277@upi*\n\n'
        '━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
        '📸 *UPLOAD SCREENSHOT TO RETAIN SEAT:*\n'
        'Submit your payment receipt screenshot here:\n'
        '🔗 $uploadUrl\n\n'
        '━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
        '📞 *Helpline / Director:* +91 9415919277\n'
        'Please clear your dues immediately to prevent auto-release.',
      );
    } else if (overdue <= 5) {
      // ── Stage 3: Day 5 — 5th Day Critical Cancellation Notice ──
      return Uri.encodeComponent(
        '⛔ *CHINTA MANI LIBRARY - 5TH DAY CRITICAL NOTICE* ⛔\n'
        '━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
        '🚨 *SEAT CANCELLATION & SUSPENSION ALERT*\n\n'
        'Dear *$sName*,\n'
        'Your membership fee of *₹$amt* is now *$overdue days overdue* (Scholar ID: `$code`).\n\n'
        '‼️ *CRITICAL NOTICE:* If fee is not settled by today, your dedicated seat allocation and locker access will be revoked and re-assigned to the next student in queue.\n\n'
        '━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
        '💳 *EMERGENCY CLEARANCE UPI:*\n'
        '👉 *9415919277@upi*\n\n'
        '━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
        '📤 *UPLOAD PROOF IMMEDIATELY:*\n'
        'Upload your payment confirmation screenshot:\n'
        '🔗 $uploadUrl\n\n'
        '━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
        '📞 *Director Desk:* +91 9415919277\n'
        '*Chinta Mani Library Management Desk*',
      );
    } else {
      // ── Stage 4: Day > 5 — Recurring 24-Hour Automated Notice ──
      return Uri.encodeComponent(
        '⏰ *CHINTA MANI LIBRARY - 24H RECURRING OVERDUE NOTICE* ⏰\n'
        '━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
        '📢 *AUTOMATED DAILY ALERT (Day $overdue Overdue)*\n\n'
        'Dear *$sName* (ID: `$code`),\n'
        'Your library membership fee of *₹$amt* remains unpaid and is overdue by *$overdue days* at Chinta Mani Library ($branchName).\n\n'
        'This automated notice will trigger every 24 hours until payment is verified on the admin ledger.\n\n'
        '━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
        '💳 *CLEAR DUES NOW (UPI):*\n'
        '👉 *9415919277@upi*\n\n'
        '━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
        '📸 *UPLOAD SCREENSHOT TO RESOLVE:* \n'
        '🔗 $uploadUrl\n\n'
        '━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
        '📞 *Helpdesk:* +91 9415919277\n'
        'Thank you,\n*Chinta Mani Library*',
      );
    }
  }
}
