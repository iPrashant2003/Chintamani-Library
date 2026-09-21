import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/theme_provider.dart';
import '../../../widgets/ambient_background.dart';
import '../../../widgets/chintamani_logo.dart';
import '../domain/branch_model.dart';

class BranchComparisonScreen extends ConsumerWidget {
  const BranchComparisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final khl = Branch.khalilabadBranch;
    final mhd = Branch.mehdawalBranch;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientBackground(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderSubtle, width: 1),
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const ChintaManiLogo(size: 32, showGlow: true),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Branch Comparison',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Khalilabad vs Mehdawal',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Overview Header Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      Expanded(child: _buildBranchSummaryCard(khl, const Color(0xFF00C2D7), 'Branch 1')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildBranchSummaryCard(mhd, const Color(0xFF38BDF8), 'Branch 2')),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Comparison Metrics
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildMetricSectionTitle('OPERATIONAL CAPACITY'),
                    _buildCompareBar(
                      title: 'Seat Occupancy',
                      khlValue: '${(khl.occupancyPercent * 100).toInt()}%',
                      khlFraction: khl.occupancyPercent,
                      mhdValue: '${(mhd.occupancyPercent * 100).toInt()}%',
                      mhdFraction: mhd.occupancyPercent,
                      accentColor: theme.primaryColor,
                    ),
                    _buildCompareBar(
                      title: 'Total Seats',
                      khlValue: '${khl.totalSeats}',
                      khlFraction: khl.totalSeats / 200,
                      mhdValue: '${mhd.totalSeats}',
                      mhdFraction: mhd.totalSeats / 200,
                      accentColor: const Color(0xFF10B981),
                    ),
                    _buildCompareBar(
                      title: 'Available Seats',
                      khlValue: '${khl.availableSeats}',
                      khlFraction: khl.availableSeats / 60,
                      mhdValue: '${mhd.availableSeats}',
                      mhdFraction: mhd.availableSeats / 60,
                      accentColor: const Color(0xFF22D3EE),
                    ),

                    const SizedBox(height: 16),
                    _buildMetricSectionTitle('STUDENT ENGAGEMENT'),
                    _buildCompareBar(
                      title: 'Today Check-ins',
                      khlValue: '94',
                      khlFraction: 94 / 120,
                      mhdValue: '68',
                      mhdFraction: 68 / 120,
                      accentColor: const Color(0xFF38BDF8),
                    ),
                    _buildCompareBar(
                      title: 'Active Members',
                      khlValue: '142',
                      khlFraction: 142 / 180,
                      mhdValue: '96',
                      mhdFraction: 96 / 180,
                      accentColor: const Color(0xFFF59E0B),
                    ),
                    _buildCompareBar(
                      title: 'Average Daily Hours',
                      khlValue: '6.8 hrs',
                      khlFraction: 6.8 / 10,
                      mhdValue: '6.2 hrs',
                      mhdFraction: 6.2 / 10,
                      accentColor: const Color(0xFFA855F7),
                    ),

                    const SizedBox(height: 16),
                    _buildMetricSectionTitle('FINANCES & RETENTION'),
                    _buildCompareBar(
                      title: 'Monthly Collection',
                      khlValue: '₹84,200',
                      khlFraction: 84200 / 100000,
                      mhdValue: '₹56,400',
                      mhdFraction: 56400 / 100000,
                      accentColor: const Color(0xFFFBBF24),
                    ),
                    _buildCompareBar(
                      title: 'Pending Dues',
                      khlValue: '₹4,800',
                      khlFraction: 4800 / 10000,
                      mhdValue: '₹3,200',
                      mhdFraction: 3200 / 10000,
                      accentColor: const Color(0xFFEF4444),
                    ),
                    _buildCompareBar(
                      title: 'Renewal Rate',
                      khlValue: '88%',
                      khlFraction: 0.88,
                      mhdValue: '84%',
                      mhdFraction: 0.84,
                      accentColor: const Color(0xFF14B8A6),
                    ),

                    const SizedBox(height: 30),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildBranchSummaryCard(Branch branch, Color color, String tag) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgCard.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                branch.shortName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                branch.name,
                style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompareBar({
    required String title,
    required String khlValue,
    required double khlFraction,
    required String mhdValue,
    required double mhdFraction,
    required Color accentColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
              ),
              Row(
                children: [
                  Text('KHL: $khlValue', style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w800)),
                  const Text('  •  ', style: TextStyle(color: AppColors.textTertiary)),
                  Text('MHD: $mhdValue', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Khalilabad bar
          Row(
            children: [
              const SizedBox(
                width: 76,
                child: Text('Khalilabad', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    children: [
                      Container(height: 8, color: Colors.white.withValues(alpha: 0.06)),
                      FractionallySizedBox(
                        widthFactor: khlFraction.clamp(0.0, 1.0),
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Mehdawal bar
          Row(
            children: [
              const SizedBox(
                width: 76,
                child: Text('Mehdawal', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    children: [
                      Container(height: 8, color: Colors.white.withValues(alpha: 0.06)),
                      FractionallySizedBox(
                        widthFactor: mhdFraction.clamp(0.0, 1.0),
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
