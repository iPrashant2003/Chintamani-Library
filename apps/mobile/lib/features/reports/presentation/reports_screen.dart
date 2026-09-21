import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/branch_switcher.dart';
import '../../../widgets/glass_button.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = [
      {
        'title': 'Members Directory Report',
        'desc': 'Complete list of active, expired, and upcoming members with seats & plans.',
        'icon': Icons.badge_outlined,
        'color': const Color(0xFF06B6D4),
      },
      {
        'title': 'Fee Collection & Revenue Report',
        'desc': 'Detailed financial breakdown by UPI, Cash, Card, and Bank with date filtering.',
        'icon': Icons.receipt_long,
        'color': AppColors.statusActive,
      },
      {
        'title': 'Outstanding Dues & Defaulters',
        'desc': 'All pending balances and overdue membership subscription amounts.',
        'icon': Icons.pending_actions,
        'color': AppColors.statusExpired,
      },
      {
        'title': 'Monthly Attendance Summary',
        'desc': 'Check-in logs, average daily attendance, peak hours, and student streaks.',
        'icon': Icons.calendar_month,
        'color': const Color(0xFF3B82F6),
      },
      {
        'title': 'Operational Expenses Report',
        'desc': 'Electricity, internet, maintenance, and staff salary statements.',
        'icon': Icons.trending_down,
        'color': const Color(0xFFF97316),
      },
      {
        'title': 'Seat & Locker Occupancy Report',
        'desc': 'Real-time utilization metrics for Floors A, B and Locker units.',
        'icon': Icons.chair_alt,
        'color': AppColors.accentNeon,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        titleSpacing: 12,
        title: const BranchSwitcher(),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final r = reports[index];
          final color = r['color'] as Color;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(r['icon'] as IconData, color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        r['title'] as String,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  r['desc'] as String,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GlassButton(
                      label: 'Export PDF',
                      icon: Icons.picture_as_pdf,
                      color: color,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.statusActive,
                            content: Text('Downloading "${r['title']}" PDF report...'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
