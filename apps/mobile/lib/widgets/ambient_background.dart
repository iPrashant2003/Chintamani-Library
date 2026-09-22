import 'package:flutter/material.dart';

/// Deep dark background with responsive full-screen luxury library photo layer.
/// When [imagePath] is provided, it is rendered behind [child] with
/// calibrated darkness and multi-stop gradient overlay so every card,
/// metric, and text label maintains high contrast on both mobile and desktop.
class AmbientBackground extends StatelessWidget {
  final Widget child;
  final String? imagePath;

  const AmbientBackground({
    super.key,
    required this.child,
    this.imagePath,
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
              // Darken base to ensure card & text readability
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
                    Colors.black.withValues(alpha: 0.70), // Protect status bar & top branding
                    Colors.black.withValues(alpha: 0.48), // Reveal artwork ambiance
                    Colors.black.withValues(alpha: 0.78), // Smooth blend toward bottom navigation
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

        // ── Actual page content ────────────────────────────────────────
        child,
      ],
    );
  }
}
