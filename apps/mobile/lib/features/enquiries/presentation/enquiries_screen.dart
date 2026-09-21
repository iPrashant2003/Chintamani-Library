import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/branch_switcher.dart';
import '../../../widgets/glass_text_field.dart';
import '../data/enquiries_repository.dart';
import '../domain/enquiry_model.dart';
import '../../branch/providers/branch_provider.dart';

class EnquiriesScreen extends ConsumerWidget {
  const EnquiriesScreen({super.key});

  void _showAddEnquiryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.3)),
        ),
        title: const Text('Add Prospective Student', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassTextField(controller: nameController, label: 'Student Name *', hintText: 'e.g. Vikram Rathore'),
            const SizedBox(height: 10),
            GlassTextField(controller: phoneController, label: 'Phone Number *', keyboardType: TextInputType.phone),
            const SizedBox(height: 10),
            GlassTextField(controller: notesController, label: 'Inquiry Notes', hintText: 'e.g. Interested in morning shift', maxLines: 2),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty && phoneController.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                final branch = ref.read(activeBranchProvider);
                await ref.read(enquiriesRepositoryProvider).createEnquiry({
                  'branchId': branch.id,
                  'name': nameController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'notes': notesController.text.trim(),
                });
                ref.invalidate(enquiriesListProvider);
              }
            },
            child: const Text('Save Enquiry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusFilter = ref.watch(enquiryFilterProvider);
    final enquiriesAsync = ref.watch(enquiriesListProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        titleSpacing: 12,
        title: const BranchSwitcher(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () => ref.invalidate(enquiriesListProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        onPressed: () => _showAddEnquiryDialog(context, ref),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('New Enquiry', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: RefreshIndicator(
        color: AppColors.accentNeon,
        onRefresh: () async => ref.invalidate(enquiriesListProvider),
        child: Column(
          children: [
            // Status Tabs
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _StatusBtn(
                      label: 'All Leads',
                      isSelected: statusFilter == 'ALL',
                      onTap: () => ref.read(enquiryFilterProvider.notifier).state = 'ALL',
                    ),
                    const SizedBox(width: 8),
                    ...Enquiry.statuses.map((s) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _StatusBtn(
                            label: s,
                            isSelected: statusFilter == s,
                            onTap: () => ref.read(enquiryFilterProvider.notifier).state = s,
                          ),
                        )),
                  ],
                ),
              ),
            ),

            // Leads List
            Expanded(
              child: enquiriesAsync.when(
                data: (enquiries) {
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80, top: 4),
                    itemCount: enquiries.length,
                    itemBuilder: (context, index) {
                      final enq = enquiries[index];
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
                                color: const Color(0xFF3B82F6).withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.support_agent, color: Color(0xFF3B82F6), size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          enq.name,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.06),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(enq.status,
                                            style: const TextStyle(
                                                color: AppColors.accentNeon, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(enq.phone, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                  if (enq.notes != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(enq.notes!,
                                          style: const TextStyle(color: AppColors.textDisabled, fontSize: 12)),
                                    ),
                                ],
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
          ],
        ),
      ),
    );
  }
}

class _StatusBtn extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusBtn({required this.label, required this.isSelected, required this.onTap});

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
