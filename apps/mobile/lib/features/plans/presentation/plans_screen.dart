import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/branch_switcher.dart';
import '../../../widgets/glass_text_field.dart';
import '../data/plans_repository.dart';
import '../domain/plan_model.dart';
import '../../branch/providers/branch_provider.dart';

class PlansScreen extends ConsumerWidget {
  const PlansScreen({super.key});

  void _showAddOrEditPlanDialog(BuildContext context, WidgetRef ref, {MembershipPlan? existing}) {
    final isEditing = existing != null;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final durationController = TextEditingController(text: existing?.durationDays.toString() ?? '30');
    final priceController = TextEditingController(text: existing != null ? existing.price.toInt().toString() : '500');
    bool includesSeat = existing?.includesSeat ?? true;
    bool includesLocker = existing?.includesLocker ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: const Color(0xFF14120E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
          ),
          title: Row(
            children: [
              Icon(
                isEditing ? Icons.edit_calendar_rounded : Icons.add_circle_outline_rounded,
                color: const Color(0xFFD4AF37),
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                isEditing ? 'Edit Batch / Timing' : 'Add Custom Batch',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configure shift duration, timings, and standard fee:',
                  style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12),
                ),
                const SizedBox(height: 14),
                GlassTextField(
                  controller: nameController,
                  label: 'Batch Name / Timing Slot *',
                  hintText: 'e.g. 6 hrs batch (06:00 AM - 12:00 PM)',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GlassTextField(
                        controller: durationController,
                        label: 'Validity (Days) *',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassTextField(
                        controller: priceController,
                        label: 'Fee (₹) *',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: const Color(0xFFD4AF37),
                  title: const Text('Dedicated Study Seat Included', style: TextStyle(color: Colors.white, fontSize: 13)),
                  value: includesSeat,
                  onChanged: (v) => setState(() => includesSeat = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: const Color(0xFFD4AF37),
                  title: const Text('Locker Facility Included (9 Lockers)', style: TextStyle(color: Colors.white, fontSize: 13)),
                  value: includesLocker,
                  onChanged: (v) => setState(() => includesLocker = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFFA1A1AA))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                final price = double.tryParse(priceController.text) ?? 500.0;
                final duration = int.tryParse(durationController.text) ?? 30;

                if (name.isEmpty) return;

                Navigator.pop(ctx);
                final branch = ref.read(activeBranchProvider);
                final repo = ref.read(plansRepositoryProvider);

                if (isEditing) {
                  final updated = existing.copyWith(
                    name: name,
                    price: price,
                    durationDays: duration,
                    includesSeat: includesSeat,
                    includesLocker: includesLocker,
                  );
                  await repo.updatePlan(updated);
                } else {
                  await repo.createPlan({
                    'branchId': branch.id,
                    'name': name,
                    'durationDays': duration,
                    'price': price,
                    'includesSeat': includesSeat,
                    'includesLocker': includesLocker,
                  });
                }

                ref.invalidate(plansListProvider);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? '✅ Batch updated successfully!' : '✅ Custom batch added!'),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text(
                isEditing ? 'Save Changes' : 'Add Batch',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, MembershipPlan plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        title: const Text('Delete Batch?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to remove "${plan.name}"?',
          style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFA1A1AA))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () async {
              Navigator.pop(ctx);
              final branch = ref.read(activeBranchProvider);
              await ref.read(plansRepositoryProvider).deletePlan(plan.id, branch.id);
              ref.invalidate(plansListProvider);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
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
            icon: const Icon(Icons.add_circle_rounded, color: Color(0xFFD4AF37)),
            tooltip: 'Add Batch / Timing',
            onPressed: () => _showAddOrEditPlanDialog(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFD4AF37),
        onRefresh: () async => ref.invalidate(plansListProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header description card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0x33D4AF37), Color(0x1014120E)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.35)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.tune_rounded, color: Color(0xFFFDE68A), size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shift & Batch Timing Management',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tap the edit pencil on any batch to customize timing slots, validity, and standard pricing.',
                            style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Standard Pricing Reference Bar
              const Text(
                'ACTIVE BATCHES & SHIFTS',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),

              const SizedBox(height: 10),

              plansAsync.when(
                data: (plans) {
                  if (plans.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const Icon(Icons.schedule_rounded, color: Color(0xFFD4AF37), size: 48),
                            const SizedBox(height: 12),
                            const Text(
                              'No batches found',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tap "Add Batch / Timing" below to configure your shifts.',
                              style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      Color badgeColor = const Color(0xFF3B82F6);
                      if (plan.name.contains('6 hrs') || plan.name.contains('6h')) {
                        badgeColor = const Color(0xFF3B82F6);
                      } else if (plan.name.contains('12 hrs') || plan.name.contains('12h')) {
                        badgeColor = const Color(0xFF8B5CF6);
                      } else if (plan.name.contains('24 hrs') || plan.name.contains('Full Day')) {
                        badgeColor = const Color(0xFF10B981);
                      } else if (plan.name.contains('Registration')) {
                        badgeColor = const Color(0xFFD4AF37);
                      } else if (plan.name.contains('Locker')) {
                        badgeColor = const Color(0xFFEC4899);
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: badgeColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: badgeColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                plan.includesLocker
                                    ? Icons.lock_rounded
                                    : plan.includesSeat
                                        ? Icons.chair_rounded
                                        : Icons.schedule_rounded,
                                color: badgeColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plan.name,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Text(
                                        '${plan.durationDays} Days',
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                                      ),
                                      if (plan.includesSeat) ...[
                                        const Text(' • ', style: TextStyle(color: AppColors.textTertiary)),
                                        const Text('Seat Included', style: TextStyle(color: Color(0xFF00E5BC), fontSize: 11.5)),
                                      ],
                                      if (plan.includesLocker) ...[
                                        const Text(' • ', style: TextStyle(color: AppColors.textTertiary)),
                                        const Text('9 Lockers', style: TextStyle(color: Color(0xFFFDE68A), fontSize: 11.5)),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${plan.price.toInt()}',
                                  style: TextStyle(
                                    color: badgeColor,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        _showAddOrEditPlanDialog(context, ref, existing: plan);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(Icons.edit_rounded, color: Color(0xFFD4AF37), size: 16),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        _confirmDelete(context, ref, plan);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
                error: (e, _) => Center(
                  child: Text('Error: $e', style: const TextStyle(color: AppColors.statusExpired)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
