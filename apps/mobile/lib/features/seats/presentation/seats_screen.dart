import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/ambient_background.dart';
import '../../../widgets/branch_switcher.dart';
import '../../../widgets/glass_button.dart';
import '../../../widgets/secondary_button.dart';
import '../../../widgets/icon_3d.dart';
import '../../branch/providers/branch_provider.dart';
import '../data/seat_repository.dart';
import '../domain/seat_model.dart';
import '../../members/data/member_repository.dart';

class SeatsScreen extends ConsumerStatefulWidget {
  const SeatsScreen({super.key});

  @override
  ConsumerState<SeatsScreen> createState() => _SeatsScreenState();
}

class _SeatsScreenState extends ConsumerState<SeatsScreen> {
  String _selectedStatus = 'ALL';
  String? _selectedSeatId;

  @override
  void initState() {
    super.initState();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'AVAILABLE':
        return AppColors.primaryGreen;
      case 'OCCUPIED':
        return AppColors.primaryEmerald;
      case 'RESERVED':
        return AppColors.accentGold;
      case 'MAINTENANCE':
        return AppColors.accentRed;
      default:
        return AppColors.textTertiary;
    }
  }

  void _showSeatDetails(BuildContext context, Seat seat) {
    HapticFeedback.lightImpact();
    setState(() => _selectedSeatId = seat.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.bgDarkElevated.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: AppColors.borderEmerald, width: 1.2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getStatusColor(seat.status).withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                            border: Border.all(color: _getStatusColor(seat.status).withValues(alpha: 0.3)),
                          ),
                          child: Icon(Icons.chair_alt_rounded, color: _getStatusColor(seat.status), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seat ${seat.seatNumber}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              '${seat.floor} • Study Hall',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(seat.status).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _getStatusColor(seat.status).withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        seat.status,
                        style: TextStyle(
                          color: _getStatusColor(seat.status),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
                const SizedBox(height: 16),
                if (seat.isOccupied) ...[
                  const Text('Current Occupant', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    seat.currentMemberName ?? 'Assigned Member',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline_rounded, size: 13, color: Color(0xFFEF4444)),
                        SizedBox(width: 5),
                        Text(
                          'Deallocation will not cancel the membership',
                          style: TextStyle(color: Color(0xFFEF4444), fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: 'Deallocate Seat',
                          textColor: AppColors.accentRed,
                          borderColor: AppColors.borderRed,
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dctx) => AlertDialog(
                                backgroundColor: const Color(0xFF1A1A2E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(color: Color(0xFFEF4444), width: 1),
                                ),
                                title: const Text('Deallocate Seat', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                content: Text(
                                  'Are you sure you want to deallocate Seat ${seat.seatNumber}?\n\n'
                                  '${seat.currentMemberName != null ? '"${seat.currentMemberName}" will be unlinked from this seat.' : ''}\n\n'
                                  'The seat will become AVAILABLE. The member\'s subscription will remain active.',
                                  style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 13),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dctx, false),
                                    child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFEF4444),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => Navigator.pop(dctx, true),
                                    child: const Text('Deallocate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true && ctx.mounted) {
                              Navigator.pop(ctx);
                              final result = await ref.read(seatRepositoryProvider).deallocateSeat(seat.id);
                              ref.invalidate(seatsListProvider);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message'] ?? 'Seat ${seat.seatNumber} deallocated'),
                                    backgroundColor: result['success'] == true ? const Color(0xFF059669) : const Color(0xFFEF4444),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const Text(
                    'This seat is available for allocation to members.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: GlassButton(
                          label: 'Maintenance',
                          icon: Icons.build_rounded,
                          color: AppColors.accentRed,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(ctx);
                            ref.read(seatRepositoryProvider).updateSeatStatus(seat.id, 'MAINTENANCE');
                            ref.invalidate(seatsListProvider);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GlassButton(
                          label: 'Assign Seat',
                          icon: Icons.person_add_rounded,
                          color: AppColors.accentNeon,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(ctx);
                            _showAssignMemberDialog(context, seat);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      if (mounted) setState(() => _selectedSeatId = null);
    });
  }

  void _showAssignMemberDialog(BuildContext context, Seat seat) {
    final activeBranch = ref.read(activeBranchProvider);
    final searchCtrl = TextEditingController();
    String query = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          return Container(
            height: MediaQuery.of(modalCtx).size.height * 0.75,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 16,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF141A24),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: Color(0x33FFFFFF), width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assign Seat ${seat.seatNumber}',
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Select member to allocate this seat',
                          style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
                      onPressed: () => Navigator.pop(modalCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0x22FFFFFF)),
                  ),
                  child: TextField(
                    controller: searchCtrl,
                    onChanged: (val) => setModalState(() => query = val.trim().toLowerCase()),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Search by member name, phone or code...',
                      hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                      prefixIcon: Icon(Icons.search_rounded, color: AppColors.goldPrimary, size: 18),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: FutureBuilder(
                    future: ref.read(memberRepositoryProvider).getMembers(
                      branchId: activeBranch.id,
                      search: query.isNotEmpty ? query : null,
                      limit: 60,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.goldPrimary));
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error loading members: ${snapshot.error}', style: const TextStyle(color: Colors.white70)),
                        );
                      }
                      final members = snapshot.data?.data ?? [];
                      if (members.isEmpty) {
                        return const Center(
                          child: Text('No members found in this branch', style: TextStyle(color: AppColors.textTertiary)),
                        );
                      }
                      return ListView.separated(
                        itemCount: members.length,
                        separatorBuilder: (_, __) => const Divider(color: Color(0x15FFFFFF), height: 1),
                        itemBuilder: (context, index) {
                          final m = members[index];
                          final sub = m.subscriptions.isNotEmpty ? m.subscriptions.first : null;
                          final planName = sub?.plan?.name ?? 'Standard Membership';
                          final currentSeat = sub?.seat?.seatNumber;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.purpleDeep.withOpacity(0.5),
                              child: Text(
                                m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    m.name,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (currentSeat != null) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD97706).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: const Color(0xFFD97706).withOpacity(0.4)),
                                    ),
                                    child: Text(
                                      'Seat $currentSeat',
                                      style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                Text(
                                  '${m.memberCode} • ${m.phone ?? 'No phone'}',
                                  style: const TextStyle(color: AppColors.textTertiary, fontSize: 11.5),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'Plan: $planName${currentSeat != null ? ' (reallocates seat)' : ''}',
                                  style: TextStyle(
                                    color: currentSeat != null ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () async {
                                Navigator.pop(modalCtx);
                                final res = await ref.read(seatRepositoryProvider).assignSeatToMember(seat.id, m.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(res['message'] ?? 'Seat assigned'),
                                      backgroundColor: res['success'] == true ? const Color(0xFF059669) : Colors.red,
                                    ),
                                  );
                                  ref.invalidate(seatsListProvider);
                                }
                              },
                              child: const Text('Assign Seat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seatsAsync = ref.watch(seatsListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientBackground(
          imagePath: 'assets/images/dashboard_bg.png',
          child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Text(
                      'Seat Allocation',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    const BranchSwitcher(),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 22),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ref.invalidate(seatsListProvider);
                      },
                    ),
                  ],
                ),
              ),

              // Single Floor Banner (72 Seats Khalilabad • 65 Seats Mehdawal)
              Builder(
                builder: (context) {
                  final activeBranch = ref.watch(activeBranchProvider);
                  final isMehdawal = activeBranch.shortName.toLowerCase().contains('mehdawal');
                  final totalSeatCount = isMehdawal ? 65 : 72;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.bgGlass,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chair_rounded, color: Color(0xFF60A5FA), size: 16),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Single Floor • Main Study Hall',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '$totalSeatCount Total Seats (${activeBranch.shortName})',
                              style: const TextStyle(
                                color: Color(0xFF93C5FD),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$totalSeatCount SEATS',
                            style: const TextStyle(
                              color: Color(0xFF60A5FA),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              // Status Filter Chips (Unified Multicolour: Blue, Sea Green, Purple, Dark Yellow, Red)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildStatusFilterChip('ALL', 'All Seats', const Color(0xFF3B82F6)),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip('AVAILABLE', 'Available', const Color(0xFF10B981)),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip('OCCUPIED', 'Occupied', const Color(0xFF8B5CF6)),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip('RESERVED', 'Reserved', const Color(0xFFD97706)),
                      const SizedBox(width: 8),
                      _buildStatusFilterChip('MAINTENANCE', 'Repair', const Color(0xFFDC2626)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Visual Seat Grid
              Expanded(
                child: seatsAsync.when(
                  data: (allSeats) {
                    final seats = _selectedStatus == 'ALL'
                        ? allSeats
                        : allSeats.where((s) => s.status == _selectedStatus).toList();

                    if (seats.isEmpty) {
                      return const Center(
                        child: Text('No seats found for this filter', style: TextStyle(color: AppColors.textSecondary)),
                      );
                    }

                    return GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 90, top: 4),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: seats.length,
                      itemBuilder: (context, index) {
                        final seat = seats[index];
                        final color = _getStatusColor(seat.status);
                        final isSelected = _selectedSeatId == seat.id;

                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            if (seat.status == 'AVAILABLE') {
                              _showAssignMemberDialog(context, seat);
                            } else {
                              _showSeatDetails(context, seat);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryGreen.withValues(alpha: 0.28)
                                  : color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accentNeon
                                    : color.withValues(alpha: 0.35),
                                width: isSelected ? 1.8 : 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isSelected ? AppColors.accentNeon : color).withValues(alpha: isSelected ? 0.35 : 0.08),
                                  blurRadius: isSelected ? 10 : 6,
                                  spreadRadius: isSelected ? 1 : 0,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon3D(
                                  type: Icon3DType.seat,
                                  size: 24,
                                  color: isSelected ? AppColors.goldBright : color,
                                  isOccupied: seat.isOccupied,
                                  isAvailable: seat.status == 'AVAILABLE',
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  seat.seatNumber,
                                  style: TextStyle(
                                    color: isSelected ? AppColors.goldBright : color,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                if (seat.isOccupied)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: Text(
                                      seat.currentMemberName?.split(' ').first ?? 'Taken',
                                      style: const TextStyle(color: AppColors.textTertiary, fontSize: 9, fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryGreen),
                  ),
                  error: (e, _) => Center(
                    child: Text('Error loading seats: $e', style: const TextStyle(color: AppColors.accentRed)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilterChip(String status, String label, Color color) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedStatus = status);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.22) : AppColors.bgGlass,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : AppColors.borderSubtle,
            width: isSelected ? 1.4 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
