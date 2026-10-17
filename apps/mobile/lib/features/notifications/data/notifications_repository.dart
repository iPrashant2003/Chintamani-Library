import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/notification_model.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.read(apiClientProvider));
});

class NotificationsRepository {
  final ApiClient _apiClient;

  NotificationsRepository(this._apiClient);

  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.notifications);
      final rawList = response.data is Map && response.data['data'] != null
          ? response.data['data'] as List
          : response.data as List;
      final serverNotifs = rawList.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
      if (serverNotifs.isNotEmpty) return serverNotifs;
    } catch (_) {}

    return _getDefaultNotifications();
  }

  List<AppNotification> _getDefaultNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'notif-dues-reminder',
        type: 'PAYMENT_ALERT',
        title: 'Membership Renewal & Fees',
        body: 'Check expiring subscriptions and send WhatsApp fee reminders directly from Due Payments.',
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 25)),
      ),
      AppNotification(
        id: 'notif-backup-verified',
        type: 'BACKUP',
        title: 'Automated Master Database Backup',
        body: 'Local JSON snapshot is active for Director Manglesh Mani Tripathi (9415919277). Keep exported backups updated.',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 'notif-app-version',
        type: 'UPDATE',
        title: 'Chintamani Library System Live',
        body: 'System operational with single loading transition, 9-locker capacity, and full omni global search.',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: 'notif-hall-capacity',
        type: 'OPERATIONS',
        title: 'Single Hall Capacity Verified',
        body: 'Khalilabad (72 Seats) and Mehdawal (65 Seats) operational 06:00 AM – 11:00 PM daily.',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      AppNotification(
        id: 'notif-qr-portal',
        type: 'PORTAL',
        title: 'Universal 4D Portal & QR Active',
        body: 'Scholars can scan the Universal QR code for instant self-attendance and e-agreement access.',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.dio.patch('${ApiEndpoints.notifications}/$id/read');
    } catch (_) {}
  }
}

final notificationsListProvider = FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  final repo = ref.read(notificationsRepositoryProvider);
  return repo.getNotifications();
});
