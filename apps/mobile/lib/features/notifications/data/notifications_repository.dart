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
      return rawList.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _generateMockNotifications();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.dio.patch('${ApiEndpoints.notifications}/$id/read');
    } catch (_) {}
  }

  List<AppNotification> _generateMockNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'notif-1',
        type: 'EXPIRY_ALERT',
        title: 'Membership Expiring Soon',
        body: 'Aditya Tripathi\'s Monthly plan expires in 2 days (Seat B02).',
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 15)),
      ),
      AppNotification(
        id: 'notif-2',
        type: 'PAYMENT_RECEIVED',
        title: 'Payment Recorded',
        body: '₹600 received via UPI from Aarav Sharma (CML-942810).',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 'notif-3',
        type: 'ENQUIRY',
        title: 'Follow-up Due Today',
        body: 'Follow-up scheduled with Ankita Jain regarding locker facility.',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: 'notif-4',
        type: 'SYSTEM',
        title: 'Branch Shift Notice',
        body: 'Chintamani Library – Khalilabad AC servicing scheduled tomorrow 6 AM.',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}

final notificationsListProvider = FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  final repo = ref.read(notificationsRepositoryProvider);
  return repo.getNotifications();
});
