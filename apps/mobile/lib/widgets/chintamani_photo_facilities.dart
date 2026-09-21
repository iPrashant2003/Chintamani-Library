import 'dart:async';
import 'package:flutter/material.dart';

class _FacilityItem {
  final String title;
  final String tag;
  final String subtitle;
  final String image;
  final IconData icon;
  final Color accentColor;

  const _FacilityItem({
    required this.title,
    required this.tag,
    required this.subtitle,
    required this.image,
    required this.icon,
    this.accentColor = const Color(0xFFD4AF37),
  });
}

class ChintamaniPhotoFacilities extends StatefulWidget {
  const ChintamaniPhotoFacilities({super.key});

  @override
  State<ChintamaniPhotoFacilities> createState() => _State();
}

class _State extends State<ChintamaniPhotoFacilities> {
  late final PageController _pc;
  int _current = 0;
  Timer? _timer;

  static const _items = [
    _FacilityItem(
      title: 'Lockers',
      tag: 'Secure & Private',
      subtitle: 'Heavy-duty digital key lockers for your books, notes & laptops',
      image: 'assets/images/luxury_lockers_hall.jpg',
      icon: Icons.lock_outline_rounded,
      accentColor: Color(0xFFD4AF37),
    ),
    _FacilityItem(
      title: 'Free Wi-Fi',
      tag: 'Upto 300 Mbps',
      subtitle: 'High-speed 5G optical fiber internet with unlimited access',
      image: 'assets/images/luxury_wifi.jpg',
      icon: Icons.wifi_rounded,
      accentColor: Color(0xFF4A90E2),
    ),
    _FacilityItem(
      title: 'Parking',
      tag: 'Free & Secure',
      subtitle: 'Dedicated two-wheeler & four-wheeler parking with CCTV',
      image: 'assets/images/luxury_building_grand.jpg',
      icon: Icons.local_parking_rounded,
      accentColor: Color(0xFF607D8B),
    ),
    _FacilityItem(
      title: 'Cafeteria',
      tag: 'Food & Beverages',
      subtitle: 'Pure hot & cold RO mineral water and hygienic refreshment lounge',
      image: 'assets/images/luxury_cafeteria_warm.jpg',
      icon: Icons.local_cafe_rounded,
      accentColor: Color(0xFF8B5E3C),
    ),
    _FacilityItem(
      title: 'Full AC Study Hall',
      tag: 'Silent Zone • 21°C',
      subtitle: 'Dual commercial inverter ACs maintaining peaceful quiet focus',
      image: 'assets/images/luxury_study_hall.jpg',
      icon: Icons.ac_unit_rounded,
      accentColor: Color(0xFF4A7A9B),
    ),
    _FacilityItem(
      title: 'Ergonomic Desk & Chairs',
      tag: 'Custom Study Seats',
      subtitle: 'Comfortable chairs with high-density lumbar cushion & individual power ports',
      image: 'assets/images/khalilabad_desks.jpg',
      icon: Icons.chair_alt_rounded,
      accentColor: Color(0xFF7B5E3C),
    ),
    _FacilityItem(
      title: 'Private Focus Cabins',
      tag: 'Exclusive Cubicles',
      subtitle: 'Dedicated sound-insulated pods for civil services prep',
      image: 'assets/images/mehdawal_study_hall.jpg',
      icon: Icons.door_front_door_outlined,
      accentColor: Color(0xFF6B5B9A),
    ),
    _FacilityItem(
      title: 'CCTV Security',
      tag: '24×7 Cloud Surveillance',
      subtitle: 'Complete 360° infrared cloud recorded security protection',
      image: 'assets/images/khalilabad_hall.jpg',
      icon: Icons.videocam_outlined,
      accentColor: Color(0xFF5A6E7F),
    ),
    _FacilityItem(
      title: '24/7 Service Available',
      tag: 'Always Open & Active',
      subtitle: 'Round-the-clock facility access and dedicated student assistance',
      image: 'assets/images/luxury_reception.jpg',
      icon: Icons.support_agent_rounded,
      accentColor: Color(0xFF4A8B6F),
    ),
    _FacilityItem(
      title: 'Clean Washrooms',
      tag: 'Hygienic & Sanitized',
      subtitle: 'Separately maintained, clean and fully sanitized washrooms',
      image: 'assets/images/luxury_building_grand.jpg',
      icon: Icons.wash_rounded,
      accentColor: Color(0xFF26A69A),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pc = PageController(viewportFraction: 0.93);
    // 2-second auto sliding
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_pc.hasClients) {
        final next = (_current + 1) % _items.length;
        _pc.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: const [
              Icon(Icons.account_balance_rounded, color: Color(0xFFD4AF37), size: 15),
              SizedBox(width: 8),
              Text(
                'Library Facilities',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Sliding Cards – same height/width, larger fonts inside
        SizedBox(
          height: 118,
          child: PageView.builder(
            controller: _pc,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _items.length,
            itemBuilder: (context, i) {
              final item = _items[i];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xCC110F18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Photo on right with natural fade
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: 140,
                        child: ShaderMask(
                          shaderCallback: (r) => const LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [Colors.black, Colors.transparent],
                            stops: [0.0, 0.92],
                          ).createShader(r),
                          blendMode: BlendMode.dstIn,
                          child: Opacity(
                            opacity: 0.50,
                            child: Image.asset(
                              item.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ),

                      // Card Content
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Premium 3D Circular Icon Disc (muted accent, no neon)
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    item.accentColor.withValues(alpha: 0.30),
                                    const Color(0xFF0E0B16),
                                  ],
                                ),
                                border: Border.all(
                                  color: item.accentColor.withValues(alpha: 0.50),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: item.accentColor.withValues(alpha: 0.18),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(item.icon, color: item.accentColor, size: 21),
                              ),
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Bigger title font as user requested
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,        // Increased from 14
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item.tag,
                                    style: TextStyle(
                                      color: item.accentColor,
                                      fontSize: 11,        // Increased from 10
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.subtitle,
                                    style: const TextStyle(
                                      color: Color(0xFF8A8A92),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 7),

        // Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_items.length, (i) {
            final active = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: active ? 14 : 4,
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
}
