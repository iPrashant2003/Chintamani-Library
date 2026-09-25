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

// ── Mobile layout: 4D Graphical Bottom Navigation Bar ────────────────────────
class _MobileLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _MobileLayout({
    required this.navigationShell,
    required this.currentIndex,
    required this.onTap,
  });

  // ── Nav items with 4D graphic definitions ─────────────────────────────────
  // Members icon color is specifically PINKISH RED (#E11D48 / #FB7185)
  static const _navItems = [
    _NavItem(
      icon: Icons.dashboard_rounded,
      activeIcon: Icons.dashboard_customize_rounded,
      label: 'Home',
      color: Color(0xFF818CF8), // Electric Indigo
      gradient: [Color(0xFF4F46E5), Color(0xFF818CF8), Color(0xFFC7D2FE)],
      badgeType: _Nav4DBadgeType.home,
    ),
    _NavItem(
      icon: Icons.people_alt_rounded,
      activeIcon: Icons.groups_rounded,
      label: 'Members',
      color: Color(0xFFE11D48), // Pinkish Red (Rose / Crimson)
      gradient: [Color(0xFF9F1239), Color(0xFFE11D48), Color(0xFFFB7185)],
      badgeType: _Nav4DBadgeType.members,
      isPinkishRed: true,
    ),
    _NavItem(
      icon: Icons.event_seat_rounded,
      activeIcon: Icons.airline_seat_recline_extra_rounded,
      label: 'Seats',
      color: Color(0xFF38BDF8), // Vivid Azure / Cyan Blue
      gradient: [Color(0xFF0284C7), Color(0xFF38BDF8), Color(0xFFBAE6FD)],
      badgeType: _Nav4DBadgeType.seats,
    ),
    _NavItem(
      icon: Icons.chat_bubble_rounded,
      activeIcon: Icons.forum_rounded,
      label: 'WhatsApp',
      color: Color(0xFF10B981), // Radiant Emerald
      gradient: [Color(0xFF047857), Color(0xFF10B981), Color(0xFF6EE7B7)],
      badgeType: _Nav4DBadgeType.whatsapp,
      isWhatsApp: true,
    ),
    _NavItem(
      icon: Icons.apps_rounded,
      activeIcon: Icons.grid_goldenratio_rounded,
      label: 'More',
      color: Color(0xFFF59E0B), // Imperial Amber Gold
      gradient: [Color(0xFFB45309), Color(0xFFF59E0B), Color(0xFFFDE68A)],
      badgeType: _Nav4DBadgeType.more,
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
          color: const Color(0xF805070D),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 0.8,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.95),
              blurRadius: 28,
              offset: const Offset(0, -6),
            ),
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.6),
              blurRadius: 18,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isSelected = index == currentIndex;

                return Expanded(
                  child: _BottomNav4DItem(
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

enum _Nav4DBadgeType { home, members, seats, whatsapp, more }

class _BottomNav4DItem extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNav4DItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_BottomNav4DItem> createState() => _BottomNav4DItemState();
}

class _BottomNav4DItemState extends State<_BottomNav4DItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isSelected = widget.isSelected;
    final primaryColor = item.color;

    final scale = _isPressed ? 0.85 : (isSelected ? 1.08 : 0.98);

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
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── 4D Volumetric Graphical Pod ───────────────────────────────
            _Nav4DGraphic(
              item: item,
              isSelected: isSelected,
            ),
            const SizedBox(height: 3),
            // ── Graphical Label with Theme Illumination ───────────────────
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected
                    ? (item.isPinkishRed ? const Color(0xFFFB7185) : primaryColor)
                    : Colors.white.withValues(alpha: 0.45),
                letterSpacing: isSelected ? 0.35 : 0.1,
                shadows: isSelected
                    ? [
                        Shadow(
                          color: primaryColor.withValues(alpha: 0.7),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

/// 4D Multi-layered Graphical Icon Renderer
class _Nav4DGraphic extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;

  const _Nav4DGraphic({
    required this.item,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = item.color;
    final gradient = item.gradient;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // ── 4D Level 1: Volumetric Floor Glow ─────────────────────────────
        if (isSelected)
          Positioned(
            bottom: -2,
            child: Container(
              width: 32,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.65),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

        // ── 4D Level 2: Beveled Specular Glass Pod Capsule ────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      gradient.last.withValues(alpha: 0.35),
                      color.withValues(alpha: 0.18),
                      Colors.black.withValues(alpha: 0.60),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.40),
                    ],
                  ),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.75)
                  : Colors.white.withValues(alpha: 0.08),
              width: isSelected ? 1.4 : 0.8,
            ),
            boxShadow: isSelected
                ? [
                    // Specular ambient bloom
                    BoxShadow(
                      color: color.withValues(alpha: 0.45),
                      blurRadius: 18,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                    // Physical drop shadow
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: _buildInnerGraphic(context),
        ),

        // ── 4D Level 3: Micro Specular Sheen Rim (Top-Left Light Glint) ──
        if (isSelected)
          Positioned(
            top: 2,
            left: 10,
            child: Container(
              width: 14,
              height: 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.8),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInnerGraphic(BuildContext context) {
    switch (item.badgeType) {
      case _Nav4DBadgeType.whatsapp:
        return _buildWhatsAppGraphic();
      case _Nav4DBadgeType.members:
        return _buildMembersGraphic();
      case _Nav4DBadgeType.seats:
        return _buildSeatsGraphic();
      case _Nav4DBadgeType.home:
        return _buildHomeGraphic();
      case _Nav4DBadgeType.more:
        return _buildMoreGraphic();
    }
  }

  // 4D Members Graphic: Pinkish-Red (#E11D48 / #FB7185) with layered avatars & glow
  Widget _buildMembersGraphic() {
    const pinkishRed = Color(0xFFE11D48);
    const softRose = Color(0xFFFB7185);

    return SizedBox(
      width: 25,
      height: 25,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background shadow silhouette for depth
          Positioned(
            top: 2,
            left: 2,
            child: Icon(
              Icons.group_rounded,
              size: 23,
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
          // Primary Pinkish-Red Avatar Cluster
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [softRose, pinkishRed, Color(0xFFBE123C)],
            ).createShader(bounds),
            child: Icon(
              isSelected ? Icons.groups_rounded : Icons.group_outlined,
              size: 23,
              color: Colors.white,
            ),
          ),
          // Ambient pinkish specular spark
          if (isSelected)
            Positioned(
              right: 1,
              top: 1,
              child: Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: softRose,
                  boxShadow: [
                    BoxShadow(color: pinkishRed, blurRadius: 4, spreadRadius: 1),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 4D WhatsApp Graphic: 3D glossy bubble emblem
  Widget _buildWhatsAppGraphic() {
    return SizedBox(
      width: 25,
      height: 25,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 2,
            left: 2,
            child: Icon(
              Icons.chat_bubble_rounded,
              size: 23,
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),
          WhatsAppLogo(
            size: 23,
            color: isSelected ? const Color(0xFF34D399) : item.color.withValues(alpha: 0.65),
          ),
        ],
      ),
    );
  }

  // 4D Home Graphic: Futuristic Dashboard Matrix
  Widget _buildHomeGraphic() {
    return SizedBox(
      width: 25,
      height: 25,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 2,
            left: 2,
            child: Icon(
              Icons.grid_view_rounded,
              size: 22,
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? item.gradient
                  : [Colors.white.withValues(alpha: 0.7), item.color.withValues(alpha: 0.5)],
            ).createShader(bounds),
            child: Icon(
              isSelected ? Icons.dashboard_rounded : Icons.dashboard_outlined,
              size: 22,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 4D Seats Graphic: Isometric 3D Seat Graphic
  Widget _buildSeatsGraphic() {
    return SizedBox(
      width: 25,
      height: 25,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 2,
            left: 2,
            child: Icon(
              Icons.airline_seat_recline_extra_rounded,
              size: 22,
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? item.gradient
                  : [Colors.white.withValues(alpha: 0.7), item.color.withValues(alpha: 0.5)],
            ).createShader(bounds),
            child: Icon(
              isSelected ? Icons.airline_seat_recline_extra_rounded : Icons.event_seat_outlined,
              size: 22,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 4D More Graphic: Imperial Vault Cube / Multi-Tool Matrix
  Widget _buildMoreGraphic() {
    return SizedBox(
      width: 25,
      height: 25,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 2,
            left: 2,
            child: Icon(
              Icons.apps_rounded,
              size: 22,
              color: Colors.black.withValues(alpha: 0.45),
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSelected
                  ? item.gradient
                  : [Colors.white.withValues(alpha: 0.7), item.color.withValues(alpha: 0.5)],
            ).createShader(bounds),
            child: Icon(
              isSelected ? Icons.apps_rounded : Icons.apps_outlined,
              size: 22,
              color: Colors.white,
            ),
          ),
        ],
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
  final _Nav4DBadgeType badgeType;
  final bool isWhatsApp;
  final bool isPinkishRed;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
    required this.gradient,
    required this.badgeType,
    this.isWhatsApp = false,
    this.isPinkishRed = false,
  });
}
