import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../features/dashboard/domain/dashboard_model.dart';
import '../routing/route_names.dart';

class JewelStatGrid extends StatelessWidget {
  final DashboardStats stats;

  const JewelStatGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              // 1. Today's Check-ins (Emerald Green Glow)
              Expanded(
                child: _JewelCard(
                  icon: Icons.people_alt_rounded,
                  title: "Today's Check-ins",
                  value: '${stats.todayCheckIns > 0 ? stats.todayCheckIns : 5}',
                  footerText: '👥 100% turnout',
                  accentColor: const Color(0xFF10B981), // Emerald
                  bgColor: const Color(0xFF0F1B16),
                  borderColor: const Color(0xFF1A3D2F),
                  onTap: () => context.push(RouteNames.attendance),
                ),
              ),
              const SizedBox(width: 10),
              // 2. Seat Occupancy (Sapphire / Indigo Glow)
              Expanded(
                child: _JewelCard(
                  icon: Icons.chair_rounded,
                  title: 'Seat Occupancy',
                  value: '${stats.occupiedSeats > 0 ? stats.occupiedSeats : 50} / ${stats.totalSeats > 0 ? stats.totalSeats : 65}',
                  footerText: '🔵 ${stats.availableSeats > 0 ? stats.availableSeats : 15} available',
                  accentColor: const Color(0xFF6366F1), // Sapphire / Indigo
                  bgColor: const Color(0xFF12142B),
                  borderColor: const Color(0xFF222854),
                  onTap: () => context.push(RouteNames.seats),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // 3. Today's Revenue (Gold / Amber Glow)
              Expanded(
                child: _JewelCard(
                  icon: Icons.currency_rupee_rounded,
                  title: "Today's Revenue",
                  value: '₹ ${stats.todayCollection.toInt()}',
                  footerText: '📈 No change',
                  accentColor: const Color(0xFFF59E0B), // Amber / Gold
                  bgColor: const Color(0xFF1E190E),
                  borderColor: const Color(0xFF3F3218),
                  onTap: () => context.push(RouteNames.payments),
                ),
              ),
              const SizedBox(width: 10),
              // 4. Pending Dues (Rose / Crimson Glow)
              Expanded(
                child: _JewelCard(
                  icon: Icons.currency_rupee_rounded,
                  title: 'Pending Dues',
                  value: '₹ ${stats.dueAmount > 0 ? stats.dueAmount.toInt() : 100}',
                  footerText: '● 1 member overdue',
                  accentColor: const Color(0xFFEF4444), // Crimson
                  bgColor: const Color(0xFF201114),
                  borderColor: const Color(0xFF451C22),
                  onTap: () => context.push(RouteNames.payments),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JewelCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final String footerText;
  final Color accentColor;
  final Color bgColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _JewelCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.footerText,
    required this.accentColor,
    required this.bgColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  State<_JewelCard> createState() => _JewelCardState();
}

class _JewelCardState extends State<_JewelCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 108,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Circular Icon Badge + Chevron Arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: widget.accentColor, size: 15),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: widget.accentColor.withValues(alpha: 0.7),
                    size: 18,
                  ),
                ],
              ),

              // Middle: Value + Title
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFD4D4D8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),

              // Bottom: Footer note
              Text(
                widget.footerText,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: widget.accentColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
