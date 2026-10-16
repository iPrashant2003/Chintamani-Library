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
      final list = rawList.map((e) => Locker.fromJson(e as Map<String, dynamic>)).toList();
      if (list.isEmpty) {
        return _generateDefaultLockers(branchId, status: status);
      }
      return list;
    } catch (_) {
      return _generateDefaultLockers(branchId, status: status);
    }
  }

  List<Locker> _generateDefaultLockers(String branchId, {String? status}) {
    final List<Locker> lockers = [];
    for (int i = 1; i <= 9; i++) {
      final lockerNum = 'L${i.toString().padLeft(2, '0')}';
      const lockerStatus = 'AVAILABLE';
      if (status != null && status != 'ALL' && lockerStatus != status) continue;

      lockers.add(Locker(
        id: 'locker-$lockerNum',
        lockerNumber: lockerNum,
        status: lockerStatus,
        branchId: branchId,
      ));
    }
    return lockers;
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
