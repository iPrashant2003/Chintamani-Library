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

// ── Mobile layout: docked dark luxury bottom bar matching reference image ─────
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
    _NavItem(icon: Icons.grid_view_rounded, activeIcon: Icons.grid_view_rounded, label: 'Home'),
    _NavItem(icon: Icons.group_outlined, activeIcon: Icons.group_rounded, label: 'Members'),
    _NavItem(icon: Icons.chair_outlined, activeIcon: Icons.chair_rounded, label: 'Seats'),
    _NavItem(icon: Icons.chat_outlined, activeIcon: Icons.chat_rounded, label: 'WhatsApp', isWhatsApp: true),
    _NavItem(icon: Icons.apps_rounded, activeIcon: Icons.apps_rounded, label: 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF0D0D0F),
      drawer: const AppDrawer(),
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xF21C160B), // Luxury warm gold-tinted obsidian with 95% opacity
              Color(0xF8100C05), // Deep rich velvet gold base
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.85),
              blurRadius: 12,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = index == currentIndex;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                          decoration: isSelected
                              ? BoxDecoration(
                                  color: const Color(0xFFD4AF37).withValues(alpha: 0.20),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFD4AF37).withValues(alpha: 0.45),
                                    width: 1.0,
                                  ),
                                )
                              : null,
                          child: item.isWhatsApp
                              ? WhatsAppLogo(
                                  size: 20,
                                  color: isSelected
                                      ? const Color(0xFFFDE68A)
                                      : const Color(0xFFD4AF37).withValues(alpha: 0.72),
                                )
                              : Icon(
                                  isSelected ? item.activeIcon : item.icon,
                                  size: 21,
                                  color: isSelected
                                      ? const Color(0xFFFDE68A)
                                      : const Color(0xFFD4AF37).withValues(alpha: 0.72),
                                ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFFFDE68A)
                                : const Color(0xFFD4AF37).withValues(alpha: 0.80),
                            letterSpacing: isSelected ? 0.2 : 0,
                          ),
                        ),
                      ],
                    ),
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

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isWhatsApp;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.isWhatsApp = false,
  });
}
