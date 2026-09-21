import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../branch/providers/branch_provider.dart';
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
                  activeBranch.name,
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
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Period Selector Chips in Atul Residency Gold & Obsidian
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

          // 1. Peak Study Hours Card (Sapphire Blue 3D Card)
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PEAK STUDY HOURS',
                            style: TextStyle(
                              color: AppColors.blueAqua,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            'Peak Occupancy between 2:00 PM – 7:30 PM',
                            style: TextStyle(
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
                      child: const Text(
                        '94% Peak',
                        style: TextStyle(
                          color: AppColors.blueAqua,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Hourly occupancy bar chart
                _buildHourlyChart(),
                const SizedBox(height: 12),
                const Text(
                  'Morning slots (8 AM - 12 PM) remain calm. Evening sessions reach maximum capacity.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Seat Turnover & Duration (Imperial Gold 3D Card)
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
                      child: const Icon3D(type: Icon3DType.seat, size: 28),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SEAT DURATION VELOCITY',
                            style: TextStyle(
                              color: AppColors.goldPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            'Average Study Duration: 5.4 Hours',
                            style: TextStyle(
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
                    _buildMetricBox('4.2h', 'Short Shift', AppColors.emeraldPrimary),
                    const SizedBox(width: 10),
                    _buildMetricBox('7.8h', 'Full Day Pass', AppColors.goldPrimary),
                    const SizedBox(width: 10),
                    _buildMetricBox('88%', 'Seat Turnover', AppColors.blueAqua),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Member Retention & Renewals (Jade Emerald 3D Card)
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MEMBERSHIP RETENTION',
                            style: TextStyle(
                              color: AppColors.emeraldPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            '91.8% Renewal Conversion Rate',
                            style: TextStyle(
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
                    value: 0.918,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: const AlwaysStoppedAnimation(AppColors.emeraldPrimary),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Active Members: 142', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    Text('Renewals Due This Week: 18', style: TextStyle(color: AppColors.amberPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Upcoming Action Recommendations (Ruby Red & Gold Card)
          Card3D(
            theme: Card3DTheme.red,
            borderRadius: 18,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: AppColors.redPrimary, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'AI STUDY HALL ALERTS',
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
                _buildAlertRow(Icons.event_seat_rounded, 'Demand Spike Predicted', 'Mehdawal branch digital wing expected to reach 100% capacity by 3:00 PM today.'),
                const SizedBox(height: 10),
                _buildAlertRow(Icons.lock_clock_rounded, 'Locker Expiration Alert', '5 members have locker rentals expiring in 48 hours. Auto-reminders queued.'),
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
                    BoxShadow(color: AppColors.goldGlow, blurRadius: 10),
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

  Widget _buildHourlyChart() {
    final hours = ['8A', '10A', '12P', '2P', '4P', '6P', '8P', '10P'];
    final heights = [0.35, 0.55, 0.65, 0.94, 0.90, 0.88, 0.72, 0.40];

    return SizedBox(
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(hours.length, (i) {
          final isPeak = heights[i] >= 0.85;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 24,
                height: 60 * heights[i],
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
