import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/branch_switcher.dart';
import '../../../widgets/glass_text_field.dart';
import '../../../widgets/glass_dropdown.dart';
import '../data/expenses_repository.dart';
import '../domain/expense_model.dart';
import '../../branch/providers/branch_provider.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  void _showAddExpenseDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final descController = TextEditingController();
    String category = 'ELECTRICITY';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.3)),
          ),
          title: const Text('Add Branch Expense', style: TextStyle(color: AppColors.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassDropdown<String>(
                  label: 'Category',
                  value: category,
                  items: Expense.categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => category = v ?? 'OTHER'),
                ),
                const SizedBox(height: 12),
                GlassTextField(
                  controller: amountController,
                  label: 'Amount (₹) *',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.primaryGreen),
                ),
                const SizedBox(height: 12),
                GlassTextField(
                  controller: descController,
                  label: 'Description',
                  hintText: 'e.g. Electric bill for September',
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              onPressed: () async {
                if (amountController.text.trim().isNotEmpty) {
                  Navigator.pop(ctx);
                  final branch = ref.read(activeBranchProvider);
                  await ref.read(expensesRepositoryProvider).createExpense({
                    'branchId': branch.id,
                    'category': category,
                    'amount': double.tryParse(amountController.text) ?? 0.0,
                    'description': descController.text.trim(),
                  });
                  ref.invalidate(expensesListProvider);
                }
              },
              child: const Text('Save Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catFilter = ref.watch(expenseCategoryFilterProvider);
    final expensesAsync = ref.watch(expensesListProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        titleSpacing: 12,
        title: const BranchSwitcher(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () => ref.invalidate(expensesListProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        onPressed: () => _showAddExpenseDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: RefreshIndicator(
        color: AppColors.accentNeon,
        onRefresh: () async => ref.invalidate(expensesListProvider),
        child: Column(
          children: [
            // Category filter chips
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _CatChip(
                      label: 'All Categories',
                      isSelected: catFilter == 'ALL',
                      onTap: () => ref.read(expenseCategoryFilterProvider.notifier).state = 'ALL',
                    ),
                    const SizedBox(width: 8),
                    ...Expense.categories.map((c) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _CatChip(
                            label: c,
                            isSelected: catFilter == c,
                            onTap: () => ref.read(expenseCategoryFilterProvider.notifier).state = c,
                          ),
                        )),
                  ],
                ),
              ),
            ),

            // Expense list
            Expanded(
              child: expensesAsync.when(
                data: (expenses) {
                  final totalAmount = expenses.fold<double>(0.0, (sum, e) => sum + e.amount);

                  return Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Expenditure',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            Text('₹${totalAmount.toInt()}',
                                style: const TextStyle(
                                    color: Color(0xFFF97316), fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80, top: 4),
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final e = expenses[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.bgCard,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white.withOpacity(0.06)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF97316).withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.receipt, color: Color(0xFFF97316), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(e.category,
                                            style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                        if (e.description != null)
                                          Text(e.description!,
                                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                        Text(DateFormat('dd MMM yyyy').format(e.date),
                                            style: const TextStyle(color: AppColors.textDisabled, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₹${e.amount.toInt()}',
                                    style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.statusExpired))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CatChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen.withOpacity(0.2) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.accentNeon : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
