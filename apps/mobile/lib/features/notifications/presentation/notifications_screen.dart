import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../data/notifications_repository.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsListProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Notifications & Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () => ref.invalidate(notificationsListProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.accentNeon,
        onRefresh: () async => ref.invalidate(notificationsListProvider),
        child: notifsAsync.when(
          data: (list) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final notif = list[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: notif.isRead ? Colors.white.withOpacity(0.06) : AppColors.primaryGreen.withOpacity(0.35),
                      width: notif.isRead ? 1 : 1.2,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_active, color: AppColors.accentNeon, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif.body,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              DateFormat('hh:mm a • dd MMM').format(notif.createdAt),
                              style: const TextStyle(color: AppColors.textDisabled, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.statusExpired))),
        ),
      ),
    );
  }
}
