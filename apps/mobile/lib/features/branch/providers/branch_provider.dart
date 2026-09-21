import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/branch_model.dart';
import 'package:chintamani_library/core/api/api_client.dart';

final activeBranchProvider = StateProvider<Branch>((ref) {
  return Branch.khalilabadBranch;
});

final userBranchesProvider = FutureProvider<List<Branch>>((ref) async {
  try {
    final client = ref.read(apiClientProvider);
    final response = await client.dio.get('/branches');
    if (response.data is Map && response.data['data'] is List) {
      final list = (response.data['data'] as List)
          .map((e) => Branch.fromJson(e as Map<String, dynamic>))
          .toList();
      if (list.isNotEmpty) {
        // Match active branch to preserve user choice while binding real DB ID
        final currentActive = ref.read(activeBranchProvider);
        final match = list.firstWhere(
          (b) => b.shortName.toLowerCase() == currentActive.shortName.toLowerCase() ||
                 b.name.toLowerCase().contains(currentActive.shortName.toLowerCase()),
          orElse: () => list.first,
        );
        ref.read(activeBranchProvider.notifier).state = match;
        return list;
      }
    }
  } catch (_) {}
  return Branch.officialBranches;
});
