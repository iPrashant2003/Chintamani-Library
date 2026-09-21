import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../routing/route_names.dart';
import '../theme/app_colors.dart';
import '../features/branch/domain/branch_model.dart';
import '../features/branch/providers/branch_provider.dart';
import 'chintamani_logo.dart';
import 'card_3d.dart';
import 'icon_3d.dart';

class BranchSwitcherCard extends ConsumerStatefulWidget {
  const BranchSwitcherCard({super.key});

  @override
  ConsumerState<BranchSwitcherCard> createState() => _BranchSwitcherCardState();
}

class _BranchSwitcherCardState extends ConsumerState<BranchSwitcherCard> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    final active = ref.read(activeBranchProvider);
    final initialIndex = active.id == Branch.mehdawalBranch.id ? 1 : 0;
    _pageController = PageController(initialPage: initialIndex, viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openDirections(String mapUrl) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(mapUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _switchBranch(int targetIndex) {
    HapticFeedback.selectionClick();
    _pageController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeBranch = ref.watch(activeBranchProvider);
    final branches = Branch.officialBranches;

    final activeIndex = activeBranch.id == Branch.mehdawalBranch.id ? 1 : 0;
    if (_pageController.hasClients &&
        _pageController.page?.round() != activeIndex &&
        !_pageController.position.isScrollingNotifier.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.animateToPage(
            activeIndex,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }

    return Column(
      children: [
        SizedBox(
          height: 155,
          child: PageView.builder(
            controller: _pageController,
            itemCount: branches.length,
            onPageChanged: (index) {
              HapticFeedback.selectionClick();
              ref.read(activeBranchProvider.notifier).state = branches[index];
            },
            itemBuilder: (context, index) {
              final branch = branches[index];
              final isCurrent = branch.id == activeBranch.id;
              final targetNextIndex = index == 0 ? 1 : 0;
              final otherBranchName = branches[targetNextIndex].shortName;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Card3D(
                  theme: Card3DTheme.gold, // Royal Imperial Gold Theme for Branch Card
                  borderRadius: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Logo + Branch Name + Directions Action
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ChintaManiLogo(
                            size: 34,
                            showGlow: true,
                            showCircularBackground: true,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  branch.name.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  softWrap: true,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  branch.subtitle,
                                  style: const TextStyle(
                                    color: AppColors.goldPrimary,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Action buttons: Photos & Directions
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Photos Gallery Button
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  context.push(RouteNames.photos);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.goldPrimary.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.goldPrimary.withValues(alpha: 0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.photo_library_rounded,
                                        size: 13,
                                        color: AppColors.goldLight,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Photos',
                                        style: TextStyle(
                                          color: AppColors.goldLight,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Directions Button in Imperial Gold
                              GestureDetector(
                                onTap: () => _openDirections(branch.mapUrl),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.goldPrimary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.goldPrimary.withValues(alpha: 0.35),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.navigation_outlined,
                                        size: 13,
                                        color: AppColors.goldPrimary,
                                      ),
                                      SizedBox(width: 3),
                                      Text(
                                        'Map',
                                        style: TextStyle(
                                          color: AppColors.goldLight,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
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

                      // Middle Row: Status Badge & Seat Occupancy
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.emeraldPrimary,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.emeraldPrimary,
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${branch.status} (${branch.openingHours})',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${branch.occupiedSeats} / ${branch.totalSeats} Seats Occupied',
                            style: const TextStyle(
                              color: AppColors.goldPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      // Linear Occupancy Bar in Imperial Gold & Sapphire
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          children: [
                            Container(
                              height: 6,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                            FractionallySizedBox(
                              widthFactor: branch.occupancyPercent,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.goldPrimary,
                                      AppColors.goldBright,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppColors.goldGlow,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom Row: Stats Summary & Switch Branch Action
                      Row(
                        children: [
                          _buildMiniBadge('${branch.availableSeats}', 'Available', AppColors.emeraldPrimary),
                          const SizedBox(width: 8),
                          _buildMiniBadge('${branch.occupiedSeats}', 'Occupied', AppColors.goldPrimary),
                          const Spacer(),
                          // Switch Branch Button
                          GestureDetector(
                            onTap: () => _switchBranch(targetNextIndex),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.goldPrimary.withValues(alpha: 0.25),
                                    AppColors.goldPrimary.withValues(alpha: 0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.goldPrimary.withValues(alpha: 0.45),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.swap_horiz_rounded,
                                    size: 16,
                                    color: AppColors.goldPrimary,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Switch to $otherBranchName',
                                    style: const TextStyle(
                                      color: AppColors.goldLight,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
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
                ),
              );
            },
          ),
        ),

        // Indicator Dots for branches
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(branches.length, (idx) {
            final isSel = idx == activeIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isSel ? 20 : 6,
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: isSel ? AppColors.goldPrimary : Colors.white.withValues(alpha: 0.2),
                boxShadow: isSel
                    ? const [
                        BoxShadow(
                          color: AppColors.goldGlow,
                          blurRadius: 6,
                        )
                      ]
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMiniBadge(String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
