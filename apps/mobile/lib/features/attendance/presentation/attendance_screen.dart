import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/ambient_background.dart';
import '../../../widgets/branch_switcher.dart';
import '../../../widgets/search_bar_widget.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/glass_card.dart';
import '../data/attendance_repository.dart';
import '../../branch/providers/branch_provider.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  String _searchQuery = '';

  void _showManualMarkDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    final memberCodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: AppColors.bgDarkElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderEmerald, width: 1.2),
          ),
          title: const Row(
            children: [
              Icon(Icons.how_to_reg_rounded, color: AppColors.accentNeon, size: 22),
              SizedBox(width: 8),
              Text(
                'Mark Attendance',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter student code or name to record check-in/out:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: memberCodeController,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. CML-942810',
                  hintStyle: const TextStyle(color: AppColors.textDisabled),
                  filled: true,
                  fillColor: AppColors.bgGlass,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryGreen),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFACC15),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final code = memberCodeController.text.trim();
                if (code.isNotEmpty) {
                  Navigator.pop(ctx);
                  final branch = ref.read(activeBranchProvider);
                  try {
                    await ref.read(attendanceRepositoryProvider).markAttendance(
                      memberId: code,
                      branchId: branch.id,
                    );
                    ref.invalidate(todayAttendanceProvider);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Attendance recorded for $code!')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(todayAttendanceProvider);

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
                      'Daily Attendance',
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
                      icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.accentElectricBlue, size: 22),
                      tooltip: 'QR Attendance',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.push(RouteNames.qr);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 22),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ref.invalidate(todayAttendanceProvider);
                      },
                    ),
                  ],
                ),
              ),

              // Attendance Circular / Pulse Dashboard Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: attendanceAsync.maybeWhen(
                  data: (list) {
                    final totalCheckins = list.length;
                    final insideNow = list.where((a) => a.isCurrentlyInside).length;
                    final checkedOut = totalCheckins - insideNow;

                    return GlassCard(
                      padding: const EdgeInsets.all(16),
                      borderColor: AppColors.borderBlue,
                      glowColor: AppColors.accentElectricBlue.withValues(alpha: 0.1),
                      child: Row(
                        children: [
                          // Circular Progress with inside vs out
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: totalCheckins > 0 ? (insideNow / totalCheckins).clamp(0.0, 1.0) : 0,
                                  strokeWidth: 5,
                                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                                  color: AppColors.accentElectricBlue,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$insideNow',
                                      style: const TextStyle(
                                        color: AppColors.accentElectricBlue,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const Text('Inside', style: TextStyle(color: AppColors.textTertiary, fontSize: 9)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('EEEE, dd MMM yyyy').format(DateTime.now()),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _buildStatPill('Total Check-ins', '$totalCheckins', AppColors.accentNeon),
                                    const SizedBox(width: 12),
                                    _buildStatPill('Departed', '$checkedOut', AppColors.textSecondary),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
              ),

              const SizedBox(height: 12),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SearchBarWidget(
                  hintText: 'Search attendee name or code...',
                  onChanged: (q) => setState(() => _searchQuery = q),
                  onClear: () => setState(() => _searchQuery = ''),
                ),
              ),

              const SizedBox(height: 10),

              // List of Check-ins
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.accentNeon,
                  backgroundColor: AppColors.bgCard,
                  onRefresh: () async => ref.invalidate(todayAttendanceProvider),
                  child: attendanceAsync.when(
                    data: (attendances) {
                      final filtered = _searchQuery.isEmpty
                          ? attendances
                          : attendances.where((a) =>
                              (a.memberName ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
                              (a.memberCode ?? '').toLowerCase().contains(_searchQuery.toLowerCase())).toList();

                      if (filtered.isEmpty) {
                        return EmptyState(
                          icon: Icons.access_time_rounded,
                          title: 'No check-ins today',
                          subtitle: _searchQuery.isNotEmpty
                              ? 'No attendee matches "$_searchQuery"'
                              : 'Tap "Mark Attendance" or scan QR code to register entrance.',
                          actionLabel: 'Mark Attendance',
                          onAction: () => _showManualMarkDialog(context),
                        );
                      }

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 90, top: 4),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final att = filtered[index];
                          final isInside = att.isCurrentlyInside;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: GlassCard(
                              padding: const EdgeInsets.all(12),
                              borderColor: isInside ? AppColors.borderBlue : AppColors.borderSubtle,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isInside
                                          ? AppColors.accentElectricBlue.withValues(alpha: 0.15)
                                          : Colors.white.withValues(alpha: 0.05),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isInside ? Icons.login_rounded : Icons.logout_rounded,
                                      color: isInside ? AppColors.accentElectricBlue : AppColors.textTertiary,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          att.memberName ?? 'Student',
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          att.memberCode ?? 'CML',
                                          style: const TextStyle(
                                            color: AppColors.textGreen,
                                            fontSize: 11,
                                            fontFamily: 'monospace',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'In: ${DateFormat('hh:mm a').format(att.checkIn)}',
                                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                      if (att.checkOut != null)
                                        Text(
                                          'Out: ${DateFormat('hh:mm a').format(att.checkOut!)}',
                                          style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
                                        )
                                      else
                                        Container(
                                          margin: const EdgeInsets.only(top: 2),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentElectricBlue.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'INSIDE',
                                            style: TextStyle(
                                              color: AppColors.accentElectricBlue,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                    error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.accentRed))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFFFACC15),
          foregroundColor: Colors.black,
          elevation: 4,
          onPressed: () => _showManualMarkDialog(context),
          icon: const Icon(Icons.how_to_reg_rounded),
          label: const Text('Mark Attendance', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
        ),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

