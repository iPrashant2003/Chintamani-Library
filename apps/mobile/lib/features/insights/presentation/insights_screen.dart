import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../branch/providers/branch_provider.dart';
import '../../dashboard/data/dashboard_repository.dart';
import '../../dashboard/domain/dashboard_model.dart';
import '../../../widgets/card_3d.dart';
import '../../../widgets/icon_3d.dart';
import '../../../widgets/chintamani_logo.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  int _selectedPeriod = 0; // 0: Today, 1: 7 Days, 2: 30 Days

  @override
  Widget build(BuildContext context) {
    final activeBranch = ref.watch(activeBranchProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final stats = statsAsync.value ?? const DashboardStats();

    final totalSeats = stats.totalSeats > 0 ? stats.totalSeats : activeBranch.totalSeats;
    final occupiedSeats = stats.occupiedSeats;
    final availableSeats = stats.availableSeats > 0 ? stats.availableSeats : (totalSeats - occupiedSeats).clamp(0, totalSeats);
    final occupancyPct = totalSeats > 0 ? ((occupiedSeats / totalSeats) * 100).round() : 0;

    final liveMembers = stats.liveMembers;
    final totalMembers = stats.totalMembers;
    final retentionRate = totalMembers > 0
        ? ((liveMembers / totalMembers) * 100).toStringAsFixed(1)
        : '100.0';
    final retentionFraction = totalMembers > 0
        ? (liveMembers / totalMembers).clamp(0.0, 1.0)
        : 1.0;
    final upcomingExpirations = stats.expiring1to3 + stats.expiring4to7;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const ChintaManiLogo(size: 28),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LIBRARY INSIGHTS',
                  style: TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  '${activeBranch.name} • Single Hall ($totalSeats Seats)',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: statsAsync.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.goldPrimary))
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Period Selector Chips
                Row(
                  children: [
                    _buildPeriodChip(0, 'Today Live'),
                    const SizedBox(width: 8),
                    _buildPeriodChip(1, 'Past 7 Days'),
                    const SizedBox(width: 8),
                    _buildPeriodChip(2, 'Monthly Trends'),
                  ],
                ),
                const SizedBox(height: 16),

                // 1. Single Hall Occupancy & Seat Utilization
                Card3D(
                  theme: Card3DTheme.blue,
                  borderRadius: 18,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.bluePrimary.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon3D(type: Icon3DType.insights, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'HALL OCCUPANCY & UTILIZATION',
                                  style: TextStyle(
                                    color: AppColors.blueAqua,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Text(
                                  '$occupiedSeats of $totalSeats Seats Active',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.bluePrimary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderBlue, width: 0.8),
                            ),
                            child: Text(
                              '$occupancyPct% Active',
                              style: const TextStyle(
                                color: AppColors.blueAqua,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildMetricBox('$occupiedSeats', 'Occupied', AppColors.goldPrimary),
                          const SizedBox(width: 10),
                          _buildMetricBox('$availableSeats', 'Available', AppColors.emeraldPrimary),
                          const SizedBox(width: 10),
                          _buildMetricBox('$totalSeats', 'Single Hall Cap', AppColors.blueAqua),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Dynamic hourly occupancy simulation scaled by real occupancy
                      _buildHourlyChart(occupancyPct / 100.0),
                      const SizedBox(height: 10),
                      Text(
                        '$availableSeats seats available for immediate allocation in Single Hall.',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Collection & Fee Recovery Velocity
                Card3D(
                  theme: Card3DTheme.gold,
                  borderRadius: 18,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.goldPrimary.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon3D(type: Icon3DType.finance, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'COLLECTION & REVENUE VELOCITY',
                                  style: TextStyle(
                                    color: AppColors.goldPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Text(
                                  'Monthly: ₹${stats.monthCollection.toInt()}',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildMetricBox('₹${stats.todayCollection.toInt()}', 'Today Collection', AppColors.emeraldPrimary),
                          const SizedBox(width: 10),
                          _buildMetricBox('₹${stats.monthCollection.toInt()}', 'This Month', AppColors.goldPrimary),
                          const SizedBox(width: 10),
                          _buildMetricBox('₹${stats.dueAmount.toInt()}', 'Overdue Dues', stats.dueAmount > 0 ? AppColors.redPrimary : AppColors.blueAqua),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Member Retention & Renewals
                Card3D(
                  theme: Card3DTheme.emerald,
                  borderRadius: 18,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.emeraldPrimary.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon3D(type: Icon3DType.members, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'MEMBERSHIP RETENTION & HEALTH',
                                  style: TextStyle(
                                    color: AppColors.emeraldPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Text(
                                  '$retentionRate% Active Retention Rate',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: retentionFraction,
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          valueColor: const AlwaysStoppedAnimation(AppColors.emeraldPrimary),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Active Members: $liveMembers', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                          Text('Total: $totalMembers', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                          Text('Renewals (≤7d): $upcomingExpirations', style: const TextStyle(color: AppColors.amberPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Intelligent Operational Alerts
                Card3D(
                  theme: Card3DTheme.red,
                  borderRadius: 18,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, color: AppColors.redPrimary, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'OPERATIONAL INSIGHT ALERTS',
                            style: TextStyle(
                              color: AppColors.redPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (stats.expiring1to3 > 0) ...[
                        _buildAlertRow(
                          Icons.timer_rounded,
                          'Urgent Subscriptions (${stats.expiring1to3} Members)',
                          '${stats.expiring1to3} members will expire within 1-3 days. Send renewal notices via WhatsApp to avoid seat release.',
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (occupancyPct >= 85) ...[
                        _buildAlertRow(
                          Icons.warning_amber_rounded,
                          'Study Hall Near Maximum Occupancy',
                          '${activeBranch.name} is currently at $occupancyPct% capacity ($occupiedSeats/$totalSeats seats occupied).',
                        ),
                        const SizedBox(height: 10),
                      ] else ...[
                        _buildAlertRow(
                          Icons.event_seat_rounded,
                          'Hall Capacity Available',
                          '$availableSeats of $totalSeats seats are available for new student enrolments.',
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (stats.dueAmount > 0) ...[
                        _buildAlertRow(
                          Icons.receipt_long_rounded,
                          'Pending Overdue Fees',
                          '₹${stats.dueAmount.toInt()} in overdue membership amounts recorded across expired accounts.',
                        ),
                        const SizedBox(height: 10),
                      ],
                      if (stats.todayCheckIns > 0) ...[
                        _buildAlertRow(
                          Icons.how_to_reg_rounded,
                          'Daily Study Attendance Active',
                          '${stats.todayCheckIns} student check-in records logged today.',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
    );
  }

  Widget _buildPeriodChip(int index, String label) {
    final isSel = _selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? AppColors.goldPrimary : const Color(0x1AFFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSel ? AppColors.goldPrimary : const Color(0x22FFFFFF),
              width: 1,
            ),
            boxShadow: isSel
                ? [
                    const BoxShadow(color: AppColors.goldGlow, blurRadius: 10),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSel ? Colors.black : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyChart(double occupancyRatio) {
    final hours = ['8A', '10A', '12P', '2P', '4P', '6P', '8P', '10P'];
    final baseMultipliers = [0.35, 0.55, 0.70, 0.95, 0.92, 0.88, 0.70, 0.40];
    final effectiveOccupancy = occupancyRatio > 0 ? occupancyRatio : 0.2;

    return SizedBox(
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(hours.length, (i) {
          final barFactor = (baseMultipliers[i] * effectiveOccupancy).clamp(0.12, 1.0);
          final isPeak = barFactor >= 0.75;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 24,
                height: 60 * barFactor,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: isPeak
                        ? [AppColors.goldPrimary, AppColors.goldBright]
                        : [AppColors.bluePrimary, AppColors.blueAqua],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                hours[i],
                style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMetricBox(String val, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 0.8),
        ),
        child: Column(
          children: [
            Text(
              val,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertRow(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.redPrimary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
