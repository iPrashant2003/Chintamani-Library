import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/ambient_background.dart';
import '../../../widgets/branch_switcher.dart';
import '../../../widgets/icon_3d.dart';
import '../data/locker_repository.dart';
import '../domain/locker_model.dart';

class LockersScreen extends ConsumerStatefulWidget {
  const LockersScreen({super.key});

  @override
  ConsumerState<LockersScreen> createState() => _LockersScreenState();
}

class _LockersScreenState extends ConsumerState<LockersScreen> {
  String? _selectedLockerId;

  Color _getLockerColor(Locker locker) {
    if (locker.status == 'MAINTENANCE') return AppColors.accentRed;
    if (locker.isOccupied) return AppColors.accentPurple;
    return AppColors.primaryGreen;
  }

  void _showLockerDetails(BuildContext context, Locker locker) {
    HapticFeedback.lightImpact();
    setState(() => _selectedLockerId = locker.id);

    final color = _getLockerColor(locker);

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
                            color: color.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                            border: Border.all(color: color.withValues(alpha: 0.3)),
                          ),
                          child: Icon(Icons.lock_rounded, color: color, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Locker ${locker.lockerNumber}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const Text(
                              'Personal Secure Storage',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        locker.isOccupied ? 'ASSIGNED' : 'UNASSIGNED',
                        style: TextStyle(
                          color: color,
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
                Text(
                  locker.isOccupied
                      ? 'Allocated to: ${locker.currentMemberName ?? 'Active Student'}'
                      : 'Unassigned • Currently available for scholar allocation.',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                if (locker.isOccupied) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.18),
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.lock_open_rounded, size: 18),
                      label: const Text('Deallocate Locker', style: TextStyle(fontWeight: FontWeight.bold)),
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
                            title: const Text('Deallocate Locker', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            content: Text(
                              'Are you sure you want to deallocate Locker ${locker.lockerNumber}?\n\n'
                              '${locker.currentMemberName != null ? '"${locker.currentMemberName}" will be unlinked from this locker.' : ''}\n\n'
                              'The locker will become AVAILABLE. The member\'s subscription will remain active.',
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
                          final result = await ref.read(lockerRepositoryProvider).deallocateLocker(locker.id);
                          ref.invalidate(lockersListProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message'] ?? 'Locker ${locker.lockerNumber} deallocated'),
                                backgroundColor: result['success'] == true ? const Color(0xFF059669) : const Color(0xFFEF4444),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      if (mounted) setState(() => _selectedLockerId = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lockersAsync = ref.watch(lockersListProvider);

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
                      'Locker Vault',
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
                        ref.invalidate(lockersListProvider);
                      },
                    ),
                  ],
                ),
              ),

              // Legend & Standard Price
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bgGlass,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Legend(color: AppColors.primaryGreen, label: 'Unassigned'),
                    _Legend(color: AppColors.accentPurple, label: 'Assigned'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0x228B5CF6),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0x558B5CF6), width: 0.8),
                      ),
                      child: const Text(
                        '9 Lockers • ₹200/mo',
                        style: TextStyle(color: Color(0xFFC4B5FD), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Locker Grid (3x3 for exactly 9 lockers)
              Expanded(
                child: lockersAsync.when(
                  data: (lockers) {
                    return GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 90, top: 4),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1.05,
                      ),
                      itemCount: lockers.length,
                      itemBuilder: (context, index) {
                        final locker = lockers[index];
                        final color = _getLockerColor(locker);
                        final isSelected = _selectedLockerId == locker.id;

                        return GestureDetector(
                          onTap: () => _showLockerDetails(context, locker),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryGreen.withValues(alpha: 0.28)
                                  : color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AppColors.accentNeon : color.withValues(alpha: 0.35),
                                width: isSelected ? 1.8 : 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isSelected ? AppColors.accentNeon : color).withValues(alpha: isSelected ? 0.35 : 0.08),
                                  blurRadius: isSelected ? 10 : 6,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon3D(
                                  type: Icon3DType.locker,
                                  size: 24,
                                  color: isSelected ? AppColors.goldBright : color,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  locker.lockerNumber,
                                  style: TextStyle(
                                    color: isSelected ? AppColors.goldBright : color,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    locker.isOccupied
                                        ? (locker.currentMemberName?.split(' ').first ?? 'Assigned')
                                        : 'Unassigned',
                                    style: TextStyle(
                                      color: locker.isOccupied ? AppColors.textTertiary : AppColors.primaryGreen.withValues(alpha: 0.75),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
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
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                  error: (e, _) => Center(child: Text('Error loading lockers: $e', style: const TextStyle(color: AppColors.accentRed))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

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
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
