import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../routing/route_names.dart';

class QuickAccessItem {
  final String title;
  final String subtitle;
  final String info;
  final IconData icon;
  final Color accentColor;
  final String route;
  final List<QuickActionBtn> actions;

  const QuickAccessItem({
    required this.title,
    required this.subtitle,
    required this.info,
    required this.icon,
    required this.accentColor,
    required this.route,
    required this.actions,
  });
}

class QuickActionBtn {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const QuickActionBtn({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class QuickAccessSection extends StatelessWidget {
  const QuickAccessSection({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      QuickAccessItem(
        title: 'Add New Scholar',
        subtitle: 'khalilabad & mehdawal',
        info: 'Admission: 6 hrs / 12 hrs',
        icon: Icons.person_add_rounded,
        accentColor: const Color(0xFFE5C07B),
        route: RouteNames.addMember,
        actions: [
          QuickActionBtn(
            label: 'Profile',
            icon: Icons.badge_outlined,
            onTap: () => context.push(RouteNames.members),
          ),
          QuickActionBtn(
            label: 'Enroll',
            icon: Icons.assignment_ind_outlined,
            onTap: () => context.push(RouteNames.addMember),
          ),
          QuickActionBtn(
            label: 'List',
            icon: Icons.format_list_bulleted_rounded,
            onTap: () => context.push(RouteNames.members),
          ),
        ],
      ),
      QuickAccessItem(
        title: 'Fee Collection',
        subtitle: 'cash, upi & dues',
        info: 'Payment: Daily settlement',
        icon: Icons.currency_rupee_rounded,
        accentColor: const Color(0xFF22C55E),
        route: RouteNames.recordPayment,
        actions: [
          QuickActionBtn(
            label: 'Collect',
            icon: Icons.payments_outlined,
            onTap: () => context.push(RouteNames.recordPayment),
          ),
          QuickActionBtn(
            label: 'Dues',
            icon: Icons.receipt_long_outlined,
            onTap: () => context.push(RouteNames.payments),
          ),
          QuickActionBtn(
            label: 'History',
            icon: Icons.history_rounded,
            onTap: () => context.push(RouteNames.payments),
          ),
        ],
      ),
      QuickAccessItem(
        title: 'Attendance QR',
        subtitle: 'smart scholar log',
        info: 'Check-in: Scan QR / Manual',
        icon: Icons.qr_code_scanner_rounded,
        accentColor: const Color(0xFFEF4444),
        route: RouteNames.qr,
        actions: [
          QuickActionBtn(
            label: 'Scan QR',
            icon: Icons.qr_code_rounded,
            onTap: () => context.push(RouteNames.qr),
          ),
          QuickActionBtn(
            label: 'Manual',
            icon: Icons.how_to_reg_outlined,
            onTap: () => context.push(RouteNames.attendance),
          ),
          QuickActionBtn(
            label: 'Logs',
            icon: Icons.event_note_outlined,
            onTap: () => context.push(RouteNames.attendance),
          ),
        ],
      ),
      QuickAccessItem(
        title: 'Study Seats Grid',
        subtitle: '72 & 65 seat capacity',
        info: 'Single Floor: Hall View',
        icon: Icons.chair_rounded,
        accentColor: const Color(0xFF38BDF8),
        route: RouteNames.seats,
        actions: [
          QuickActionBtn(
            label: 'Grid',
            icon: Icons.grid_view_rounded,
            onTap: () => context.push(RouteNames.seats),
          ),
          QuickActionBtn(
            label: 'Assign',
            icon: Icons.chair_alt_outlined,
            onTap: () => context.push(RouteNames.seats),
          ),
          QuickActionBtn(
            label: 'Lockers',
            icon: Icons.lock_outline_rounded,
            onTap: () => context.push(RouteNames.lockers),
          ),
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: QUICK ACCESS
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'QUICK ACCESS',
            style: TextStyle(
              color: Color(0xFFE5C07B),
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Horizontal Cards matching recent member card dimensions & styling
        SizedBox(
          height: 128,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push(item.route);
                },
                child: Container(
                  width: 210,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151518),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF242428),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Avatar icon + Name + location
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: item.accentColor.withValues(alpha: 0.15),
                              border: Border.all(
                                color: item.accentColor.withValues(alpha: 0.5),
                                width: 1.2,
                              ),
                            ),
                            child: Icon(item.icon, color: item.accentColor, size: 18),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 10, color: Color(0xFF71717A)),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        item.subtitle,
                                        style: const TextStyle(
                                          color: Color(0xFF71717A),
                                          fontSize: 9.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Middle info line
                      Text(
                        item.info,
                        style: const TextStyle(
                          color: Color(0xFFA1A1AA),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                      ),

                      // Bottom actions row (Profile, Message, Renew equivalent)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: item.actions.map((act) {
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              act.onTap();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(act.icon, size: 12, color: const Color(0xFFE5C07B)),
                                const SizedBox(width: 3),
                                Text(
                                  act.label,
                                  style: const TextStyle(
                                    color: Color(0xFFD4D4D8),
                                    fontSize: 9.5,
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
