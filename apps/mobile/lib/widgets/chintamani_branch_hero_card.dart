import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../features/branch/domain/branch_model.dart';
import '../features/branch/providers/branch_provider.dart';
import '../features/dashboard/domain/dashboard_model.dart';
import '../routing/route_names.dart';

class ChintamaniBranchHeroCard extends ConsumerWidget {
  final DashboardStats? stats;

  const ChintamaniBranchHeroCard({super.key, this.stats});

  Future<void> _launchMaps(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBranch = ref.watch(activeBranchProvider);
    final isMehdawal = activeBranch.shortName.toLowerCase().contains('mehdawal');
    final totalSeats = isMehdawal ? 65 : 72;
    final occupied = stats != null && stats!.occupiedSeats > 0
        ? stats!.occupiedSeats
        : (isMehdawal ? 50 : 54);
    final available = totalSeats > occupied ? totalSeats - occupied : 15;
    final progress = (occupied / totalSeats).clamp(0.0, 1.0);

    final mapUrl = isMehdawal
        ? 'https://maps.app.goo.gl/6snL6CTrmxak4zsa8'
        : 'https://maps.app.goo.gl/RjjdGmMsiEKkJn7F7';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF141322),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF25233D),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Top Right Luxury Building Image Overlay (from Image 4)
              Positioned(
                top: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(30),
                  ),
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(0x88000000),
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.9],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Opacity(
                      opacity: 0.35,
                      child: Image.asset(
                        'assets/images/luxury_building.jpg',
                        width: 140,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Row: Logo/Emblem + Branch Name + Photos & Map Buttons
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Laurel Emblem Logo
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1F1C2E),
                            border: Border.all(
                              color: const Color(0xFFE5C07B).withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(3),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.auto_stories_rounded,
                                color: Color(0xFFE5C07B),
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Branch Name & System Title
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CHINTA MANI LIBRARY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                ' Branch',
                                style: const TextStyle(
                                  color: Color(0xFFE5C07B),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action Buttons: [ Photos ] & [ Map ]
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push(RouteNames.photos);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF221F35),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE5C07B).withValues(alpha: 0.35),
                                width: 0.9,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.photo_library_outlined, color: Color(0xFFE5C07B), size: 13),
                                SizedBox(width: 4),
                                Text(
                                  'Photos',
                                  style: TextStyle(
                                    color: Color(0xFFE5C07B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _launchMaps(mapUrl);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF221F35),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE5C07B).withValues(alpha: 0.35),
                                width: 0.9,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.navigation_rounded, color: Color(0xFFE5C07B), size: 13),
                                SizedBox(width: 4),
                                Text(
                                  'Map',
                                  style: TextStyle(
                                    color: Color(0xFFE5C07B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Hours & Occupancy Info Row
                    Row(
                      children: [
                        // Pulsing Green dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF22C55E),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'Open (06:00 AM – 11:00 PM (Daily))',
                            style: TextStyle(
                              color: Color(0xFFD4D4D8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          ' /  Seats Occupied',
                          style: const TextStyle(
                            color: Color(0xFFFDE047),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Gold Occupancy Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        height: 6,
                        width: double.infinity,
                        color: const Color(0xFF232238),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFD4AF37),
                                  Color(0xFFFBBF24),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Bottom Row: [ 15 Available ] [ 50 Occupied ] [ ⇄ Switch to Branch ]
                    Row(
                      children: [
                        // Available Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF14241B),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF22C55E).withValues(alpha: 0.35),
                              width: 0.9,
                            ),
                          ),
                          child: Text(
                            ' Available',
                            style: const TextStyle(
                              color: Color(0xFF4ADE80),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Occupied Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF282315),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE5C07B).withValues(alpha: 0.35),
                              width: 0.9,
                            ),
                          ),
                          child: Text(
                            ' Occupied',
                            style: const TextStyle(
                              color: Color(0xFFFDE047),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),

                        // Switch Branch Pill Button
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            final isMehd = activeBranch.id == Branch.mehdawalBranch.id;
                            ref.read(activeBranchProvider.notifier).state =
                                isMehd ? Branch.khalilabadBranch : Branch.mehdawalBranch;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Switched to ',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                duration: const Duration(milliseconds: 1400),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: const Color(0xFF1E1C2C),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF262217),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE5C07B),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.swap_horiz_rounded,
                                  color: Color(0xFFE5C07B),
                                  size: 15,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Switch to ',
                                  style: const TextStyle(
                                    color: Color(0xFFE5C07B),
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
            ],
          ),
        ),

        const SizedBox(height: 6),

        // Carousel Dot Indicators (showing 2 branches)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: !isMehdawal ? 20 : 6,
              height: 5,
              decoration: BoxDecoration(
                color: !isMehdawal ? const Color(0xFFE5C07B) : const Color(0xFF353348),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: isMehdawal ? 20 : 6,
              height: 5,
              decoration: BoxDecoration(
                color: isMehdawal ? const Color(0xFFE5C07B) : const Color(0xFF353348),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
