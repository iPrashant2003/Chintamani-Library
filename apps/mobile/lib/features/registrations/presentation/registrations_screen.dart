import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../routing/route_names.dart';
import '../data/registration_repository.dart';
import '../domain/registration_model.dart';
import 'registration_detail_screen.dart';

final selectedRegistrationStatusProvider = StateProvider<String>((ref) => 'PENDING');

class RegistrationsScreen extends ConsumerStatefulWidget {
  const RegistrationsScreen({super.key});

  @override
  ConsumerState<RegistrationsScreen> createState() => _RegistrationsScreenState();
}

class _RegistrationsScreenState extends ConsumerState<RegistrationsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(selectedRegistrationStatusProvider);
    final registrationsAsync = ref.watch(registrationsListProvider(status));

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        title: const Text(
          'Member Registrations',
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
              ref.invalidate(registrationsListProvider);
              ref.invalidate(pendingRegistrationsCountProvider);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(105),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x22FFFFFF)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search by name, phone, or REG-ID...',
                      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.goldPrimary, size: 18),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),

              // Filter Tabs
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                child: Row(
                  children: [
                    _buildTabButton('PENDING', 'Pending Review', const Color(0xFFD97706)),
                    const SizedBox(width: 8),
                    _buildTabButton('APPROVED', 'Approved', const Color(0xFF059669)),
                    const SizedBox(width: 8),
                    _buildTabButton('REJECTED', 'Rejected', const Color(0xFFDC2626)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: registrationsAsync.when(
        data: (list) {
          final filtered = list.where((r) {
            if (_searchQuery.isEmpty) return true;
            return r.name.toLowerCase().contains(_searchQuery) ||
                r.phone.contains(_searchQuery) ||
                r.applicationId.toLowerCase().contains(_searchQuery);
          }).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.assignment_turned_in_outlined,
                    size: 54,
                    color: AppColors.textTertiary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    status == 'PENDING'
                        ? 'No pending registrations'
                        : 'No $status registrations found',
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
              ref.invalidate(registrationsListProvider);
            },
            color: AppColors.goldPrimary,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final item = filtered[idx];
                return _buildRegistrationCard(context, item);
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.goldPrimary),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.redPrimary, size: 36),
              const SizedBox(height: 8),
              Text(
                'Failed to load registrations\n$err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(registrationsListProvider),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary),
                child: const Text('Retry', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String tabValue, String label, Color accentColor) {
    final currentStatus = ref.watch(selectedRegistrationStatusProvider);
    final isSelected = currentStatus == tabValue;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(selectedRegistrationStatusProvider.notifier).state = tabValue;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withOpacity(0.18) : AppColors.bgCard,
            borderRadius: BorderRadius.circular(10),
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

  Widget _buildRegistrationCard(BuildContext context, RegistrationModel item) {
    Color statusColor;
    switch (item.status) {
      case 'APPROVED':
        statusColor = const Color(0xFF059669);
        break;
      case 'REJECTED':
        statusColor = const Color(0xFFDC2626);
        break;
      default:
        statusColor = const Color(0xFFD97706);
    }

    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(item.submittedAt);

    return GestureDetector(
      onTap: () async {
        final changed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => RegistrationDetailScreen(registrationId: item.id),
          ),
        );
        if (changed == true) {
          ref.invalidate(registrationsListProvider);
          ref.invalidate(pendingRegistrationsCountProvider);
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
            // Top Row: App ID + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3), width: 0.8),
                  ),
                  child: Text(
                    item.applicationId,
                    style: const TextStyle(
                      color: AppColors.goldLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withOpacity(0.4), width: 0.8),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Applicant Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.purpleDeep.withOpacity(0.2),
                  child: Text(
                    item.name.isNotEmpty ? item.name.substring(0, 1).toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppColors.purpleLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+91 ${item.phone}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Plan & Seat Info row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.card_membership_rounded, size: 14, color: AppColors.goldPrimary),
                      const SizedBox(width: 6),
                      Text(
                        item.planName ?? 'Standard Plan',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  if (item.reservedSeatNumber != null)
                    Row(
                      children: [
                        const Icon(Icons.event_seat_rounded, size: 14, color: Color(0xFF059669)),
                        const SizedBox(width: 4),
                        Text(
                          'Seat ${item.reservedSeatNumber}',
                          style: const TextStyle(color: Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    )
                  else
                    const Text(
                      'Admin Allocation',
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 10),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Bottom timestamp & view detail
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
                      'Review Application',
                      style: TextStyle(color: AppColors.goldPrimary, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.goldPrimary),
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
