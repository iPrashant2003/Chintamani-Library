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
  static final List<Payment> _localStore = [];

  PaymentRepository(this._apiClient) {
    if (_localStore.isEmpty) {
      _initMockData();
    }
  }

  void _initMockData() {
    final now = DateTime.now();
    _localStore.addAll([
      Payment(
        id: 'pay-1',
        memberId: 'mem-1',
        amount: 600.0,
        method: 'UPI',
        status: 'PAID',
        verificationStatus: 'APPROVED',
        paidAt: now.subtract(const Duration(hours: 2)),
        txnRef: 'UPI-948201849',
        memberName: 'Aarav Sharma',
        memberCode: 'CML-942810',
        memberPhone: '9415919277',
        planName: 'Monthly Scholar Pass',
      ),
      Payment(
        id: 'pay-2',
        memberId: 'mem-2',
        amount: 1700.0,
        method: 'CASH',
        status: 'PAID',
        verificationStatus: 'APPROVED',
        paidAt: now.subtract(const Duration(days: 1)),
        txnRef: 'CASH-REC-042',
        memberName: 'Priya Verma',
        memberCode: 'CML-810423',
        memberPhone: '9415919277',
        planName: 'Quarterly Executive Pass',
      ),
      Payment(
        id: 'pay-3',
        memberId: 'mem-3',
        amount: 600.0,
        method: 'UPI',
        status: 'PENDING',
        verificationStatus: 'PENDING_VERIFICATION',
        paidAt: now.subtract(const Duration(hours: 4)),
        dueDate: now.subtract(const Duration(days: 1)), // Day 1 overdue
        txnRef: 'UPI-REC-77312',
        memberName: 'Aditya Tripathi',
        memberCode: 'CML-724190',
        memberPhone: '9415919277',
        planName: 'Monthly Scholar (Due)',
      ),
      Payment(
        id: 'pay-4',
        memberId: 'mem-4',
        amount: 500.0,
        method: 'CASH',
        status: 'PENDING',
        verificationStatus: 'PENDING_VERIFICATION',
        paidAt: now.subtract(const Duration(days: 3)),
        dueDate: now.subtract(const Duration(days: 3)), // Day 3 urgent overdue
        memberName: 'Sneha Patel',
        memberCode: 'CML-612984',
        memberPhone: '9415919277',
        planName: 'Shift Fee (3rd Day Overdue)',
      ),
      Payment(
        id: 'pay-5',
        memberId: 'mem-5',
        amount: 3200.0,
        method: 'BANK',
        status: 'PAID',
        verificationStatus: 'APPROVED',
        paidAt: now.subtract(const Duration(days: 5)),
        txnRef: 'NEFT-89102481',
        memberName: 'Krishna Yadav',
        memberCode: 'CML-539012',
        memberPhone: '9415919277',
        planName: 'Half-Yearly Pass',
      ),
      Payment(
        id: 'pay-6',
        memberId: 'mem-6',
        amount: 1000.0,
        method: 'UPI',
        status: 'PENDING',
        verificationStatus: 'PENDING_VERIFICATION',
        paidAt: now.subtract(const Duration(days: 6)),
        dueDate: now.subtract(const Duration(days: 6)), // 6 days overdue
        memberName: 'Rohan Gupta',
        memberCode: 'CML-482019',
        memberPhone: '9415919277',
        planName: '24-Hour Pass (6 Days Overdue)',
      ),
    ]);
  }

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
      return _filterPayments(_localStore, status);
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

    final idx = _localStore.indexWhere((p) => p.id == paymentId);
    if (idx != -1) {
      _localStore[idx] = _localStore[idx].copyWith(
        verificationStatus: newStatus,
        status: newStatus == 'APPROVED' ? 'PAID' : (newStatus == 'DISAPPROVED' ? 'FAILED' : 'PENDING'),
      );
    }
  }

  Future<Payment> recordPayment(Map<String, dynamic> data) async {
    final payment = Payment(
      id: 'pay-${DateTime.now().millisecondsSinceEpoch}',
      memberId: data['memberId']?.toString() ?? 'mem-1',
      amount: (data['amount'] as num?)?.toDouble() ?? 600.0,
      method: data['method']?.toString() ?? 'UPI',
      status: 'PAID',
      verificationStatus: 'APPROVED',
      paidAt: DateTime.now(),
      memberName: data['memberName']?.toString() ?? 'Scholar',
      memberPhone: data['phone']?.toString() ?? '9415919277',
      planName: data['planName']?.toString() ?? 'Scholar Plan',
    );
    _localStore.insert(0, payment);

    try {
      await _apiClient.dio.post(ApiEndpoints.payments, data: data);
    } catch (_) {}

    return payment;
  }
}

final paymentFilterProvider = StateProvider<String>((ref) => 'ALL');

final paymentsListProvider = FutureProvider.autoDispose<List<Payment>>((ref) async {
  final branch = ref.watch(activeBranchProvider);
  final filter = ref.watch(paymentFilterProvider);
  final repo = ref.read(paymentRepositoryProvider);
  return repo.getPayments(branchId: branch.id, status: filter);
});
