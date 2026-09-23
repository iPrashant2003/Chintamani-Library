import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/glass_sidebar.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/whatsapp_logo.dart';

class MainShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({super.key, required this.navigationShell});

  void _onTap(int index) {
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  String get _currentRoute {
    final routes = [
      '/dashboard', '/members', '/seats', '/whatsapp', '/more'
    ];
    final idx = navigationShell.currentIndex;
    if (idx < routes.length) return routes[idx];
    return '/dashboard';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final useDesktopLayout = screenWidth >= 768;

    if (useDesktopLayout) {
      return _DesktopLayout(
        navigationShell: navigationShell,
        currentRoute: _currentRoute,
      );
    }

    return _MobileLayout(
      navigationShell: navigationShell,
      currentIndex: navigationShell.currentIndex,
      onTap: _onTap,
    );
  }
}

// ── Desktop layout: left sidebar + content ────────────────────────────────────
class _DesktopLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final String currentRoute;

  const _DesktopLayout({
    required this.navigationShell,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: Row(
        children: [
          GlassSidebar(currentRoute: currentRoute),
          Expanded(
            child: navigationShell,
          ),
        ],
      ),
    );
  }
}

// ── Mobile layout: 3D multicolour animated bottom bar ─────────────────────────
class _MobileLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _MobileLayout({
    required this.navigationShell,
    required this.currentIndex,
    required this.onTap,
  });

  static const _navItems = [
    _NavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'Home',
      color: Color(0xFF38BDF8), // Electric Sky Blue
      gradient: [Color(0xFF0284C7), Color(0xFF38BDF8)],
    ),
    _NavItem(
      icon: Icons.group_outlined,
      activeIcon: Icons.group_rounded,
      label: 'Members',
      color: Color(0xFF10B981), // Emerald Green
      gradient: [Color(0xFF059669), Color(0xFF10B981)],
    ),
    _NavItem(
      icon: Icons.chair_outlined,
      activeIcon: Icons.chair_rounded,
      label: 'Seats',
      color: Color(0xFFF59E0B), // Warm Amber
      gradient: [Color(0xFFD97706), Color(0xFFF59E0B)],
    ),
    _NavItem(
      icon: Icons.chat_outlined,
      activeIcon: Icons.chat_rounded,
      label: 'WhatsApp',
      color: Color(0xFF25D366), // Official WhatsApp Green
      gradient: [Color(0xFF128C7E), Color(0xFF25D366)],
      isWhatsApp: true,
    ),
    _NavItem(
      icon: Icons.apps_outlined,
      activeIcon: Icons.apps_rounded,
      label: 'More',
      color: Color(0xFFA855F7), // Royal Violet
      gradient: [Color(0xFF7C3AED), Color(0xFFA855F7)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF080B12),
      drawer: const AppDrawer(),
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xF7090C14),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 0.8,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.90),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = index == currentIndex;

                return Expanded(
                  child: _BottomNav3DItem(
                    item: item,
                    isSelected: isSelected,
                    onTap: () => onTap(index),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNav3DItem extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNav3DItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_BottomNav3DItem> createState() => _BottomNav3DItemState();
}

class _BottomNav3DItemState extends State<_BottomNav3DItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isSelected = widget.isSelected;

    final scale = _isPressed ? 0.90 : (isSelected ? 1.05 : 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 3D Elevated Tile Container with Specular Highlight & Ambient Glow
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          item.color.withValues(alpha: 0.28),
                          item.color.withValues(alpha: 0.08),
                          Colors.black.withValues(alpha: 0.40),
                        ],
                      )
                    : null,
                border: isSelected
                    ? Border.all(
                        color: item.color.withValues(alpha: 0.55),
                        width: 1.2,
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        // Ambient multi-colour glow in item's natural colour
                        BoxShadow(
                          color: item.color.withValues(alpha: 0.35),
                          blurRadius: 14,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                        // Bottom drop shadow for 3D elevation
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.7),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: item.isWhatsApp
                  ? WhatsAppLogo(
                      size: 21,
                      color: isSelected
                          ? const Color(0xFF25D366)
                          : const Color(0xFF25D366).withValues(alpha: 0.55),
                    )
                  : Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: 21,
                      color: isSelected
                          ? item.color
                          : Colors.white.withValues(alpha: 0.48),
                    ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected
                    ? item.color
                    : Colors.white.withValues(alpha: 0.55),
                letterSpacing: isSelected ? 0.2 : 0,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;
  final List<Color> gradient;
  final bool isWhatsApp;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
    required this.gradient,
    this.isWhatsApp = false,
  });
}
