import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/branch/domain/branch_model.dart';
import '../features/branch/providers/branch_provider.dart';

class ThinBranchSwitcherCard extends ConsumerWidget {
  const ThinBranchSwitcherCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBranch = ref.watch(activeBranchProvider);
    final isMehdawal = activeBranch.shortName.toLowerCase().contains('mehdawal');
    final totalSeats = isMehdawal ? 65 : 72;
    final otherBranchName = isMehdawal ? 'Khalilabad' : 'Mehdawal';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          final nextBranch = isMehdawal ? Branch.khalilabadBranch : Branch.mehdawalBranch;
          ref.read(activeBranchProvider.notifier).state = nextBranch;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Switched to ${nextBranch.name}'),
              duration: const Duration(milliseconds: 1400),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF1E1E24),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF261E0E), // Deep luxury gold
                Color(0xFF161208),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5C07B).withValues(alpha: 0.4),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE5C07B).withValues(alpha: 0.12),
                blurRadius: 14,
                spreadRadius: 0,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left: 3D Golden Library Emblem / Icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0xFF523E15),
                      Color(0xFF1F1707),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFE5C07B).withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE5C07B).withValues(alpha: 0.25),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.account_balance_rounded,
                    color: Color(0xFFE5C07B),
                    size: 19,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Center: Branch Name + Capacity
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      activeBranch.name.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFE5C07B),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalSeats Total Seats • Main Hall • Tap to switch to $otherBranchName',
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Right: Golden Switch Button Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5C07B).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE5C07B).withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.swap_horiz_rounded,
                      color: Color(0xFFE5C07B),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Switch',
                      style: TextStyle(
                        color: Color(0xFFE5C07B),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
