import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/branch/domain/branch_model.dart';
import '../features/branch/providers/branch_provider.dart';
import '../features/dashboard/domain/dashboard_model.dart';
import '../routing/route_names.dart';
import '../theme/app_colors.dart';

class BranchSwitcherCompactCard extends ConsumerWidget {
  final DashboardStats? stats;

  const BranchSwitcherCompactCard({super.key, this.stats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBranch = ref.watch(activeBranchProvider);
    final isMehdawal = activeBranch.shortName.toLowerCase().contains('mehdawal');
    final totalSeats = isMehdawal ? 65 : 72;
    final occupied = stats != null && stats!.occupiedSeats > 0
        ? stats!.occupiedSeats
        : (isMehdawal ? 50 : 54);
    final available = totalSeats > occupied ? totalSeats - occupied : 15;

    final photoAsset = isMehdawal
        ? 'assets/images/mehdawal_hall.jpg'
        : 'assets/images/khalilabad_hall.jpg';

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        final isMehd = activeBranch.id == Branch.mehdawalBranch.id;
        ref.read(activeBranchProvider.notifier).state =
            isMehd ? Branch.khalilabadBranch : Branch.mehdawalBranch;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to ${isMehd ? Branch.khalilabadBranch.name : Branch.mehdawalBranch.name}'),
            duration: const Duration(milliseconds: 1200),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF1E1E24),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF141417),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF27272A),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Branch Name + Location Pin
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFFE5C07B),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${activeBranch.shortName} Branch',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Open Hours
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'Open  06:00 AM – 11:00 PM',
                        style: TextStyle(
                          color: Color(0xFFA1A1AA),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Seats Occupied + Available Pill
                  Row(
                    children: [
                      Text(
                        '$occupied / $totalSeats',
                        style: const TextStyle(
                          color: Color(0xFFE5C07B),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Text(
                        ' Seats Occupied',
                        style: TextStyle(
                          color: Color(0xFF71717A),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF22C55E).withValues(alpha: 0.4),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '$available Available',
                          style: const TextStyle(
                            color: Color(0xFF22C55E),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Right Thumbnail Photo + Switch Badge
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    photoAsset,
                    width: 64,
                    height: 58,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 64,
                      height: 58,
                      color: const Color(0xFF24242A),
                      child: const Icon(Icons.business_rounded, color: Color(0xFFE5C07B), size: 24),
                    ),
                  ),
                ),
                // Small Switch Pill
                Container(
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141417).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE5C07B), width: 0.8),
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    size: 11,
                    color: Color(0xFFE5C07B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
