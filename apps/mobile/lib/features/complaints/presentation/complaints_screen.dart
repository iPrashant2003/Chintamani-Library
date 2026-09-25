import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../data/complaint_repository.dart';
import '../domain/complaint_model.dart';
import 'complaint_detail_screen.dart';

import 'package:flutter/services.dart';
import '../../branch/providers/branch_provider.dart';

final selectedComplaintStatusProvider = StateProvider<String>((ref) => 'OPEN');
final selectedComplaintCategoryProvider = StateProvider<String>((ref) => 'ALL');
final selectedComplaintBranchProvider = StateProvider<String>((ref) => 'ALL');

class ComplaintsScreen extends ConsumerStatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  ConsumerState<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends ConsumerState<ComplaintsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final active = ref.read(activeBranchProvider);
      final key = active.shortName.toLowerCase();
      ref.read(selectedComplaintBranchProvider.notifier).state = key;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(selectedComplaintStatusProvider);
    final category = ref.watch(selectedComplaintCategoryProvider);
    final branchFilter = ref.watch(selectedComplaintBranchProvider);
    final complaintsAsync = ref.watch(complaintsListProvider(
      ComplaintFilterArgs(status: status, branchId: branchFilter),
    ));

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        title: const Text(
          'Member Complaints & Issues',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.goldPrimary),
            onPressed: () {
              ref.invalidate(complaintsListProvider);
              ref.invalidate(openComplaintsCountProvider);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(175),
          child: Column(
            children: [
              // Branch Filter Bar (All / Khalilabad / Mehdawal)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                child: Row(
                  children: [
                    _buildBranchButton('ALL', '🏛️ All Branches', const Color(0xFFA855F7)),
                    const SizedBox(width: 8),
                    _buildBranchButton('khalilabad', '📍 Khalilabad', const Color(0xFFD4AF37)),
                    const SizedBox(width: 8),
                    _buildBranchButton('mehdawal', '📍 Mehdawal', const Color(0xFF14B8A6)),
                  ],
                ),
              ),
              // Search input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0x22FFFFFF)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Search complaints, members, or CMP-ID...',
                      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.purpleLight, size: 16),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 14, color: AppColors.textSecondary),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ),

              // Status Filter Tabs
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                child: Row(
                  children: [
                    _buildTabButton('OPEN', 'Open Issues', const Color(0xFFDC2626)),
                    const SizedBox(width: 8),
                    _buildTabButton('IN_PROGRESS', 'In Progress', const Color(0xFFD97706)),
                    const SizedBox(width: 8),
                    _buildTabButton('RESOLVED', 'Resolved', const Color(0xFF059669)),
                  ],
                ),
              ),

              // Category horizontal filter chips
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCatChip('ALL', 'All Categories'),
                    _buildCatChip('AC', 'AC Cooling'),
                    _buildCatChip('ELECTRICITY', 'Power / Socket'),
                    _buildCatChip('SEAT', 'Seat / Chair'),
                    _buildCatChip('CLEANLINESS', 'Cleanliness'),
                    _buildCatChip('INTERNET', 'Wi-Fi'),
                    _buildCatChip('OTHER', 'Other'),
                  ],
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
      body: complaintsAsync.when(
        data: (list) {
          final filtered = list.where((c) {
            if (category != 'ALL' && c.category.toUpperCase() != category) return false;
            if (_searchQuery.isEmpty) return true;
            return c.memberName.toLowerCase().contains(_searchQuery) ||
                c.memberPhone.contains(_searchQuery) ||
                c.complaintId.toLowerCase().contains(_searchQuery) ||
                c.description.toLowerCase().contains(_searchQuery);
          }).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.task_alt_rounded,
                    size: 54,
                    color: AppColors.textTertiary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    status == 'OPEN' ? 'No open complaints right now' : 'No $status complaints found',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(complaintsListProvider);
            },
            color: AppColors.purpleLight,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final item = filtered[idx];
                return _buildComplaintCard(context, item);
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.purpleLight),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.redPrimary, size: 36),
              const SizedBox(height: 8),
              Text('Error: $err', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(complaintsListProvider),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.purpleDeep),
                child: const Text('Retry', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranchButton(String key, String label, Color color) {
    final current = ref.watch(selectedComplaintBranchProvider);
    final isSelected = current == key;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(selectedComplaintBranchProvider.notifier).state = key;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.20) : AppColors.bgCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : const Color(0x22FFFFFF),
              width: isSelected ? 1.4 : 0.8,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? color : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String tabValue, String label, Color accentColor) {
    final currentStatus = ref.watch(selectedComplaintStatusProvider);
    final isSelected = currentStatus == tabValue;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(selectedComplaintStatusProvider.notifier).state = tabValue;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withOpacity(0.18) : AppColors.bgCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? accentColor : const Color(0x22FFFFFF),
              width: isSelected ? 1.2 : 0.8,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? accentColor : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCatChip(String code, String label) {
    final activeCat = ref.watch(selectedComplaintCategoryProvider);
    final isSelected = activeCat == code;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontSize: 10,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: AppColors.bgCard,
        selectedColor: AppColors.purpleDeep.withOpacity(0.4),
        side: BorderSide(
          color: isSelected ? AppColors.purpleLight : const Color(0x22FFFFFF),
          width: 0.8,
        ),
        onSelected: (_) {
          ref.read(selectedComplaintCategoryProvider.notifier).state = code;
        },
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildComplaintCard(BuildContext context, ComplaintModel item) {
    Color statusColor;
    switch (item.status) {
      case 'RESOLVED':
      case 'CLOSED':
        statusColor = const Color(0xFF059669);
        break;
      case 'IN_PROGRESS':
        statusColor = const Color(0xFFD97706);
        break;
      default:
        statusColor = const Color(0xFFDC2626);
    }

    final isMehdawal = (item.branchName?.toLowerCase().contains('mehda') ?? false) ||
                       (item.branchId?.toLowerCase().contains('mehda') ?? false);
    final branchDisplayName = item.branchName ?? (isMehdawal ? 'Mehdawal' : 'Khalilabad');

    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(item.createdAt);

    return GestureDetector(
      onTap: () async {
        final changed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => ComplaintDetailScreen(complaintId: item.id),
          ),
        );
        if (changed == true) {
          ref.invalidate(complaintsListProvider);
          ref.invalidate(openComplaintsCountProvider);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xF2141A24),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x22FFFFFF), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.purpleDeep.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.purpleLight.withOpacity(0.4)),
                      ),
                      child: Text(
                        item.complaintId,
                        style: const TextStyle(
                          color: AppColors.purpleLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isMehdawal ? const Color(0x2214B8A6) : const Color(0x22D4AF37),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isMehdawal ? const Color(0xFF14B8A6) : const Color(0xFFD4AF37),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        branchDisplayName,
                        style: TextStyle(
                          color: isMehdawal ? const Color(0xFF2DD4BF) : const Color(0xFFFDE68A),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.category,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Member Info
            Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  item.memberName,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                Text(
                  '+91 ${item.memberPhone}',
                  style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Description
            Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3),
            ),
            const SizedBox(height: 10),

            // Bottom row: Date & details link
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
                ),
                const Row(
                  children: [
                    Text(
                      'View & Update',
                      style: TextStyle(color: AppColors.purpleLight, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.purpleLight),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
