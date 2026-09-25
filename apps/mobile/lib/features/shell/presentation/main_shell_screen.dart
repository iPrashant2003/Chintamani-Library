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

// ── Mobile layout: 3D luxury gold-active bottom bar ─────────────────────────
class _MobileLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _MobileLayout({
    required this.navigationShell,
    required this.currentIndex,
    required this.onTap,
  });

  // ── Nav items: each with its distinct muted-luxury color ──
  // Active state: always transitions to luxury gold (per spec §15)
  static const _navItems = [
    _NavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'Home',
      color: Color(0xFFA78BFA), // Soft Purple
      gradient: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
    ),
    _NavItem(
      icon: Icons.group_outlined,
      activeIcon: Icons.group_rounded,
      label: 'Members',
      color: Color(0xFF2DD4BF), // Sea Green / Teal
      gradient: [Color(0xFF0D9488), Color(0xFF2DD4BF)],
    ),
    _NavItem(
      icon: Icons.chair_outlined,
      activeIcon: Icons.chair_rounded,
      label: 'Seats',
      color: Color(0xFF60A5FA), // Royal Blue
      gradient: [Color(0xFF2563EB), Color(0xFF60A5FA)],
    ),
    _NavItem(
      icon: Icons.chat_outlined,
      activeIcon: Icons.chat_rounded,
      label: 'WhatsApp',
      color: Color(0xFF34D399), // Emerald Green
      gradient: [Color(0xFF059669), Color(0xFF34D399)],
      isWhatsApp: true,
    ),
    _NavItem(
      icon: Icons.apps_outlined,
      activeIcon: Icons.apps_rounded,
      label: 'More',
      color: Color(0xFFE8C97A), // Luxury Gold
      gradient: [Color(0xFFC9A84C), Color(0xFFE8C97A)],
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
          color: const Color(0xF4060810),
          border: Border(
            top: BorderSide(
              color: const Color(0xFFC9A84C).withValues(alpha: 0.14),
              width: 0.8,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.92),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
            BoxShadow(
              color: const Color(0xFFC9A84C).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
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

    // Active color is always luxury gold; inactive keeps item's own color
    const goldActive = Color(0xFFE8C97A);
    const goldGlow = Color(0xFFC9A84C);

    final scale = _isPressed ? 0.88 : (isSelected ? 1.06 : 1.0);

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
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── 3D Elevated Container: Gold when active, neutral when inactive ──
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          goldGlow.withValues(alpha: 0.32),
                          goldGlow.withValues(alpha: 0.10),
                          Colors.black.withValues(alpha: 0.50),
                        ],
                      )
                    : null,
                border: isSelected
                    ? Border.all(
                        color: goldActive.withValues(alpha: 0.60),
                        width: 1.3,
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        // Luxury gold ambient glow (top layer)
                        BoxShadow(
                          color: goldGlow.withValues(alpha: 0.45),
                          blurRadius: 18,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                        // 3D depth drop shadow (bottom layer)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.75),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: item.isWhatsApp
                  ? WhatsAppLogo(
                      size: 21,
                      color: isSelected
                          ? goldActive
                          : item.color.withValues(alpha: 0.55),
                    )
                  : Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: 22,
                      color: isSelected
                          ? goldActive  // ← luxury gold when active
                          : item.color.withValues(alpha: 0.60),
                    ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                color: isSelected
                    ? goldActive  // ← luxury gold label when active
                    : Colors.white.withValues(alpha: 0.45),
                letterSpacing: isSelected ? 0.3 : 0,
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
