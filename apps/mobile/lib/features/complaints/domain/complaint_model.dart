class ComplaintModel {
  final String id;
  final String complaintId;
  final String memberName;
  final String memberPhone;
  final String? memberId;
  final String category;
  final String description;
  final String status; // OPEN, IN_PROGRESS, RESOLVED, CLOSED
  final String? resolution;
  final String? assignedTo;
  final String? branchName;
  final String? attachmentUrls;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const ComplaintModel({
    required this.id,
    required this.complaintId,
    required this.memberName,
    required this.memberPhone,
    this.memberId,
    required this.category,
    required this.description,
    required this.status,
    this.resolution,
    this.assignedTo,
    this.branchName,
    this.attachmentUrls,
    required this.createdAt,
    this.resolvedAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] as String,
      complaintId: json['complaintId'] as String,
      memberName: json['memberName'] as String,
      memberPhone: json['memberPhone'] as String,
      memberId: json['memberId'] as String?,
      category: json['category'] as String,
      description: json['description'] as String,
      status: json['status'] as String? ?? 'OPEN',
      resolution: json['resolution'] as String?,
      assignedTo: json['assignedTo'] as String?,
      branchName: json['branch']?['name'] as String?,
      attachmentUrls: json['attachmentUrls'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      resolvedAt: json['resolvedAt'] != null ? DateTime.tryParse(json['resolvedAt'] as String) : null,
    );
  }

  bool get isOpen => status == 'OPEN' || status == 'IN_PROGRESS';
  bool get isResolved => status == 'RESOLVED' || status == 'CLOSED';
}
