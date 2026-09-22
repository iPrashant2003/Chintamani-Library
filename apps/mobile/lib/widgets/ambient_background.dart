import 'package:flutter/material.dart';

/// Deep dark background with optional full-screen photo layer.
/// When [imagePath] is provided (asset path), it is rendered behind
/// [child] with reduced brightness and a translucent dark overlay
/// so every card / module remains clearly readable.
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
        // ── Pitch-black base ───────────────────────────────────────────
        const ColoredBox(color: Color(0xFF000000)),

        // ── Optional photo background ──────────────────────────────────
        if (imagePath != null)
          Positioned.fill(
            child: Image.asset(
              imagePath!,
              fit: BoxFit.cover,
              // Darken the image so cards stay readable
              color: Colors.black.withValues(alpha: 0.60),
              colorBlendMode: BlendMode.darken,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),

        // ── Very subtle dark vignette overlay ─────────────────────────
        if (imagePath != null)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.4,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.30),
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
