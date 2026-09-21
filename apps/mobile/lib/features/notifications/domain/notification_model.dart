class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'GENERAL',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
