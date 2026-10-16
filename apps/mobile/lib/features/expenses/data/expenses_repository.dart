import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/expense_model.dart';
import '../../branch/providers/branch_provider.dart';

final expensesRepositoryProvider = Provider<ExpensesRepository>((ref) {
  return ExpensesRepository(ref.read(apiClientProvider));
});

class ExpensesRepository {
  final ApiClient _apiClient;

  ExpensesRepository(this._apiClient);

  Future<List<Expense>> getExpenses({required String branchId, String? category}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.expenses,
        queryParameters: {
          'branchId': branchId,
          if (category != null && category != 'ALL') 'category': category,
        },
      );
      final rawList = response.data is Map && response.data['data'] != null
          ? response.data['data'] as List
          : response.data as List;
      return rawList.map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Expense> createExpense(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.expenses, data: data);
      final resData = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;
      return Expense.fromJson(resData as Map<String, dynamic>);
    } catch (_) {
      return Expense(
        id: 'exp-${DateTime.now().millisecondsSinceEpoch}',
        branchId: data['branchId']?.toString() ?? '',
        category: data['category']?.toString() ?? 'OTHER',
        amount: (data['amount'] as num?)?.toDouble() ?? 500.0,
        description: data['description']?.toString(),
        date: DateTime.now(),
      );
    }
  }

}

final expenseCategoryFilterProvider = StateProvider<String>((ref) => 'ALL');

final expensesListProvider = FutureProvider.autoDispose<List<Expense>>((ref) async {
  final branch = ref.watch(activeBranchProvider);
  final cat = ref.watch(expenseCategoryFilterProvider);
  final repo = ref.read(expensesRepositoryProvider);
  return repo.getExpenses(branchId: branch.id, category: cat);
});
