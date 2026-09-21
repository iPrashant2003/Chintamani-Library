import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/plan_model.dart';
import '../../branch/providers/branch_provider.dart';

final plansRepositoryProvider = Provider<PlansRepository>((ref) {
  return PlansRepository(ref.read(apiClientProvider));
});

class PlansRepository {
  final ApiClient _apiClient;

  PlansRepository(this._apiClient);

  Future<List<MembershipPlan>> getPlans({required String branchId, bool? isActive}) async {
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
      return rawList.map((e) => MembershipPlan.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _defaultPlans(branchId);
    }
  }

  Future<MembershipPlan> createPlan(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.plans, data: data);
      final resData = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;
      return MembershipPlan.fromJson(resData as Map<String, dynamic>);
    } catch (_) {
      return MembershipPlan(
        id: 'plan-${DateTime.now().millisecondsSinceEpoch}',
        branchId: data['branchId']?.toString() ?? '',
        name: data['name']?.toString() ?? 'New Plan',
        durationDays: (data['durationDays'] as num?)?.toInt() ?? 30,
        price: (data['price'] as num?)?.toDouble() ?? 600.0,
      );
    }
  }

  List<MembershipPlan> _defaultPlans(String branchId) {
    return [
      MembershipPlan(id: 'plan-1', branchId: branchId, name: 'Daily Pass', durationDays: 1, price: 80, includesSeat: true),
      MembershipPlan(id: 'plan-2', branchId: branchId, name: 'Monthly Basic', durationDays: 30, price: 600, includesSeat: true),
      MembershipPlan(id: 'plan-3', branchId: branchId, name: 'Quarterly Premium', durationDays: 90, price: 1700, includesSeat: true, includesLocker: true),
      MembershipPlan(id: 'plan-4', branchId: branchId, name: 'Half-Yearly Elite', durationDays: 180, price: 3200, includesSeat: true, includesLocker: true),
      MembershipPlan(id: 'plan-5', branchId: branchId, name: 'Annual VIP', durationDays: 365, price: 6000, includesSeat: true, includesLocker: true),
    ];
  }
}

final plansListProvider = FutureProvider.autoDispose<List<MembershipPlan>>((ref) async {
  final branch = ref.watch(activeBranchProvider);
  final repo = ref.read(plansRepositoryProvider);
  return repo.getPlans(branchId: branch.id);
});
