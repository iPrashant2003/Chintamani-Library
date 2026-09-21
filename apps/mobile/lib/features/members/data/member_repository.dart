import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/paginated_response.dart';
import '../../../core/services/database_backup_service.dart';
import '../domain/member_model.dart';
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
      final response = await _apiClient.dio.get(
        ApiEndpoints.members,
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
      return PaginatedResponse<Member>.fromJson(
        data as Map<String, dynamic>,
        (json) => Member.fromJson(json),
      );
    } catch (_) {
      // Fetch from local master database (Clean, zero demo members by default)
      final localMembers = await DatabaseBackupService.instance.getMembers(branchId);
      final filtered = localMembers.where((m) {
        if (status == 'active' && !m.isActive) return false;
        if (status == 'expired' && m.isActive) return false;
        if (status == 'expiring1_3' && (m.daysRemaining == null || m.daysRemaining! > 3 || !m.isActive)) return false;
        if (status == 'expiring4_7' && (m.daysRemaining == null || m.daysRemaining! < 4 || m.daysRemaining! > 7 || !m.isActive)) return false;
        if (status == 'expiring8_15' && (m.daysRemaining == null || m.daysRemaining! < 8 || m.daysRemaining! > 15 || !m.isActive)) return false;
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

  Future<void> deleteMember(String id) async {
    try {
      await _apiClient.dio.delete('${ApiEndpoints.members}/$id');
    } catch (_) {}
    await DatabaseBackupService.instance.deleteMember(id);
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
  final res = await repo.getMembers(branchId: branch.id, status: 'all', limit: 1000);
  final all = res.data;

  int active = 0;
  int expired = 0;
  int exp1_3 = 0;
  int exp4_7 = 0;
  int exp8_15 = 0;

  for (final m in all) {
    if (m.isActive) {
      active++;
      final rem = m.daysRemaining;
      if (rem != null) {
        if (rem <= 3) {
          exp1_3++;
        } else if (rem <= 7) {
          exp4_7++;
        } else if (rem <= 15) {
          exp8_15++;
        }
      }
    } else {
      expired++;
    }
  }

  return {
    'active': active,
    'expired': expired,
    'expiring1_3': exp1_3,
    'expiring4_7': exp4_7,
    'expiring8_15': exp8_15,
    'all': all.length,
  };
});
