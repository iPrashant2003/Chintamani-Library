import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/paginated_response.dart';
import '../../../core/services/database_backup_service.dart';
import '../domain/member_model.dart';
import '../../plans/domain/plan_model.dart';
import '../../lockers/domain/locker_model.dart';
import '../../branch/providers/branch_provider.dart';

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository(ref.read(apiClientProvider));
});

class MemberRepository {
  final ApiClient _apiClient;

  MemberRepository(this._apiClient);

  Future<PaginatedResponse<Member>> getMembers({
    required String branchId,
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final endpoint = status == 'archived' ? '${ApiEndpoints.members}/archived' : ApiEndpoints.members;
      final response = await _apiClient.dio.get(
        endpoint,
        queryParameters: {
          'branchId': branchId,
          if (status != null && status != 'all') 'status': status,
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'limit': limit,
        },
      );
      final data = response.data is Map && response.data['data'] != null
          ? response.data
          : {'data': response.data, 'total': (response.data as List).length, 'page': 1, 'limit': limit};
      final result = PaginatedResponse<Member>.fromJson(
        data as Map<String, dynamic>,
        (json) => Member.fromJson(json),
      );

      // Sync fetched backend members to local cache (keeps offline view fresh)
      for (final member in result.data) {
        await DatabaseBackupService.instance.addMember(member);
      }

      return result;
    } catch (_) {
      // Fetch from local master database (Clean, zero demo members by default)
      final localMembers = await DatabaseBackupService.instance.getMembers(branchId);
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      final day3End = endOfToday.add(const Duration(days: 3));
      final day5End = endOfToday.add(const Duration(days: 5));
      final day15End = endOfToday.add(const Duration(days: 15));

      final filtered = localMembers.where((m) {
        final sub = m.activeSubscription;
        final bool hasValidSub = sub != null && sub.endDate.isAfter(startOfToday);
        if (status == 'active' && (!m.isActive || !hasValidSub)) return false;
        if (status == 'expired' && (m.isActive && hasValidSub)) return false;
        if (status == 'expiring1_3') {
          if (!m.isActive || sub == null) return false;
          if (!sub.endDate.isAfter(endOfToday) || sub.endDate.isAfter(day3End)) return false;
        }
        if (status == 'expiring3_5' || status == 'expiring4_7') {
          if (!m.isActive || sub == null) return false;
          if (!sub.endDate.isAfter(day3End) || sub.endDate.isAfter(day5End)) return false;
        }
        if (status == 'expiring8_15') {
          if (!m.isActive || sub == null) return false;
          final day7End = endOfToday.add(const Duration(days: 7));
          if (!sub.endDate.isAfter(day7End) || sub.endDate.isAfter(day15End)) return false;
        }
        if (search != null && search.isNotEmpty) {
          final q = search.toLowerCase();
          return m.name.toLowerCase().contains(q) ||
              m.memberCode.toLowerCase().contains(q) ||
              (m.phone != null && m.phone!.contains(q));
        }
        return true;
      }).toList();

      return PaginatedResponse<Member>(
        data: filtered,
        total: filtered.length,
        page: page,
        limit: limit,
      );
    }
  }

  Future<Member> getMember(String id) async {
    try {
      final response = await _apiClient.dio.get('${ApiEndpoints.members}/$id');
      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;
      return Member.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      final localMembers = await DatabaseBackupService.instance.getMembers('');
      final match = localMembers.where((m) => m.id == id).firstOrNull;
      if (match != null) return match;
      throw Exception('Member not found');
    }
  }

