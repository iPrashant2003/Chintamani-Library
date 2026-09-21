import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../routing/route_names.dart';

class QuickActionsGoldBar extends StatelessWidget {
  const QuickActionsGoldBar({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(
        label: 'Add Member',
        icon: Icons.person_add_outlined,
        onTap: () => context.push(RouteNames.addMember),
      ),
      _ActionItem(
        label: 'Collect Fee',
        icon: Icons.currency_rupee_rounded,
        onTap: () => context.push(RouteNames.recordPayment),
      ),
      _ActionItem(
        label: 'Scan QR',
        icon: Icons.qr_code_scanner_rounded,
        onTap: () => context.push(RouteNames.qr),
      ),
      _ActionItem(
        label: 'Insights',
        icon: Icons.trending_up_rounded,
        onTap: () => context.push(RouteNames.insights),
      ),
      _ActionItem(
        label: 'More',
        icon: Icons.more_horiz_rounded,
        onTap: () => context.push(RouteNames.more),
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141417),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF27272A),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  Icon(Icons.flash_on_rounded, color: Color(0xFFE5C07B), size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Text(
                'Get things done faster',
                style: TextStyle(
                  color: Color(0xFF71717A),
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 5 Circular Gold Outline Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: actions.map((act) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  act.onTap();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1D1B17),
                        border: Border.all(
                          color: const Color(0xFFE5C07B).withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE5C07B).withValues(alpha: 0.15),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(act.icon, color: const Color(0xFFE5C07B), size: 20),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      act.label,
                      style: const TextStyle(
                        color: Color(0xFFD4D4D8),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ActionItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}
