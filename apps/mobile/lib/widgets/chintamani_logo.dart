import 'package:flutter/material.dart';

/// Reusable Chinta Mani Library official emblem widget.
/// Strictly preserves logo aspect ratio and official branding.
class ChintaManiLogo extends StatelessWidget {
  final double size;
  final bool showGlow;
  final Color? glowColor;
  final bool showCircularBackground;
  final VoidCallback? onTap;

  const ChintaManiLogo({
    super.key,
    this.size = 40,
    this.showGlow = false,
    this.glowColor,
    this.showCircularBackground = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGlow = glowColor ?? const Color(0xFFF59E0B); // Golden glow matching laurel

    Widget content = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: showCircularBackground ? const Color(0xFF040B0D) : Colors.transparent,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: effectiveGlow.withValues(alpha: 0.35),
                  blurRadius: size * 0.35,
                  spreadRadius: size * 0.05,
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/chintamani_logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback gracefully to high-quality vector typography emblem if asset isn't resolved
            return Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  'CML',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: size * 0.28,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}
