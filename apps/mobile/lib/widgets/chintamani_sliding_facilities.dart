import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'icon_3d.dart';

class MulticolourFacility {
  final String category;
  final String title;
  final String subtitle;
  final Icon3DType icon3dType;
  final Color primaryColor;
  final Color secondaryColor;
  final List<Color> bgGradient;
  final Color borderColor;
  final Color glowColor;

  const MulticolourFacility({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.icon3dType,
    required this.primaryColor,
    required this.secondaryColor,
    required this.bgGradient,
    required this.borderColor,
    required this.glowColor,
  });
}

class ChintaManiSlidingFacilities extends StatefulWidget {
  const ChintaManiSlidingFacilities({super.key});

  @override
  State<ChintaManiSlidingFacilities> createState() => _ChintaManiSlidingFacilitiesState();
}

class _ChintaManiSlidingFacilitiesState extends State<ChintaManiSlidingFacilities> {
  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;
  bool _isUserDragging = false;

  // 6 Multicolour Facility Cards: Red, Blue, Purple, Pink, Golden, Green
  static const List<MulticolourFacility> facilities = [
    // 1. RED
    MulticolourFacility(
      category: '100% UNINTERRUPTED UPTIME',
      title: 'HEAVY POWER BACKUP',
      subtitle: 'Automatic heavy silent generator & inverter with 0-sec cutover lag',
      icon3dType: Icon3DType.power,
      primaryColor: Color(0xFFEF4444),
      secondaryColor: Color(0xFFFCA5A5),
      bgGradient: [Color(0xFF330E12), Color(0xFF160507)],
      borderColor: Color(0xFF7F1D1D),
      glowColor: Color(0xFFEF4444),
    ),
    // 2. BLUE
    MulticolourFacility(
      category: 'GIGABIT HIGH BANDWIDTH',
      title: 'ULTRA HIGH-SPEED 5G WI-FI',
      subtitle: 'Dedicated dual optical fiber connections with zero dead zones',
      icon3dType: Icon3DType.wifi,
      primaryColor: Color(0xFF3B82F6),
      secondaryColor: Color(0xFF93C5FD),
      bgGradient: [Color(0xFF0F2042), Color(0xFF070F21)],
      borderColor: Color(0xFF1E3A8A),
      glowColor: Color(0xFF3B82F6),
    ),
    // 3. PURPLE
    MulticolourFacility(
      category: 'PERSONAL SECURE STORAGE',
      title: 'PERSONAL KEY LOCKERS',
      subtitle: 'Individual heavy-duty steel key lockers for laptops, books & bags',
      icon3dType: Icon3DType.locker,
      primaryColor: Color(0xFFA855F7),
      secondaryColor: Color(0xFFD8B4FE),
      bgGradient: [Color(0xFF240F3E), Color(0xFF0F041D)],
      borderColor: Color(0xFF581C87),
      glowColor: Color(0xFFA855F7),
    ),
    // 4. PINK
    MulticolourFacility(
      category: 'CONSTANT 22°C CLIMATE',
      title: 'FULL AC STUDY HALL',
      subtitle: 'Smart dual-compressor inverter air conditioning with dust filtration',
      icon3dType: Icon3DType.airConditioner,
      primaryColor: Color(0xFFEC4899),
      secondaryColor: Color(0xFFFBCFE8),
      bgGradient: [Color(0xFF360F25), Color(0xFF17030E)],
      borderColor: Color(0xFF831843),
      glowColor: Color(0xFFEC4899),
    ),
    // 5. GOLDEN
    MulticolourFacility(
      category: 'ABSOLUTE PIN-DROP SILENCE',
      title: '24/7 SILENT STUDY ZONE',
      subtitle: 'Individual acoustic partitions and strict supervisor discipline',
      icon3dType: Icon3DType.seat,
      primaryColor: Color(0xFFE5C07B),
      secondaryColor: Color(0xFFFEF08A),
      bgGradient: [Color(0xFF2E1F0A), Color(0xFF140D02)],
      borderColor: Color(0xFF78350F),
      glowColor: Color(0xFFE5C07B),
    ),
    // 6. GREEN
    MulticolourFacility(
      category: 'HEALTH & HYDRATION',
      title: 'PURE RO + MINERAL WATER',
      subtitle: 'Multistage reverse osmosis cold & ambient drinking water dispensers',
      icon3dType: Icon3DType.water,
      primaryColor: Color(0xFF10B981),
      secondaryColor: Color(0xFF6EE7B7),
      bgGradient: [Color(0xFF0C2B1C), Color(0xFF03140C)],
      borderColor: Color(0xFF064E3B),
      glowColor: Color(0xFF10B981),
    ),
  ];

  static const int _kInfiniteBase = 50000;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 1.0,
      initialPage: _kInfiniteBase,
    );
    _currentPage = _kInfiniteBase % facilities.length;
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(milliseconds: 2600), (_) {
      if (!mounted || _isUserDragging || !_pageController.hasClients) return;
      final nextRaw = (_pageController.page?.round() ?? _kInfiniteBase) + 1;
      _pageController.animateToPage(
        nextRaw,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title: FACILITIES
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'FACILITIES',
            style: TextStyle(
              color: Color(0xFFE5C07B),
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Multicolour Sliding Card Container
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 116,
            child: PageView.builder(
              controller: _pageController,
              itemCount: null,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (idx) {
                setState(() => _currentPage = idx % facilities.length);
              },
              itemBuilder: (context, index) {
                final item = facilities[index % facilities.length];

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: item.bgGradient,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: item.borderColor,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: item.glowColor.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
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
                      // 3D Graphic sphere container
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.4),
                          border: Border.all(
                            color: item.primaryColor.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: item.glowColor.withValues(alpha: 0.35),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon3D(
                            type: item.icon3dType,
                            size: 36,
                            color: item.primaryColor,
                            secondaryColor: item.secondaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Text Information
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.category,
                              style: TextStyle(
                                color: item.primaryColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 10.5,
                                height: 1.25,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
