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
      return _generateMockExpenses(branchId, category: category);
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

  List<Expense> _generateMockExpenses(String branchId, {String? category}) {
    final now = DateTime.now();
    final list = [
      Expense(id: 'e-1', branchId: branchId, category: 'ELECTRICITY', amount: 3450.0, description: 'Electricity Bill September', date: now.subtract(const Duration(days: 2))),
      Expense(id: 'e-2', branchId: branchId, category: 'INTERNET', amount: 1299.0, description: 'Airtel Fiber 300Mbps', date: now.subtract(const Duration(days: 5))),
      Expense(id: 'e-3', branchId: branchId, category: 'CLEANING', amount: 1500.0, description: 'Housekeeping supplies and phenyl', date: now.subtract(const Duration(days: 8))),
      Expense(id: 'e-4', branchId: branchId, category: 'MAINTENANCE', amount: 850.0, description: 'AC Filter replacement', date: now.subtract(const Duration(days: 12))),
      Expense(id: 'e-5', branchId: branchId, category: 'SALARY', amount: 12000.0, description: 'Staff Salary - Rajesh', date: now.subtract(const Duration(days: 15))),
    ];

    if (category != null && category != 'ALL') {
      return list.where((e) => e.category == category).toList();
    }
    return list;
  }
}

final expenseCategoryFilterProvider = StateProvider<String>((ref) => 'ALL');

final expensesListProvider = FutureProvider.autoDispose<List<Expense>>((ref) async {
  final branch = ref.watch(activeBranchProvider);
  final cat = ref.watch(expenseCategoryFilterProvider);
  final repo = ref.read(expensesRepositoryProvider);
  return repo.getExpenses(branchId: branch.id, category: cat);
});
