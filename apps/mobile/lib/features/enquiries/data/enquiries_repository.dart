import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/enquiry_model.dart';
import '../../branch/providers/branch_provider.dart';

final enquiriesRepositoryProvider = Provider<EnquiriesRepository>((ref) {
  return EnquiriesRepository(ref.read(apiClientProvider));
});

class EnquiriesRepository {
  final ApiClient _apiClient;

  EnquiriesRepository(this._apiClient);

  Future<List<Enquiry>> getEnquiries({required String branchId, String? status}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.enquiries,
        queryParameters: {
          'branchId': branchId,
          if (status != null && status != 'ALL') 'status': status,
        },
      );
      final rawList = response.data is Map && response.data['data'] != null
          ? response.data['data'] as List
          : response.data as List;
      return rawList.map((e) => Enquiry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _generateMockEnquiries(branchId, status: status);
    }
  }

  Future<Enquiry> createEnquiry(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.enquiries, data: data);
      final resData = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;
      return Enquiry.fromJson(resData as Map<String, dynamic>);
    } catch (_) {
      return Enquiry(
        id: 'enq-${DateTime.now().millisecondsSinceEpoch}',
        branchId: data['branchId']?.toString() ?? '',
        name: data['name']?.toString() ?? 'Prospective Student',
        phone: data['phone']?.toString() ?? '9876543210',
        status: 'NEW',
        notes: data['notes']?.toString(),
        createdAt: DateTime.now(),
      );
    }
  }

  Future<void> updateEnquiryStatus(String id, String status) async {
    try {
      await _apiClient.dio.patch('${ApiEndpoints.enquiries}/$id', data: {'status': status});
    } catch (_) {}
  }

  List<Enquiry> _generateMockEnquiries(String branchId, {String? status}) {
    final now = DateTime.now();
    final list = [
      Enquiry(
        id: 'enq-1',
        branchId: branchId,
        name: 'Rohit Mehra',
        phone: '9876501928',
        email: 'rohit.mehra@gmail.com',
        status: 'NEW',
        followUpDate: now.add(const Duration(days: 1)),
        notes: 'Needs morning 7am-2pm slot with AC seat',
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      Enquiry(
        id: 'enq-2',
        branchId: branchId,
        name: 'Ankita Jain',
        phone: '9876501929',
        status: 'INTERESTED',
        followUpDate: now,
        notes: 'Wants to visit and check locker facility tomorrow',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Enquiry(
        id: 'enq-3',
        branchId: branchId,
        name: 'Vikram Rathore',
        phone: '9876501930',
        status: 'CONTACTED',
        notes: 'Called, shared plan brochures via WhatsApp',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Enquiry(
        id: 'enq-4',
        branchId: branchId,
        name: 'Simran Kaur',
        phone: '9876501931',
        status: 'CONVERTED',
        notes: 'Joined Quarterly plan A12',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ];

    if (status != null && status != 'ALL') {
      return list.where((e) => e.status == status).toList();
    }
    return list;
  }
}

final enquiryFilterProvider = StateProvider<String>((ref) => 'ALL');

final enquiriesListProvider = FutureProvider.autoDispose<List<Enquiry>>((ref) async {
  final branch = ref.watch(activeBranchProvider);
  final status = ref.watch(enquiryFilterProvider);
  final repo = ref.read(enquiriesRepositoryProvider);
  return repo.getEnquiries(branchId: branch.id, status: status);
});