  Future<Member> createMember(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.members, data: data);
      final resData = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;
      final member = Member.fromJson(resData as Map<String, dynamic>);
      await DatabaseBackupService.instance.addMember(member);
      return member;
    } catch (_) {
      // Save locally to persistent database & backup
      final id = 'mem-${DateTime.now().millisecondsSinceEpoch}';
      final code = 'CML-${(DateTime.now().millisecondsSinceEpoch % 900000 + 100000)}';
      final newMember = Member(
        id: id,
        memberCode: code,
        name: data['name']?.toString() ?? 'New Scholar',
        phone: data['phone']?.toString(),
        email: data['email']?.toString(),
        fatherName: data['fatherName']?.toString(),
        gender: data['gender']?.toString(),
        dob: data['dob'] != null ? DateTime.tryParse(data['dob'].toString()) : null,
        address: data['address']?.toString(),
        institute: data['institute']?.toString(),
        course: data['course']?.toString(),
        batch: data['batch']?.toString(),
        branchId: data['branchId']?.toString() ?? 'chintamani-khalilabad',
        isActive: true,
      );
      await DatabaseBackupService.instance.addMember(newMember);
      return newMember;
    }
  }

  Future<Member> updateMember(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.patch('${ApiEndpoints.members}/$id', data: data);
      final resData = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;
      final member = Member.fromJson(resData as Map<String, dynamic>);
      await DatabaseBackupService.instance.updateMember(member);
      return member;
    } catch (_) {
      final local = await DatabaseBackupService.instance.getMembers('');
      final existing = local.where((m) => m.id == id).firstOrNull;
      if (existing != null) {
        final updated = Member(
          id: existing.id,
          memberCode: existing.memberCode,
          name: data['name']?.toString() ?? existing.name,
          phone: data['phone']?.toString() ?? existing.phone,
          email: data['email']?.toString() ?? existing.email,
          fatherName: data['fatherName']?.toString() ?? existing.fatherName,
          gender: data['gender']?.toString() ?? existing.gender,
          dob: existing.dob,
          address: data['address']?.toString() ?? existing.address,
          institute: data['institute']?.toString() ?? existing.institute,
          course: data['course']?.toString() ?? existing.course,
          batch: data['batch']?.toString() ?? existing.batch,
          branchId: existing.branchId,
          isActive: existing.isActive,
        );
        await DatabaseBackupService.instance.updateMember(updated);
        return updated;
      }
      throw Exception('Member not found');
    }
  }

  Future<Map<String, dynamic>> archiveMember(String id) async {
    try {
      final res = await _apiClient.dio.patch('${ApiEndpoints.members}/$id/archive');
      return {'success': true, 'message': res.data['message'] ?? 'Member archived successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to archive member: $e'};
    }
  }

  Future<Map<String, dynamic>> restoreMember(String id) async {
    try {
      final res = await _apiClient.dio.patch('${ApiEndpoints.members}/$id/restore');
      return {'success': true, 'message': res.data['message'] ?? 'Member restored successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to restore member: $e'};
    }
  }

  Future<Map<String, dynamic>> permanentDeleteMember(String id) async {
    try {
      final res = await _apiClient.dio.delete('${ApiEndpoints.members}/$id/permanent');
      await DatabaseBackupService.instance.deleteMember(id);
      return {'success': true, 'message': res.data['message'] ?? 'Member permanently deleted'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to permanently delete member: $e'};
    }
  }

  Future<void> deleteMember(String id) async {
    try {
      await _apiClient.dio.delete('${ApiEndpoints.members}/$id');
    } catch (_) {}
    await DatabaseBackupService.instance.deleteMember(id);
  }

  Future<Member?> renewSubscription(String memberId, {required String planName, required double price, required int days}) async {
    final local = await DatabaseBackupService.instance.getMembers('');
    final existing = local.where((m) => m.id == memberId).firstOrNull;
    if (existing == null) return null;

    final now = DateTime.now();
    DateTime newStart = now;
    if (existing.activeSubscription != null && existing.activeSubscription!.endDate.isAfter(now)) {
      newStart = existing.activeSubscription!.endDate;
    }
    final newEnd = newStart.add(Duration(days: days));

    final newSub = Subscription(
      id: 'sub-${DateTime.now().millisecondsSinceEpoch}',
      memberId: memberId,
      planId: 'plan-${planName.replaceAll(' ', '-').toLowerCase()}',
      startDate: newStart,
      endDate: newEnd,
      status: 'ACTIVE',
      seat: existing.activeSubscription?.seat,
      locker: existing.activeSubscription?.locker,
      plan: MembershipPlan(
        id: 'plan-${planName.replaceAll(' ', '-').toLowerCase()}',
        name: planName,
        durationDays: days,
        price: price,
        branchId: existing.branchId,
        includesSeat: true,
      ),
    );

    final updated = existing.copyWith(
      isActive: true,
      subscriptions: [newSub, ...existing.subscriptions],
    );

    try {
      await _apiClient.dio.post('${ApiEndpoints.members}/$memberId/subscriptions', data: {
        'planName': planName,
        'price': price,
        'durationDays': days,
        'startDate': newStart.toIso8601String(),
        'endDate': newEnd.toIso8601String(),
      });
    } catch (_) {}

    await DatabaseBackupService.instance.updateMember(updated);
    return updated;
  }

  Future<Member?> giftDays(String memberId, int days) async {
    final local = await DatabaseBackupService.instance.getMembers('');
    final existing = local.where((m) => m.id == memberId).firstOrNull;
    if (existing == null) return null;

    final sub = existing.activeSubscription;
    if (sub == null) return null;

    final updatedSub = sub.copyWith(
      endDate: sub.endDate.add(Duration(days: days)),
      status: 'ACTIVE',
    );

    final remainingSubs = existing.subscriptions.where((s) => s.id != sub.id).toList();
    final updated = existing.copyWith(
      isActive: true,
      subscriptions: [updatedSub, ...remainingSubs],
    );

    await DatabaseBackupService.instance.updateMember(updated);
    return updated;
  }

  Future<Member?> toggleBlock(String memberId) async {
    final local = await DatabaseBackupService.instance.getMembers('');
    final existing = local.where((m) => m.id == memberId).firstOrNull;
    if (existing == null) return null;

    final updated = existing.copyWith(isActive: !existing.isActive);
    try {
      await _apiClient.dio.patch('${ApiEndpoints.members}/$memberId', data: {'isActive': updated.isActive});
    } catch (_) {}
    await DatabaseBackupService.instance.updateMember(updated);
    return updated;
  }

  Future<Member?> markLeft(String memberId) async {
    final local = await DatabaseBackupService.instance.getMembers('');
    final existing = local.where((m) => m.id == memberId).firstOrNull;
    if (existing == null) return null;

    final subs = existing.subscriptions.map((s) => s.copyWith(
      seat: null,
      assignedSeatId: null,
      status: 'EXPIRED',
    )).toList();

    final updated = existing.copyWith(
      isActive: false,
      subscriptions: subs,
    );

    try {
      await _apiClient.dio.patch('${ApiEndpoints.members}/$memberId', data: {'isActive': false});
    } catch (_) {}
    await DatabaseBackupService.instance.updateMember(updated);
    return updated;
  }

  Future<Member?> assignLocker(String memberId, String lockerNumber) async {
    final local = await DatabaseBackupService.instance.getMembers('');
    final existing = local.where((m) => m.id == memberId).firstOrNull;
    if (existing == null) return null;

    final sub = existing.activeSubscription;
    if (sub == null) return null;

    final updatedSub = sub.copyWith(
      locker: Locker(
        id: 'locker-$lockerNumber',
        lockerNumber: lockerNumber,
        status: 'OCCUPIED',
        branchId: existing.branchId,
      ),
    );

    final remainingSubs = existing.subscriptions.where((s) => s.id != sub.id).toList();
    final updated = existing.copyWith(
      subscriptions: [updatedSub, ...remainingSubs],
    );

    await DatabaseBackupService.instance.updateMember(updated);
    return updated;
  }

  Future<Map<String, int>> getStats(String branchId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiEndpoints.members}/stats',
        queryParameters: {'branchId': branchId},
      );
      if (response.data is Map) {
        final data = response.data as Map;
        return {
          'all': (data['all'] as num?)?.toInt() ?? 0,
          'active': (data['active'] as num?)?.toInt() ?? 0,
          'expired': (data['expired'] as num?)?.toInt() ?? 0,
          'expiring1_3': (data['expiring1_3'] as num?)?.toInt() ?? 0,
          'expiring3_5': (data['expiring3_5'] as num?)?.toInt() ?? 0,
          'expiring4_7': (data['expiring3_5'] ?? data['expiring4_7'] as num?)?.toInt() ?? 0,
          'expiring8_15': (data['expiring8_15'] as num?)?.toInt() ?? 0,
        };
      }
    } catch (_) {}

    // Fallback: local calculation with strict non-overlapping date logic
    final localMembers = await DatabaseBackupService.instance.getMembers(branchId);
    int active = 0;
    int expired = 0;
    int exp1_3 = 0;
    int exp3_5 = 0;
    int exp8_15 = 0;

    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    final day3End = endOfToday.add(const Duration(days: 3));
    final day5End = endOfToday.add(const Duration(days: 5));
    final day15End = endOfToday.add(const Duration(days: 15));

    for (final m in localMembers) {
      final sub = m.activeSubscription;
      final bool hasValidSub = sub != null && sub.endDate.isAfter(startOfToday);
      if (m.isActive && hasValidSub) {
        active++;
        final end = sub.endDate;
        if (end.isAfter(endOfToday) && !end.isAfter(day3End)) {
          exp1_3++;
        } else if (end.isAfter(day3End) && !end.isAfter(day5End)) {
          exp3_5++;
        } else if (end.isAfter(endOfToday.add(const Duration(days: 7))) && !end.isAfter(day15End)) {
          exp8_15++;
        }
      } else {
        expired++;
      }
    }

    return {
      'all': localMembers.length,
      'active': active,
      'expired': expired,
      'expiring1_3': exp1_3,
      'expiring3_5': exp3_5,
      'expiring4_7': exp3_5,
      'expiring8_15': exp8_15,
    };
  }
}


class MemberFilterState {
  final String status;
  final String searchQuery;

  const MemberFilterState({this.status = 'all', this.searchQuery = ''});

  MemberFilterState copyWith({String? status, String? searchQuery}) {
    return MemberFilterState(
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final memberFilterProvider = StateProvider<MemberFilterState>((ref) {
  return const MemberFilterState();
});

final membersListProvider = FutureProvider.autoDispose<PaginatedResponse<Member>>((ref) async {
  final branch = ref.watch(activeBranchProvider);
  final filter = ref.watch(memberFilterProvider);
  final repo = ref.read(memberRepositoryProvider);

  return repo.getMembers(
    branchId: branch.id,
    status: filter.status,
    search: filter.searchQuery,
  );
});

final memberDetailProvider = FutureProvider.autoDispose.family<Member, String>((ref, id) async {
  final repo = ref.read(memberRepositoryProvider);
  return repo.getMember(id);
});

final memberStatsProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final branch = ref.watch(activeBranchProvider);
  final repo = ref.read(memberRepositoryProvider);
  return repo.getStats(branch.id);
});
