import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CarouselSlide {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final Color accentColor;

  const CarouselSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.accentColor,
  });
}

class Library3DCarousel extends StatefulWidget {
  final List<CarouselSlide>? slides;
  final double height;
  final Color glowColor;

  const Library3DCarousel({
    super.key,
    this.slides,
    this.height = 200,
    this.glowColor = AppColors.primaryGreen,
  });

  @override
  State<Library3DCarousel> createState() => _Library3DCarouselState();
}

class _Library3DCarouselState extends State<Library3DCarousel> {
  late final PageController _pageCtrl;
  int _currentPage = 0;
  double _pageOffset = 0.0;
  Timer? _autoPlayTimer;
  bool _userInteracting = false;

  static const List<CarouselSlide> _defaultSlides = [
    CarouselSlide(
      title: 'Silent Reading Zones',
      subtitle: 'Premium air-conditioned study cabins with ergonomic chairs for deep focus',
      icon: Icons.self_improvement_rounded,
      gradientColors: [Color(0xFF064E3B), Color(0xFF065F46)],
      accentColor: Color(0xFF10B981),
    ),
    CarouselSlide(
      title: 'Digital Book Access',
      subtitle: 'Access 10,000+ e-books and research journals through our digital library portal',
      icon: Icons.menu_book_rounded,
      gradientColors: [Color(0xFF1E3A5F), Color(0xFF1D4ED8)],
      accentColor: Color(0xFF38BDF8),
    ),
    CarouselSlide(
      title: 'Flexible Memberships',
      subtitle: 'Daily, monthly, quarterly and annual plans starting at ₹80/day',
      icon: Icons.card_membership_rounded,
      gradientColors: [Color(0xFF4C1D95), Color(0xFF5B21B6)],
      accentColor: Color(0xFFA855F7),
    ),
    CarouselSlide(
      title: 'Secure Locker Storage',
      subtitle: 'Personal lockers available for all members – keep your belongings safe',
      icon: Icons.lock_outline_rounded,
      gradientColors: [Color(0xFF78350F), Color(0xFF92400E)],
      accentColor: Color(0xFFFBBF24),
    ),
    CarouselSlide(
      title: 'Smart QR Attendance',
      subtitle: 'Lightning-fast QR check-in & check-out with instant digital timestamp',
      icon: Icons.qr_code_scanner_rounded,
      gradientColors: [Color(0xFF0C4A6E), Color(0xFF075985)],
      accentColor: Color(0xFF22D3EE),
    ),
  ];

  List<CarouselSlide> get _slides => widget.slides ?? _defaultSlides;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.88, initialPage: 0);
    _pageCtrl.addListener(() {
      if (_pageCtrl.hasClients) {
        setState(() => _pageOffset = _pageCtrl.page ?? 0);
      }
    });
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_userInteracting && _pageCtrl.hasClients && mounted) {
        final next = (_currentPage + 1) % _slides.length;
        _pageCtrl.animateToPage(
          next,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: GestureDetector(
            onPanDown: (_) {
              _userInteracting = true;
              _autoPlayTimer?.cancel();
            },
            onPanEnd: (_) {
              _userInteracting = false;
              _startAutoPlay();
            },
            child: PageView.builder(
              controller: _pageCtrl,
              itemCount: _slides.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (ctx, index) {
                final slide = _slides[index];
                // Compute offset from center for 3D effect
                final diff = (_pageOffset - index).abs().clamp(0.0, 1.0);
                final isCenter = (_pageOffset - index).abs() < 0.5;
                final rotY = (_pageOffset - index) * 0.25; // radians
                final scaleVal = 1.0 - diff * 0.08;
                final opacityVal = 1.0 - diff * 0.4;

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (ctx, t, child) => child!,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(rotY)
                      ..scale(scaleVal),
                    alignment: FractionalOffset.center,
                    child: Opacity(
                      opacity: opacityVal.clamp(0.0, 1.0),
                      child: _buildSlideCard(slide, isCenter),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (i) {
            final isSelected = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isSelected ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: isSelected
                    ? widget.glowColor
                    : widget.glowColor.withValues(alpha: 0.3),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: widget.glowColor.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 0,
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

  Widget _buildSlideCard(CarouselSlide slide, bool isCenter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: slide.gradientColors
                    .map((c) => c.withValues(alpha: 0.85))
                    .toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: slide.accentColor.withValues(alpha: isCenter ? 0.5 : 0.2),
                width: isCenter ? 1.5 : 1.0,
              ),
              boxShadow: isCenter
                  ? [
                      BoxShadow(
                        color: slide.accentColor.withValues(alpha: 0.25),
                        blurRadius: 20,
                        spreadRadius: -2,
                      )
                    ]
                  : [],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: slide.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: slide.accentColor.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      slide.icon,
                      color: slide.accentColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slide.title,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          slide.subtitle,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.45,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: slide.accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: slide.accentColor.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Learn more',
                                style: TextStyle(
                                  color: slide.accentColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded,
                                  size: 12, color: slide.accentColor),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
