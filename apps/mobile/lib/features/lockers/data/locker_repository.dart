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
      return _generateMockLockers(branchId, status: status);
    }
  }

  Future<void> updateLockerStatus(String lockerId, String status) async {
    try {
      await _apiClient.dio.patch('${ApiEndpoints.lockers}/$lockerId/status', data: {'status': status});
    } catch (_) {}
  }

  List<Locker> _generateMockLockers(String branchId, {String? status}) {
    final occupants = branchId.contains('mehdawal')
        ? {
            'L02': 'Sunil Gupta',
            'L05': 'Kajal Mishra',
          }
        : {
            'L01': 'Aarav Sharma',
            'L03': 'Akshara Pandey',
            'L07': 'Sarita Pandey',
          };

    // Strictly 9 lockers per branch (L01 - L09) as per official library setup
    final List<Locker> lockers = [];
    for (int i = 1; i <= 9; i++) {
      final num = 'L${i.toString().padLeft(2, '0')}';
      String lockerStatus = 'AVAILABLE';
      String? memberName;

      if (occupants.containsKey(num)) {
        lockerStatus = 'OCCUPIED';
        memberName = occupants[num];
      }

      if (status != null && status != 'ALL' && lockerStatus != status) {
        continue;
      }

      lockers.add(Locker(
        id: 'locker-$branchId-$num',
        lockerNumber: num,
        status: lockerStatus,
        branchId: branchId,
        currentMemberName: memberName,
      ));
    }
    return lockers;
  }
}

final lockersListProvider = FutureProvider.autoDispose<List<Locker>>((ref) async {
  final branch = ref.watch(activeBranchProvider);
  final repo = ref.read(lockerRepositoryProvider);
  return repo.getLockers(branchId: branch.id);
});
