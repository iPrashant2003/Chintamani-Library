import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';

class FacilityItem {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  const FacilityItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}

class ChintaManiExperienceCarousel extends ConsumerWidget {
  const ChintaManiExperienceCarousel({super.key});

  static const List<FacilityItem> facilities = [
    FacilityItem(
      title: 'Study Space',
      description: 'Comfortable and focused study environment with ergonomic seating',
      icon: Icons.menu_book_rounded,
      accentColor: Color(0xFF00C2D7),
    ),
    FacilityItem(
      title: 'AC Study Hall',
      description: 'Fully climate-controlled halls for pleasant long study sessions',
      icon: Icons.ac_unit_rounded,
      accentColor: Color(0xFF38BDF8),
    ),
    FacilityItem(
      title: 'Dedicated Seats',
      description: 'Your own reserved daily desk with individual charging ports',
      icon: Icons.event_seat_rounded,
      accentColor: Color(0xFF10B981),
    ),
    FacilityItem(
      title: 'High-Speed Wi-Fi',
      description: 'Blazing fast optical fiber connection for online lectures and research',
      icon: Icons.wifi_rounded,
      accentColor: Color(0xFF22D3EE),
    ),
    FacilityItem(
      title: 'Power Backup',
      description: '100% 24/7 generator and inverter power backup for zero interruptions',
      icon: Icons.bolt_rounded,
      accentColor: Color(0xFFFBBF24),
    ),
    FacilityItem(
      title: 'Silent Environment',
      description: 'Pin-drop silence zone designed exclusively for competitive exams',
      icon: Icons.volume_off_rounded,
      accentColor: Color(0xFFA855F7),
    ),
    FacilityItem(
      title: 'CCTV Security',
      description: 'Continuous 24/7 surveillance ensuring safety of students and belongings',
      icon: Icons.videocam_rounded,
      accentColor: Color(0xFFF43F5E),
    ),
    FacilityItem(
      title: 'Clean Environment',
      description: 'Daily sanitized premises, RO drinking water, and clean restrooms',
      icon: Icons.cleaning_services_rounded,
      accentColor: Color(0xFF14B8A6),
    ),
    FacilityItem(
      title: 'Locker Facility',
      description: 'Personal lockable units to safely store heavy books and laptops',
      icon: Icons.lock_outline_rounded,
      accentColor: Color(0xFFD97706),
    ),
    FacilityItem(
      title: 'Digital Membership',
      description: 'Quick paperless renewals, fee history, and automated validity alerts',
      icon: Icons.card_membership_rounded,
      accentColor: Color(0xFF6366F1),
    ),
    FacilityItem(
      title: 'Seat Availability',
      description: 'Real-time live occupancy check before visiting the library',
      icon: Icons.airline_seat_recline_normal_rounded,
      accentColor: Color(0xFF06B6D4),
    ),
    FacilityItem(
      title: 'Smart Attendance',
      description: 'Instant contactless QR check-in & checkout tracking with logs',
      icon: Icons.qr_code_scanner_rounded,
      accentColor: Color(0xFF4ADE80),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: theme.glowColor.withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Chinta Mani Experience',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3), width: 1),
                ),
                child: Text(
                  '${facilities.length} Facilities',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: facilities.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = facilities[index];
              return _FacilityCard(item: item, themePrimary: theme.primaryColor);
            },
          ),
        ),
      ],
    );
  }
}

class _FacilityCard extends StatefulWidget {
  final FacilityItem item;
  final Color themePrimary;

  const _FacilityCard({required this.item, required this.themePrimary});

  @override
  State<_FacilityCard> createState() => _FacilityCardState();
}

class _FacilityCardState extends State<_FacilityCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => HapticFeedback.selectionClick(),
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 180),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      item.accentColor.withValues(alpha: _isHovered ? 0.20 : 0.12),
                      AppColors.bgCard.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: item.accentColor.withValues(alpha: _isHovered ? 0.6 : 0.25),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: item.accentColor.withValues(alpha: _isHovered ? 0.25 : 0.08),
                      blurRadius: 12,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: item.accentColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: item.accentColor.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            item.icon,
                            color: item.accentColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      item.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        height: 1.35,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
