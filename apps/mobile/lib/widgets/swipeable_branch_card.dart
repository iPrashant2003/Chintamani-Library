import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/branch/domain/branch_model.dart';
import '../features/branch/providers/branch_provider.dart';
import '../features/dashboard/domain/dashboard_model.dart';

class SwipeableBranchCard extends ConsumerStatefulWidget {
  final DashboardStats? stats;
  const SwipeableBranchCard({super.key, this.stats});

  @override
  ConsumerState<SwipeableBranchCard> createState() => _SwipeableBranchCardState();
}

class _SwipeableBranchCardState extends ConsumerState<SwipeableBranchCard>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  final List<_BranchDef> _branches = [
    _BranchDef(
      id: 'khalilabad',
      name: 'Khalilabad',
      fullName: 'Khalilabad Branch',
      totalSeats: 72,
      image: 'assets/images/khalilabad_study_hall.jpg', // 3rd photo from user
      branch: Branch.khalilabadBranch,
    ),
    _BranchDef(
      id: 'mehdawal',
      name: 'Mehdawal',
      fullName: 'Mehdawal Branch',
      totalSeats: 65,
      image: 'assets/images/mehdawal_study_hall.jpg', // 2nd photo from user
      branch: Branch.mehdawalBranch,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  int _branchIndex(Branch b) =>
      b.id == Branch.khalilabadBranch.id ? 0 : 1;

  @override
  Widget build(BuildContext context) {
    final activeBranch = ref.watch(activeBranchProvider);
    final currentIdx = _branchIndex(activeBranch);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 94,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) {
              HapticFeedback.mediumImpact();
              final newBranch = _branches[idx].branch;
              ref.read(activeBranchProvider.notifier).state = newBranch;

              // Light mode toast notification
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF6EBD0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.swap_horiz_rounded,
                          color: Color(0xFFB4831B),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Switched to ${_branches[idx].fullName}',
                          style: const TextStyle(
                            color: Color(0xFF18181B),
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  duration: const Duration(milliseconds: 1300),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFFFAF9F5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                      width: 1.0,
                    ),
                  ),
                  elevation: 6,
                ),
              );
            },
            itemCount: _branches.length,
            itemBuilder: (context, idx) {
              final b = _branches[idx];
              final totalSeats = b.totalSeats;
              final occupied = widget.stats?.occupiedSeats ?? 0;
              final available = (totalSeats - occupied).clamp(0, totalSeats);
              final progress = (occupied / totalSeats).clamp(0.0, 1.0);

              return _buildBranchCard(b, occupied, available, totalSeats, progress);
            },
          ),
        ),
        const SizedBox(height: 5),

        // Page Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_branches.length, (i) {
            final active = i == currentIdx;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 16 : 4.5,
              height: 3.5,
              decoration: BoxDecoration(
                color: active ? const Color(0xFFD4AF37) : const Color(0xFF2C2410),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ],
    );
  }

  // Branch Card with real photo in BG + Vignette + Reduced Opacity (NO photo at right side)
  Widget _buildBranchCard(
    _BranchDef b,
    int occupied,
    int available,
    int totalSeats,
    double progress,
  ) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF0D0A14),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Photo as full card background – high brightness, no vignette (user request)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.70,
                  child: Image.asset(
                    b.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),

              // Light subtle dark gradient overlay for text legibility while keeping photo bright
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x40000000),
                        Color(0x75000000),
                      ],
                    ),
                  ),
                ),
              ),

              // Top gold specular accent line
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 1.2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      Color(0xFFD4AF37),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),

              // Card Content Across Entire Width
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Row 1: 3D Location icon + Branch Name + Open Hours + Slide Hint
                    Row(
                      children: [
                        // 3D Embossed Golden Pin Icon
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF3B2E15), Color(0xFF161108)],
                            ),
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                              width: 1.0,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFFE5C07B),
                              size: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          b.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),

                      ],
                    ),

                    // Row 2: Occupancy & Available pill & Slide Hint
                    Row(
                      children: [
                        Text(
                          '$occupied / $totalSeats',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Seats Occupied',
                          style: TextStyle(
                            color: Color(0xFF8A8A92),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0x3310B981),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            '$available Available',
                            style: const TextStyle(
                              color: Color(0xFF34D399),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                      ],
                    ),

                    // Row 3: Golden Progress Bar with Animated Pulse
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Container(
                        height: 4,
                        color: const Color(0xFF1E1A26),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0xFFB45309),
                                Color(0xFFFBBF24),
                              ]),
                            ),
                          ),
                        ),
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

class _BranchDef {
  final String id;
  final String name;
  final String fullName;
  final int totalSeats;
  final String image;
  final Branch branch;

  const _BranchDef({
    required this.id,
    required this.name,
    required this.fullName,
    required this.totalSeats,
    required this.image,
    required this.branch,
  });
}
