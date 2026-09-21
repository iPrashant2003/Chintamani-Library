import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/theme_provider.dart';
import 'chintamani_logo.dart';
import 'whatsapp_logo.dart';

class _SidebarItem {
  final String route;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _SidebarItem({
    required this.route,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const _kNavItems = [
  _SidebarItem(
    route: '/dashboard',
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard_rounded,
    label: 'Dashboard',
  ),
  _SidebarItem(
    route: '/branches/compare',
    icon: Icons.compare_arrows_outlined,
    activeIcon: Icons.compare_arrows_rounded,
    label: 'Branch Insights',
  ),
  _SidebarItem(
    route: '/members',
    icon: Icons.people_outline_rounded,
    activeIcon: Icons.people_rounded,
    label: 'Members',
  ),
  _SidebarItem(
    route: '/seats',
    icon: Icons.event_seat_outlined,
    activeIcon: Icons.event_seat_rounded,
    label: 'Seats',
  ),
  _SidebarItem(
    route: '/lockers',
    icon: Icons.lock_outline_rounded,
    activeIcon: Icons.lock_rounded,
    label: 'Lockers',
  ),
  _SidebarItem(
    route: '/attendance',
    icon: Icons.check_circle_outline_rounded,
    activeIcon: Icons.check_circle_rounded,
    label: 'Attendance',
  ),
  _SidebarItem(
    route: '/payments',
    icon: Icons.currency_rupee_rounded,
    activeIcon: Icons.currency_rupee_rounded,
    label: 'Payments',
  ),
  _SidebarItem(
    route: '/enquiries',
    icon: Icons.contact_mail_outlined,
    activeIcon: Icons.contact_mail_rounded,
    label: 'Enquiries',
  ),
  _SidebarItem(
    route: '/expenses',
    icon: Icons.receipt_long_outlined,
    activeIcon: Icons.receipt_long_rounded,
    label: 'Expenses',
  ),
  _SidebarItem(
    route: '/reports',
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart_rounded,
    label: 'Reports',
  ),
  _SidebarItem(
    route: '/communication',
    icon: Icons.chat_outlined,
    activeIcon: Icons.chat_rounded,
    label: 'Communication',
  ),
  _SidebarItem(
    route: '/whatsapp',
    icon: Icons.chat_bubble_outline_rounded,
    activeIcon: Icons.chat_bubble_rounded,
    label: 'WhatsApp Hub',
  ),
  _SidebarItem(
    route: '/qr',
    icon: Icons.qr_code_outlined,
    activeIcon: Icons.qr_code_rounded,
    label: 'QR Code',
  ),
  _SidebarItem(
    route: '/settings',
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
    label: 'Settings',
  ),
];

class GlassSidebar extends ConsumerStatefulWidget {
  final String currentRoute;
  final VoidCallback? onToggle;

  const GlassSidebar({
    super.key,
    required this.currentRoute,
    this.onToggle,
  });

  @override
  ConsumerState<GlassSidebar> createState() => _GlassSidebarState();
}

class _GlassSidebarState extends ConsumerState<GlassSidebar>
    with SingleTickerProviderStateMixin {
  bool _expanded = true;
  late AnimationController _animCtrl;
  late Animation<double> _widthAnim;

  static const double _expandedWidth = 230.0;
  static const double _collapsedWidth = 70.0;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _widthAnim = Tween<double>(
      begin: _expandedWidth,
      end: _collapsedWidth,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOutCubic));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _animCtrl.reverse();
    } else {
      _animCtrl.forward();
    }
    widget.onToggle?.call();
  }

  bool _isActive(String route) {
    if (route == '/dashboard') return widget.currentRoute == '/dashboard';
    return widget.currentRoute.startsWith(route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return AnimatedBuilder(
      animation: _widthAnim,
      builder: (ctx, _) {
        final w = _expanded ? _expandedWidth : _collapsedWidth;
        return SizedBox(
          width: w,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xEB1A1408), // Luxury gold-tinted obsidian
                      Color(0xF40F0C05), // Deep dark velvet gold base
                    ],
                  ),
                  border: Border(
                    right: BorderSide(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.30),
                      width: 1.2,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.10),
                      blurRadius: 16,
                      offset: const Offset(3, 0),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header with Official Logo
                      _buildHeader(w, theme),
                      const SizedBox(height: 6),

                      // Nav items list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          itemCount: _kNavItems.length,
                          itemBuilder: (ctx, i) => _buildNavItem(_kNavItems[i], w, theme),
                        ),
                      ),

                      // Bottom Divider
                      Divider(
                        color: theme.primaryColor.withValues(alpha: 0.20),
                        thickness: 1,
                        indent: 14,
                        endIndent: 14,
                      ),

                      // About & Contact quick actions
                      _buildBottomAction(
                        icon: Icons.info_outline_rounded,
                        label: 'About Chinta Mani',
                        onTap: () => context.push('/about'),
                        theme: theme,
                      ),
                      _buildBottomAction(
                        icon: Icons.support_agent_rounded,
                        label: 'Contact Support',
                        onTap: () => context.push('/contact'),
                        theme: theme,
                      ),

                      // Toggle collapse/expand button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: _buildToggleButton(w, theme),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(double w, AppThemeConfig theme) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          const ChintaManiLogo(
            size: 38,
            showGlow: true,
            showCircularBackground: true,
          ),
          if (_expanded) ...[
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CHINTA MANI',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Library Network',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(_SidebarItem item, double w, AppThemeConfig theme) {
    final active = _isActive(item.route);

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          context.go(item.route);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: active
                ? theme.primaryColor.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: active
                ? Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.45),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              item.route == '/whatsapp'
                  ? WhatsAppLogo(
                      size: 19,
                      color: active ? theme.primaryColor : AppColors.textTertiary,
                    )
                  : Icon(
                      active ? item.activeIcon : item.icon,
                      size: 19,
                      color: active ? theme.primaryColor : AppColors.textTertiary,
                    ),
              if (_expanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: active ? theme.primaryColor : AppColors.textSecondary,
                      fontSize: 12.5,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (active)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: theme.glowColor.withValues(alpha: 0.7),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );

    if (!_expanded) {
      return Tooltip(
        message: item.label,
        preferBelow: false,
        child: content,
      );
    }

    return content;
  }

  Widget _buildBottomAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required AppThemeConfig theme,
  }) {
    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 17, color: AppColors.textTertiary),
              if (_expanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (!_expanded) {
      return Tooltip(message: label, preferBelow: false, child: content);
    }
    return content;
  }

  Widget _buildToggleButton(double w, AppThemeConfig theme) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: _expanded ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
          children: [
            if (_expanded)
              const Text(
                'Collapse Sidebar',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            Icon(
              _expanded ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

