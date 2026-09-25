import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/complaint_model.dart';

final complaintRepositoryProvider = Provider<ComplaintRepository>((ref) {
  return ComplaintRepository(ref.read(apiClientProvider));
});

class ComplaintFilterArgs {
  final String status;
  final String? branchId;
  const ComplaintFilterArgs({required this.status, this.branchId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplaintFilterArgs &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          branchId == other.branchId;

  @override
  int get hashCode => status.hashCode ^ (branchId?.hashCode ?? 0);
}

final complaintsListProvider = FutureProvider.family<List<ComplaintModel>, ComplaintFilterArgs>(
  (ref, args) async {
    final repo = ref.read(complaintRepositoryProvider);
    return repo.getComplaints(
      status: args.status,
      branchId: (args.branchId == null || args.branchId == 'ALL' || args.branchId == 'all') ? null : args.branchId,
    );
  },
);

final openComplaintsCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(complaintRepositoryProvider);
  return repo.getOpenCount();
});

class ComplaintRepository {
  final ApiClient _apiClient;

  ComplaintRepository(this._apiClient);

  Future<List<ComplaintModel>> getComplaints({
    String status = 'OPEN',
    String? category,
    String? search,
    String? branchId,
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.complaints,
        queryParameters: {
          'status': status,
          if (category != null && category != 'ALL') 'category': category,
          if (search != null && search.isNotEmpty) 'search': search,
          if (branchId != null) 'branchId': branchId,
          'page': page,
          'limit': limit,
        },
      );
      final data = response.data;
      final list = data is Map ? (data['data'] as List? ?? []) : (data as List? ?? []);
      return list.map((j) => ComplaintModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> getOpenCount({String? branchId}) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiEndpoints.complaints}/open-count',
        queryParameters: {
          if (branchId != null) 'branchId': branchId,
        },
      );
      final data = response.data;
      if (data is int) return data;
      if (data is Map) return data['count'] as int? ?? 0;
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<ComplaintModel?> getComplaintDetail(String id) async {
    try {
      final response = await _apiClient.dio.get('${ApiEndpoints.complaints}/$id');
      return ComplaintModel.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateStatus(String id, String status, {String? resolution, String? assignedTo}) async {
    try {
      await _apiClient.dio.patch(
        '${ApiEndpoints.complaints}/$id/status',
        data: {
          'status': status,
          if (resolution != null) 'resolution': resolution,
          if (assignedTo != null) 'assignedTo': assignedTo,
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
