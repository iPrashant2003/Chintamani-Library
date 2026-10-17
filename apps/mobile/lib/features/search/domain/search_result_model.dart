class SearchMemberItem {
  final String id;
  final String name;
  final String memberCode;
  final String? phone;
  final String? email;
  final String? seatNumber;
  final String? planName;
  final bool isActive;

  const SearchMemberItem({
    required this.id,
    required this.name,
    required this.memberCode,
    this.phone,
    this.email,
    this.seatNumber,
    this.planName,
    this.isActive = true,
  });

  factory SearchMemberItem.fromJson(Map<String, dynamic> json) {
    String? seat;
    String? plan;
    if (json['subscriptions'] is List && (json['subscriptions'] as List).isNotEmpty) {
      final sub = (json['subscriptions'] as List).first as Map<String, dynamic>;
      if (sub['seat'] is Map) {
        seat = sub['seat']['seatNumber'] as String?;
      }
      if (sub['plan'] is Map) {
        plan = sub['plan']['name'] as String?;
      }
    }

    return SearchMemberItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      memberCode: json['memberCode'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      seatNumber: seat,
      planName: plan,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class SearchSeatItem {
  final String id;
  final String seatNumber;
  final String floor;
  final String status;
  final String branchId;

  const SearchSeatItem({
    required this.id,
    required this.seatNumber,
    required this.floor,
    required this.status,
    required this.branchId,
  });

  factory SearchSeatItem.fromJson(Map<String, dynamic> json) {
    return SearchSeatItem(
      id: json['id'] as String? ?? '',
      seatNumber: json['seatNumber'] as String? ?? '',
      floor: json['floor'] as String? ?? 'Main Hall',
      status: json['status'] as String? ?? 'AVAILABLE',
      branchId: json['branchId'] as String? ?? '',
    );
  }

  bool get isAvailable => status == 'AVAILABLE';
}

class SearchLockerItem {
  final String id;
  final String lockerNumber;
  final String status;
  final String? currentMemberName;
  final String? currentMemberId;
  final String branchId;

  const SearchLockerItem({
    required this.id,
    required this.lockerNumber,
    required this.status,
    this.currentMemberName,
    this.currentMemberId,
    required this.branchId,
  });

  factory SearchLockerItem.fromJson(Map<String, dynamic> json) {
    return SearchLockerItem(
      id: json['id'] as String? ?? '',
      lockerNumber: json['lockerNumber'] as String? ?? '',
      status: json['status'] as String? ?? 'AVAILABLE',
      currentMemberName: json['currentMemberName'] as String?,
      currentMemberId: json['currentMemberId'] as String?,
      branchId: json['branchId'] as String? ?? '',
    );
  }

  bool get isAssigned => status == 'OCCUPIED' && (currentMemberName != null && currentMemberName!.isNotEmpty);
}

class SearchComplaintItem {
  final String id;
  final String complaintId;
  final String memberName;
  final String category;
  final String description;
  final String status;

  const SearchComplaintItem({
    required this.id,
    required this.complaintId,
    required this.memberName,
    required this.category,
    required this.description,
    required this.status,
  });

  factory SearchComplaintItem.fromJson(Map<String, dynamic> json) {
    return SearchComplaintItem(
      id: json['id'] as String? ?? '',
      complaintId: json['complaintId'] as String? ?? '',
      memberName: json['memberName'] as String? ?? '',
      category: json['category'] as String? ?? 'GENERAL',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'OPEN',
    );
  }
}

class SearchRegistrationItem {
  final String id;
  final String applicationId;
  final String name;
  final String phone;

  const SearchRegistrationItem({
    required this.id,
    required this.applicationId,
    required this.name,
    required this.phone,
  });

  factory SearchRegistrationItem.fromJson(Map<String, dynamic> json) {
    return SearchRegistrationItem(
      id: json['id'] as String? ?? '',
      applicationId: json['applicationId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }
}

class SearchNotificationItem {
  final String id;
  final String title;
  final String body;

  const SearchNotificationItem({
    required this.id,
    required this.title,
    required this.body,
  });

  factory SearchNotificationItem.fromJson(Map<String, dynamic> json) {
    return SearchNotificationItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }
}

class SearchResultGroup {
  final String query;
  final List<SearchMemberItem> members;
  final List<SearchSeatItem> seats;
  final List<SearchLockerItem> lockers;
  final List<SearchComplaintItem> complaints;
  final List<SearchRegistrationItem> registrations;
  final List<SearchNotificationItem> notifications;

  const SearchResultGroup({
    required this.query,
    this.members = const [],
    this.seats = const [],
    this.lockers = const [],
    this.complaints = const [],
    this.registrations = const [],
    this.notifications = const [],
  });

  bool get isEmpty =>
      members.isEmpty &&
      seats.isEmpty &&
      lockers.isEmpty &&
      complaints.isEmpty &&
      registrations.isEmpty &&
      notifications.isEmpty;

  int get totalCount =>
      members.length +
      seats.length +
      lockers.length +
      complaints.length +
      registrations.length +
      notifications.length;

  factory SearchResultGroup.fromJson(Map<String, dynamic> json) {
    return SearchResultGroup(
      query: json['query'] as String? ?? '',
      members: (json['members'] as List? ?? [])
          .map((e) => SearchMemberItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      seats: (json['seats'] as List? ?? [])
          .map((e) => SearchSeatItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      lockers: (json['lockers'] as List? ?? [])
          .map((e) => SearchLockerItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      complaints: (json['complaints'] as List? ?? [])
          .map((e) => SearchComplaintItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      registrations: (json['registrations'] as List? ?? [])
          .map((e) => SearchRegistrationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      notifications: (json['notifications'] as List? ?? [])
          .map((e) => SearchNotificationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
