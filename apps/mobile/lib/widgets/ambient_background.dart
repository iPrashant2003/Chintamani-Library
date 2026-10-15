import 'package:flutter/material.dart';

/// Deep dark background with responsive full-screen luxury library photo layer
/// and centered transparent watermark brand logo.
/// Every card, metric, and text label maintains high contrast and readability.
class AmbientBackground extends StatelessWidget {
  final Widget child;
  final String? imagePath;
  final bool showCenterLogo;
  final double logoOpacity;

  const AmbientBackground({
    super.key,
    required this.child,
    this.imagePath,
    this.showCenterLogo = true,
    this.logoOpacity = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Pitch-black foundation ─────────────────────────────────────
        const ColoredBox(color: Color(0xFF000000)),

        // ── Responsive Photo Background Layer ─────────────────────────
        if (imagePath != null)
          Positioned.fill(
            child: Image.asset(
              imagePath!,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              color: Colors.black.withValues(alpha: 0.62),
              colorBlendMode: BlendMode.darken,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

        // ── Vertical gradient overlay for text readability ────────────
        if (imagePath != null)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.70),
                    Colors.black.withValues(alpha: 0.48),
                    Colors.black.withValues(alpha: 0.78),
                  ],
                ),
              ),
            ),
          ),

        // ── Soft radial vignette to keep edges calm & luxury ──────────
        if (imagePath != null)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.35,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.40),
                  ],
                ),
              ),
            ),
          ),

        // ── Centered Watermark Logo (Proper Opacity & Transparent) ─────
        if (showCenterLogo)
          Positioned.fill(
            child: Center(
              child: IgnorePointer(
                child: Opacity(
                  opacity: logoOpacity,
                  child: Image.asset(
                    'assets/images/app_bg_logo.png',
                    width: 310,
                    height: 310,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),

        // ── Actual page content ────────────────────────────────────────
        child,
      ],
    );
  }
}
