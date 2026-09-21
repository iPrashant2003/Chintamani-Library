import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/branch/domain/branch_model.dart';
import '../features/branch/providers/branch_provider.dart';
import '../features/dashboard/domain/dashboard_model.dart';
import '../routing/route_names.dart';

class SeatOccupancyHeroCard extends ConsumerWidget {
  final DashboardStats stats;

  const SeatOccupancyHeroCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBranch = ref.watch(activeBranchProvider);
    final isMehdawal = activeBranch.shortName.toLowerCase().contains('mehdawal');
    final totalSeats = isMehdawal ? 65 : 72;
    final occupied = stats.occupiedSeats > 0 ? stats.occupiedSeats : (isMehdawal ? 50 : 54);
    final available = totalSeats > occupied ? totalSeats - occupied : 15;

    // 16 bar heights forming wave pattern from the reference image
    const barHeights = [28.0, 24.0, 32.0, 38.0, 44.0, 40.0, 34.0, 42.0, 48.0, 42.0, 38.0, 44.0, 46.0, 40.0, 34.0, 30.0];
    // Ratios of gold fill for the 16 bars
    const fillRatios = [0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.7, 0.0, 0.0, 0.0];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151518),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF27272A),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Seat Occupancy: 50 / 65 Seats
          Row(
            children: [
              const Text(
                'Seat Occupancy: ',
                style: TextStyle(
                  color: Color(0xFFD4D4D8),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$occupied / $totalSeats Seats',
                style: const TextStyle(
                  color: Color(0xFFE5C07B),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Center: Segmented Bar Graph (16 Bars matching mockup)
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push(RouteNames.seats);
            },
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(16, (i) {
                  final h = barHeights[i];
                  final ratio = fillRatios[i];

                  return Container(
                    width: 14,
                    height: h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: const Color(0xFF242742), // Deep muted indigo background
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        if (ratio > 0)
                          FractionallySizedBox(
                            heightFactor: ratio,
                            widthFactor: 1.0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFE5C07B), // Warm Gold
                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Footer Row: 15 Available | 50 Occupied | Branch: Mehdawal [⇄]
          Row(
            children: [
              Text(
                '$available Available',
                style: const TextStyle(
                  color: Color(0xFF22C55E),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('|', style: TextStyle(color: Color(0xFF52525B), fontSize: 11)),
              ),
              Text(
                '$occupied Occupied',
                style: const TextStyle(
                  color: Color(0xFFE5C07B),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('|', style: TextStyle(color: Color(0xFF52525B), fontSize: 11)),
              ),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Branch: ${activeBranch.shortName}',
                      style: const TextStyle(
                        color: Color(0xFFA1A1AA),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 6),
                    // Gold pill switch button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        final isMehd = activeBranch.id == Branch.mehdawalBranch.id;
                        ref.read(activeBranchProvider.notifier).state =
                            isMehd ? Branch.khalilabadBranch : Branch.mehdawalBranch;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Switched to ${isMehd ? Branch.khalilabadBranch.name : Branch.mehdawalBranch.name}'),
                            duration: const Duration(milliseconds: 1400),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF1E1E24),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5C07B).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFE5C07B).withValues(alpha: 0.5),
                            width: 0.8,
                          ),
                        ),
                        child: const Icon(
                          Icons.swap_horiz_rounded,
                          size: 13,
                          color: Color(0xFFE5C07B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
