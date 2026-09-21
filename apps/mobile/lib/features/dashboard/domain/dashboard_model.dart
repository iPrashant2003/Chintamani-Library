class DashboardStats {
  final int liveMembers;
  final int totalMembers;
  final int expiredMemberships;
  final int expiring1to3;
  final int expiring4to7;
  final int expiring8to15;
  final double todayCollection;
  final double monthCollection;
  final double prevMonthCollection;
  final int todayCheckIns;
  final double dueAmount;
  final int todayReminders;
  final double todayExpenses;
  final int todayFollowups;
  final int totalEnquiries;
  final int todayBirthdays;
  final int occupiedSeats;
  final int totalSeats;
  final int availableSeats;

  int get expiringIn1to3Days => expiring1to3;
  int get expiringIn4to7Days => expiring4to7;
  int get expiringIn8to15Days => expiring8to15;

  const DashboardStats({
    this.liveMembers = 0,
    this.totalMembers = 0,
    this.expiredMemberships = 0,
    this.expiring1to3 = 0,
    this.expiring4to7 = 0,
    this.expiring8to15 = 0,
    this.todayCollection = 0.0,
    this.monthCollection = 0.0,
    this.prevMonthCollection = 0.0,
    this.todayCheckIns = 0,
    this.dueAmount = 0.0,
    this.todayReminders = 0,
    this.todayExpenses = 0.0,
    this.todayFollowups = 0,
    this.totalEnquiries = 0,
    this.todayBirthdays = 0,
    this.occupiedSeats = 0,
    this.totalSeats = 0,
    this.availableSeats = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      liveMembers: (json['liveMembers'] as num?)?.toInt() ?? 0,
      totalMembers: (json['totalMembers'] as num?)?.toInt() ?? 0,
      expiredMemberships: (json['expiredMemberships'] as num?)?.toInt() ?? 0,
      expiring1to3: (json['expiringIn1to3Days'] as num?)?.toInt() ?? (json['expiring1to3'] as num?)?.toInt() ?? 0,
      expiring4to7: (json['expiringIn4to7Days'] as num?)?.toInt() ?? (json['expiring4to7'] as num?)?.toInt() ?? 0,
      expiring8to15: (json['expiringIn8to15Days'] as num?)?.toInt() ?? (json['expiring8to15'] as num?)?.toInt() ?? 0,
      todayCollection: (json['todayCollection'] as num?)?.toDouble() ?? 0.0,
      monthCollection: (json['monthCollection'] as num?)?.toDouble() ?? 0.0,
      prevMonthCollection: (json['prevMonthCollection'] as num?)?.toDouble() ?? 0.0,
      todayCheckIns: (json['todayCheckIns'] as num?)?.toInt() ?? 0,
      dueAmount: (json['dueAmount'] as num?)?.toDouble() ?? 0.0,
      todayReminders: (json['todayReminders'] as num?)?.toInt() ?? 0,
      todayExpenses: (json['todayExpenses'] as num?)?.toDouble() ?? 0.0,
      todayFollowups: (json['todayFollowups'] as num?)?.toInt() ?? 0,
      totalEnquiries: (json['totalEnquiries'] as num?)?.toInt() ?? 0,
      todayBirthdays: (json['todayBirthdays'] as num?)?.toInt() ?? 0,
      occupiedSeats: (json['occupiedSeats'] as num?)?.toInt() ?? 0,
      totalSeats: (json['totalSeats'] as num?)?.toInt() ?? 0,
      availableSeats: (json['availableSeats'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'liveMembers': liveMembers,
      'totalMembers': totalMembers,
      'expiredMemberships': expiredMemberships,
      'expiring1to3': expiring1to3,
      'expiring4to7': expiring4to7,
      'expiring8to15': expiring8to15,
      'todayCollection': todayCollection,
      'monthCollection': monthCollection,
      'prevMonthCollection': prevMonthCollection,
      'todayCheckIns': todayCheckIns,
      'dueAmount': dueAmount,
      'todayReminders': todayReminders,
      'todayExpenses': todayExpenses,
      'todayFollowups': todayFollowups,
      'totalEnquiries': totalEnquiries,
      'todayBirthdays': todayBirthdays,
      'occupiedSeats': occupiedSeats,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
    };
  }
}
