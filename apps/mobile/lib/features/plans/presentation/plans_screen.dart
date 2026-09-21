import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/branch_switcher.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/glass_text_field.dart';
import '../data/plans_repository.dart';
import '../domain/plan_model.dart';
import '../../branch/providers/branch_provider.dart';

class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  void _showAddPlanDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final durationController = TextEditingController(text: '30');
    final priceController = TextEditingController();
    bool includesSeat = true;
    bool includesLocker = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.3)),
          ),
          title: const Text('Add Membership Plan', style: TextStyle(color: AppColors.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassTextField(controller: nameController, label: 'Plan Name *', hintText: 'e.g. 3 Months Study Pass'),
                const SizedBox(height: 10),
                GlassTextField(controller: durationController, label: 'Duration (Days) *', keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                GlassTextField(controller: priceController, label: 'Price (₹) *', keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primaryGreen,
                  title: const Text('Includes Dedicated Seat', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                  value: includesSeat,
                  onChanged: (v) => setState(() => includesSeat = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primaryGreen,
                  title: const Text('Includes Locker Facility', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                  value: includesLocker,
                  onChanged: (v) => setState(() => includesLocker = v),
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
                if (nameController.text.trim().isNotEmpty && priceController.text.trim().isNotEmpty) {
                  Navigator.pop(ctx);
                  final branch = ref.read(activeBranchProvider);
                  await ref.read(plansRepositoryProvider).createPlan({
                    'branchId': branch.id,
                    'name': nameController.text.trim(),
                    'durationDays': int.tryParse(durationController.text) ?? 30,
                    'price': double.tryParse(priceController.text) ?? 600.0,
                    'includesSeat': includesSeat,
                    'includesLocker': includesLocker,
                  });
                  ref.invalidate(plansListProvider);
                }
              },
              child: const Text('Save Plan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(plansListProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        titleSpacing: 12,
        title: const BranchSwitcher(),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.accentNeon),
            tooltip: 'Add Plan',
            onPressed: () => _showAddPlanDialog(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        onPressed: () => _showAddPlanDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Plan', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: RefreshIndicator(
        color: AppColors.accentNeon,
        onRefresh: () async => ref.invalidate(plansListProvider),
        child: plansAsync.when(
          data: (plans) {
            return ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.card_membership, color: AppColors.accentNeon, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Duration: ${plan.durationDays} Days'
                              '${plan.includesSeat ? '  •  Seat Included' : ''}'
                              '${plan.includesLocker ? '  •  Locker' : ''}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${plan.price.toInt()}',
                        style: const TextStyle(
                          color: AppColors.accentNeon,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.statusExpired))),
        ),
      ),
    );
  }
}
