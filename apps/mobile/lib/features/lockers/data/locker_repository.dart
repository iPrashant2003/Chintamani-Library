import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/locker_model.dart';
import '../../branch/providers/branch_provider.dart';

final lockerRepositoryProvider = Provider<LockerRepository>((ref) {
  return LockerRepository(ref.read(apiClientProvider));
});

class LockerRepository {
  final ApiClient _apiClient;

  LockerRepository(this._apiClient);

  Future<List<Locker>> getLockers({required String branchId, String? status}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.lockers,
        queryParameters: {
          'branchId': branchId,
          if (status != null && status != 'ALL') 'status': status,
        },
      );
      final rawList = response.data is Map && response.data['data'] != null
          ? response.data['data'] as List
          : response.data as List;
      return rawList.map((e) => Locker.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> updateLockerStatus(String lockerId, String status) async {
    try {
      await _apiClient.dio.patch('${ApiEndpoints.lockers}/$lockerId/status', data: {'status': status});
    } catch (_) {}
  }
}

final lockersListProvider = FutureProvider.autoDispose<List<Locker>>((ref) async {
  final branch = ref.watch(activeBranchProvider);
  final repo = ref.read(lockerRepositoryProvider);
  return repo.getLockers(branchId: branch.id);
});
