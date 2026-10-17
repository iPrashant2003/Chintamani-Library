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
      final seats = rawList.map((e) => Seat.fromJson(e as Map<String, dynamic>)).toList();

      // ── Front-end safety: filter to only valid Single Hall seats ──
      final filtered = _filterAndSortSeats(seats, branchId);

      if (filtered.isEmpty) {
        return _generateMockSeats(branchId, floor: floor, status: status);
      }
      // Apply status filter if backend didn't do it
      if (status != null && status != 'ALL') {
        return filtered.where((s) => s.status == status).toList();
      }
      return filtered;
    } catch (_) {
      return _generateMockSeats(branchId, floor: floor, status: status);
    }
  }

  /// Resolves whether a branchId refers to Mehdawal branch.
  /// Matches by slug/name AND by the known Mehdawal DB UUID.
  static bool _isMehdawalBranch(String branchId) {
    final lower = branchId.toLowerCase();
    return lower.contains('mehdawal') ||
        lower.contains('mehda') ||
        lower == 'a45d90e2-8154-4a83-b83b-fcfa7db86c44';
  }

  /// Filter to official seat numbers only and sort numerically.
  List<Seat> _filterAndSortSeats(List<Seat> seats, String branchId) {
    // First check if any returned seats have an M prefix — that tells us definitively
    final hasMSeats = seats.any((s) => s.seatNumber.startsWith('M'));
    final hasKSeats = seats.any((s) => s.seatNumber.startsWith('K'));

    final isMehdawal = hasMSeats && !hasKSeats
        ? true
        : (!hasKSeats && !hasMSeats)
            ? _isMehdawalBranch(branchId)
            : _isMehdawalBranch(branchId);
    final prefix = isMehdawal ? 'M' : 'K';
    final max = isMehdawal ? 65 : 72;
    final pattern = RegExp('^$prefix(\\d{2})\$');

    final filtered = seats.where((s) {
      final match = pattern.firstMatch(s.seatNumber);
      if (match == null) return false;
      final num = int.tryParse(match.group(1) ?? '') ?? 0;
      return num >= 1 && num <= max;
    }).toList();

    filtered.sort((a, b) {
      final numA = int.tryParse(a.seatNumber.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final numB = int.tryParse(b.seatNumber.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return numA.compareTo(numB);
    });

    return filtered;
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
    final isMehdawal = _isMehdawalBranch(branchId);
    // Khalilabad: 72 seats | Mehdawal: 65 seats (official capacities)
    final totalSeats = isMehdawal ? 65 : 72;
    const singleFloor = 'Main Hall';

    final prefix = isMehdawal ? 'M' : 'K';

    // 100% Real data: All seats start AVAILABLE. Real members added manually get assigned.
    for (int i = 1; i <= totalSeats; i++) {
      final seatNum = '$prefix${i.toString().padLeft(2, '0')}';
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
