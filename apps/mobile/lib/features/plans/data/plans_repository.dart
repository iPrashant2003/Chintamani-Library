import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/services/database_backup_service.dart';
import '../domain/plan_model.dart';
import '../../branch/providers/branch_provider.dart';

final plansRepositoryProvider = Provider<PlansRepository>((ref) {
  return PlansRepository(ref.read(apiClientProvider));
});

class PlansRepository {
  final ApiClient _apiClient;

  PlansRepository(this._apiClient);

  static const String _dbPlansKey = 'library_plans_and_shifts';

  Future<List<MembershipPlan>> getPlans({required String branchId, bool? isActive}) async {
    try {
      // First check local persistent storage for any user edits or custom batches
      final db = await DatabaseBackupService.instance.readDatabase();
      if (db[_dbPlansKey] is List && (db[_dbPlansKey] as List).isNotEmpty) {
        final list = db[_dbPlansKey] as List;
        return list.map((e) => MembershipPlan.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      }
    } catch (_) {}

    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.plans,
        queryParameters: {
          'branchId': branchId,
          if (isActive != null) 'isActive': isActive,
        },
      );
      final rawList = response.data is Map && response.data['data'] != null
          ? response.data['data'] as List
          : response.data as List;
      final serverPlans = rawList.map((e) => MembershipPlan.fromJson(e as Map<String, dynamic>)).toList();
      if (serverPlans.isNotEmpty) return serverPlans;
    } catch (_) {}

    return _standardPlans(branchId);
  }

  Future<void> saveAllPlans(List<MembershipPlan> plans) async {
    try {
      final db = await DatabaseBackupService.instance.readDatabase();
      db[_dbPlansKey] = plans.map((p) => p.toJson()).toList();
      await DatabaseBackupService.instance.writeDatabase(db);
    } catch (_) {}
  }

  Future<MembershipPlan> createPlan(Map<String, dynamic> data) async {
    final newPlan = MembershipPlan(
      id: 'plan-${DateTime.now().millisecondsSinceEpoch}',
      branchId: data['branchId']?.toString() ?? '',
      name: data['name']?.toString() ?? 'New Batch',
      durationDays: (data['durationDays'] as num?)?.toInt() ?? 30,
      price: (data['price'] as num?)?.toDouble() ?? 500.0,
      includesSeat: data['includesSeat'] == true,
      includesLocker: data['includesLocker'] == true,
    );

    try {
      final currentPlans = await getPlans(branchId: data['branchId']?.toString() ?? '');
      final updated = [...currentPlans, newPlan];
      await saveAllPlans(updated);
    } catch (_) {}

    return newPlan;
  }

  Future<void> updatePlan(MembershipPlan updatedPlan) async {
    try {
      final currentPlans = await getPlans(branchId: updatedPlan.branchId);
      final updated = currentPlans.map((p) => p.id == updatedPlan.id ? updatedPlan : p).toList();
      await saveAllPlans(updated);
    } catch (_) {}
  }

  Future<void> deletePlan(String planId, String branchId) async {
    try {
      final currentPlans = await getPlans(branchId: branchId);
      final updated = currentPlans.where((p) => p.id != planId).toList();
      await saveAllPlans(updated);
    } catch (_) {}
  }

  // Standard library pricing configured per official directions:
  // 6 hrs: ₹500
  // 12 hrs: ₹800
  // 24 hrs / Full Day: ₹1,000
  // Registration: ₹100
  // Locker: ₹200
  List<MembershipPlan> _standardPlans(String branchId) {
    return [
      MembershipPlan(
        id: 'plan-6h',
        branchId: branchId,
        name: '6 hrs batch (Morning / Evening)',
        durationDays: 30,
        price: 500,
        includesSeat: true,
        includesLocker: false,
      ),
      MembershipPlan(
        id: 'plan-12h',
        branchId: branchId,
        name: '12 hrs batch (Day / Night)',
        durationDays: 30,
        price: 800,
        includesSeat: true,
        includesLocker: false,
      ),
      MembershipPlan(
        id: 'plan-24h',
        branchId: branchId,
        name: '24 hrs batch (Full Day / Reserved)',
        durationDays: 30,
        price: 1000,
        includesSeat: true,
        includesLocker: false,
      ),
      MembershipPlan(
        id: 'plan-reg',
        branchId: branchId,
        name: 'Registration Fee (One-Time)',
        durationDays: 365,
        price: 100,
        includesSeat: false,
        includesLocker: false,
      ),
      MembershipPlan(
        id: 'plan-locker',
        branchId: branchId,
        name: 'Locker Facility (9 Lockers Vault)',
        durationDays: 30,
        price: 200,
        includesSeat: false,
        includesLocker: true,
      ),
    ];
  }
}

final plansListProvider = FutureProvider.autoDispose<List<MembershipPlan>>((ref) async {
  final branch = ref.watch(activeBranchProvider);
  final repo = ref.read(plansRepositoryProvider);
  return repo.getPlans(branchId: branch.id);
});
