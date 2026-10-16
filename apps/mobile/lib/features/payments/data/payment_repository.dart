import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/payment_model.dart';
import '../../branch/providers/branch_provider.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(ref.read(apiClientProvider));
});

class PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepository(this._apiClient);

  Future<List<Payment>> getPayments({required String branchId, String? status}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.payments,
        queryParameters: {
          'branchId': branchId,
          if (status != null && status != 'ALL') 'status': status,
        },
      );
      final rawList = response.data is Map && response.data['data'] != null
          ? response.data['data'] as List
          : response.data as List;
      final apiPayments = rawList.map((e) => Payment.fromJson(e as Map<String, dynamic>)).toList();
      return _filterPayments(apiPayments, status);
    } catch (_) {
      return [];
    }
  }

  List<Payment> _filterPayments(List<Payment> list, String? status) {
    if (status == null || status == 'ALL') return list;
    if (status == 'APPROVED') return list.where((p) => p.isApproved).toList();
    if (status == 'PENDING') return list.where((p) => p.isPending).toList();
    if (status == 'DISAPPROVED') return list.where((p) => p.isDisapproved).toList();
    return list.where((p) => p.status == status).toList();
  }

  Future<void> updateVerificationStatus(String paymentId, String newStatus) async {
    try {
      await _apiClient.dio.patch('${ApiEndpoints.payments}/$paymentId', data: {'verificationStatus': newStatus});
    } catch (_) {}
  }

  Future<Payment> recordPayment(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.payments, data: data);
      final resData = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;
      return Payment.fromJson(resData as Map<String, dynamic>);
    } catch (_) {
      return Payment(
        id: 'pay-${DateTime.now().millisecondsSinceEpoch}',
        memberId: data['memberId']?.toString() ?? '',
        amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
        method: data['method']?.toString() ?? 'UPI',
        status: 'PENDING',
        verificationStatus: 'PENDING_VERIFICATION',
        paidAt: DateTime.now(),
        memberName: data['memberName']?.toString() ?? 'Scholar',
        memberPhone: data['phone']?.toString() ?? '',
        planName: data['planName']?.toString() ?? '',
      );
    }
  }
}

final paymentFilterProvider = StateProvider<String>((ref) => 'ALL');

final paymentsListProvider = FutureProvider.autoDispose<List<Payment>>((ref) async {
  final branch = ref.watch(activeBranchProvider);
  final filter = ref.watch(paymentFilterProvider);
  final repo = ref.read(paymentRepositoryProvider);
  return repo.getPayments(branchId: branch.id, status: filter);
});
