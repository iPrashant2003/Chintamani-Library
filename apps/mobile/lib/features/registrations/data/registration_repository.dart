import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/registration_model.dart';
import '../domain/payment_verification_model.dart';

final registrationRepositoryProvider = Provider<RegistrationRepository>((ref) {
  return RegistrationRepository(ref.read(apiClientProvider));
});

class RegistrationFilterArgs {
  final String status;
  final String? branchId;
  const RegistrationFilterArgs({required this.status, this.branchId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegistrationFilterArgs &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          branchId == other.branchId;

  @override
  int get hashCode => status.hashCode ^ (branchId?.hashCode ?? 0);
}

final registrationsListProvider = FutureProvider.family<List<RegistrationModel>, RegistrationFilterArgs>(
  (ref, args) async {
    final repo = ref.read(registrationRepositoryProvider);
    return repo.getRegistrations(
      status: args.status,
      branchId: (args.branchId == null || args.branchId == 'ALL' || args.branchId == 'all') ? null : args.branchId,
    );
  },
);

final pendingRegistrationsCountProvider = FutureProvider.family<int, String?>((ref, branchId) async {
  final repo = ref.read(registrationRepositoryProvider);
  return repo.getPendingCount(
    branchId: (branchId == null || branchId == 'ALL' || branchId == 'all') ? null : branchId,
  );
});

final paymentVerificationsListProvider = FutureProvider.family<List<PaymentVerificationModel>, String>(
  (ref, status) async {
    final repo = ref.read(registrationRepositoryProvider);
    return repo.getPaymentVerifications(status: status);
  },
);

final pendingVerificationsCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.read(registrationRepositoryProvider);
  return repo.getPendingVerificationsCount();
});

class RegistrationRepository {
  final ApiClient _apiClient;

  RegistrationRepository(this._apiClient);

  Future<List<RegistrationModel>> getRegistrations({
    String status = 'PENDING',
    String? search,
    String? branchId,
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.registrations,
        queryParameters: {
          'status': status,
          if (search != null && search.isNotEmpty) 'search': search,
          if (branchId != null) 'branchId': branchId,
          'page': page,
          'limit': limit,
        },
      );
      final data = response.data;
      final list = data is Map ? (data['data'] as List? ?? []) : (data as List? ?? []);
      return list.map((j) => RegistrationModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> getPendingCount({String? branchId}) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiEndpoints.registrations}/pending-count',
        queryParameters: {
          if (branchId != null) 'branchId': branchId,
        },
      );
      final data = response.data;
      if (data is int) return data;
      if (data is Map) return (data['count'] as int? ?? data as int? ?? 0);
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<Map<String, dynamic>?> getRegistrationDetail(String id) async {
    try {
      final response = await _apiClient.dio.get('${ApiEndpoints.registrations}/$id');
      return response.data as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> approveRegistration(String id, {String? seatId}) async {
    try {
      await _apiClient.dio.patch(
        '${ApiEndpoints.registrations}/$id/approve',
        data: {if (seatId != null) 'seatId': seatId},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rejectRegistration(String id, {String? reason}) async {
    try {
      await _apiClient.dio.patch(
        '${ApiEndpoints.registrations}/$id/reject',
        data: {'reason': reason ?? 'Application requirements not met'},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> assignSeat(String registrationId, String seatId) async {
    try {
      await _apiClient.dio.patch(
        '${ApiEndpoints.registrations}/$registrationId/assign-seat',
        data: {'seatId': seatId},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // Payment Verifications

  Future<List<PaymentVerificationModel>> getPaymentVerifications({
    String status = 'PENDING',
    String? search,
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.paymentVerifications,
        queryParameters: {
          'status': status,
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'limit': limit,
        },
      );
      final data = response.data;
      final list = data is Map ? (data['data'] as List? ?? []) : (data as List? ?? []);
      return list.map((j) => PaymentVerificationModel.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> getPendingVerificationsCount() async {
    try {
      final response = await _apiClient.dio.get('${ApiEndpoints.paymentVerifications}/pending-count');
      final data = response.data;
      if (data is int) return data;
      if (data is Map) return data['count'] as int? ?? 0;
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<bool> approveVerification(String id) async {
    try {
      await _apiClient.dio.patch('${ApiEndpoints.paymentVerifications}/$id/approve');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rejectVerification(String id, {String? reason}) async {
    try {
      await _apiClient.dio.patch(
        '${ApiEndpoints.paymentVerifications}/$id/reject',
        data: {'reason': reason ?? 'Transaction could not be verified'},
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
