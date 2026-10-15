import 'package:flutter/material.dart';

/// Deep dark background with centered transparent watermark brand logo.
/// Removed existing photo backgrounds so the official insignia displays with
/// calibrated opacity and brightness across all app pages and the Universal QR portal.
/// Every card, metric, and text label maintains 100% contrast and readability.
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
    this.logoOpacity = 0.12,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Pitch-black foundation ─────────────────────────────────────
        const ColoredBox(color: Color(0xFF000000)),

        // ── Centered Watermark Brand Insignia (Proper Opacity & Transparent) ─
        if (showCenterLogo)
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: logoOpacity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                  child: Center(
                    child: Image.asset(
                      'assets/images/app_bg_logo.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
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
