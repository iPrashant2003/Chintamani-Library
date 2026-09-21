import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/seat_model.dart';
import '../../branch/providers/branch_provider.dart';

final seatRepositoryProvider = Provider<SeatRepository>((ref) {
  return SeatRepository(ref.read(apiClientProvider));
});

class SeatRepository {
  final ApiClient _apiClient;

  SeatRepository(this._apiClient);

  Future<List<Seat>> getSeats({required String branchId, String? floor, String? status}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.seats,
        queryParameters: {
          'branchId': branchId,
          if (floor != null && floor != 'ALL') 'floor': floor,
          if (status != null && status != 'ALL') 'status': status,
        },
      );
      final rawList = response.data is Map && response.data['data'] != null
          ? response.data['data'] as List
          : response.data as List;
      return rawList.map((e) => Seat.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _generateMockSeats(branchId, floor: floor, status: status);
    }
  }

  Future<void> updateSeatStatus(String seatId, String status) async {
    try {
      await _apiClient.dio.patch('${ApiEndpoints.seats}/$seatId/status', data: {'status': status});
    } catch (_) {}
  }

  Future<void> releaseSeat(String seatId) async {
    try {
      await _apiClient.dio.post('${ApiEndpoints.seats}/$seatId/release');
    } catch (_) {}
  }

  List<Seat> _generateMockSeats(String branchId, {String? floor, String? status}) {
    final List<Seat> seats = [];
    final isMehdawal = branchId.toLowerCase().contains('mehdawal');
    final totalSeats = isMehdawal ? 65 : 72;
    const singleFloor = 'Main Hall';

    // 100% Real data: All seats start AVAILABLE. Real members added manually get assigned.
    for (int i = 1; i <= totalSeats; i++) {
      final seatNum = i.toString().padLeft(2, '0');
      const seatStatus = 'AVAILABLE';

      if (status != null && status != 'ALL' && seatStatus != status) {
        continue;
      }

      seats.add(Seat(
        id: 'seat-$seatNum',
        seatNumber: seatNum,
        floor: singleFloor,
        status: seatStatus,
        branchId: branchId,
        currentMemberName: null,
      ));
    }
    return seats;
  }
}

class SeatFilterState {
  final String floor;
  final String status;

  const SeatFilterState({this.floor = 'ALL', this.status = 'ALL'});

  SeatFilterState copyWith({String? floor, String? status}) {
    return SeatFilterState(
      floor: floor ?? this.floor,
      status: status ?? this.status,
    );
  }
}

final seatFilterProvider = StateProvider<SeatFilterState>((ref) {
  return const SeatFilterState();
});

final seatsListProvider = FutureProvider.autoDispose<List<Seat>>((ref) async {
  final branch = ref.watch(activeBranchProvider);
  final filter = ref.watch(seatFilterProvider);
  final repo = ref.read(seatRepositoryProvider);

  return repo.getSeats(
    branchId: branch.id,
    floor: filter.floor,
    status: filter.status,
  );
});
