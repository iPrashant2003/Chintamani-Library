import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/services/database_backup_service.dart';
import '../domain/dashboard_model.dart';
import '../../branch/providers/branch_provider.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.read(apiClientProvider));
});

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  Future<DashboardStats> getStats(String branchId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.dashboard,
        queryParameters: {'branchId': branchId},
      );
      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;
      return DashboardStats.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return _computeStatsFromLocalDb(branchId);
    }
  }

  Future<DashboardStats> _computeStatsFromLocalDb(String branchId) async {
    try {
      final members = await DatabaseBackupService.instance.getMembers(branchId);
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final todayStart = DateTime(now.year, now.month, now.day);

      int liveMembers = 0;
      int expiredMemberships = 0;
      int expiring1to3 = 0;
      int expiring4to7 = 0;
      int expiring8to15 = 0;
      double monthCollection = 0.0;
      double todayCollection = 0.0;
      double dueAmount = 0.0;
      int occupiedSeats = 0;

      for (final m in members) {
        bool hasActiveSub = false;

        for (final sub in m.subscriptions) {
          final planPrice = sub.plan?.price ?? 0.0;

          if (sub.isActive) {
            hasActiveSub = true;
            final daysLeft = sub.endDate.difference(now).inDays;
            if (daysLeft <= 3) expiring1to3++;
            else if (daysLeft <= 7) expiring4to7++;
            else if (daysLeft <= 15) expiring8to15++;
            // Count plan price as monthly collection if started this month
            if (sub.startDate.isAfter(monthStart)) {
              monthCollection += planPrice;
              if (sub.startDate.isAfter(todayStart)) {
                todayCollection += planPrice;
              }
            }
          } else if (sub.isExpired) {
            expiredMemberships++;
            // Any unpaid due amounts
            if (planPrice > 0) dueAmount += planPrice * 0.1; // 10% overdue estimate
          }
        }

        if (hasActiveSub) {
          liveMembers++;
          occupiedSeats++;
        }
      }

      return DashboardStats(
        liveMembers: liveMembers,
        totalMembers: members.length,
        expiredMemberships: expiredMemberships,
        expiring1to3: expiring1to3,
        expiring4to7: expiring4to7,
        expiring8to15: expiring8to15,
        todayCollection: todayCollection,
        monthCollection: monthCollection,
        prevMonthCollection: 0.0,
        todayCheckIns: liveMembers,
        dueAmount: dueAmount,
        todayReminders: expiring1to3,
        todayExpenses: 0.0,
        todayFollowups: 0,
        totalEnquiries: 0,
        todayBirthdays: 0,
        occupiedSeats: occupiedSeats,
        totalSeats: 50,
        availableSeats: (50 - occupiedSeats).clamp(0, 50),
      );
    } catch (_) {
      return const DashboardStats(
        liveMembers: 0,
        totalMembers: 0,
        expiredMemberships: 0,
        expiring1to3: 0,
        expiring4to7: 0,
        expiring8to15: 0,
        todayCollection: 0.0,
        monthCollection: 0.0,
        prevMonthCollection: 0.0,
        todayCheckIns: 0,
        dueAmount: 0.0,
        todayReminders: 0,
        todayExpenses: 0.0,
        todayFollowups: 0,
        totalEnquiries: 0,
        todayBirthdays: 0,
        occupiedSeats: 0,
        totalSeats: 50,
        availableSeats: 50,
      );
    }
  }
}

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  final branch = ref.watch(activeBranchProvider);
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.getStats(branch.id);
});
