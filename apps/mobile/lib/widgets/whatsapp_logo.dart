import 'package:flutter/material.dart';

/// A custom-painted vector WhatsApp logo that accurately renders the
/// WhatsApp speech bubble and phone handset in any given color and size.
class WhatsAppLogo extends StatelessWidget {
  final double size;
  final Color color;

  const WhatsAppLogo({
    super.key,
    this.size = 24.0,
    this.color = const Color(0xFFD4AF37),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _WhatsAppPainter(color: color),
    );
  }
}

class _WhatsAppPainter extends CustomPainter {
  final Color color;

  const _WhatsAppPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.088
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Outer speech bubble path with bottom-left beak/tail
    final bubblePath = Path();
    // Center of circle roughly at (w * 0.51, h * 0.49)
    final cx = w * 0.5;
    final cy = h * 0.48;
    final r = w * 0.40;

    // Draw speech bubble with pointer tail
    // Sweep from ~130 deg (bottom left tail base) clockwise to ~80 deg
    bubblePath.addArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      0.65 * 3.14159265, // ~117 deg
      1.68 * 3.14159265, // ~302 deg sweep
    );

    // Tail towards bottom-left
    bubblePath.lineTo(w * 0.12, h * 0.88);
    bubblePath.lineTo(w * 0.30, h * 0.77);

    canvas.drawPath(bubblePath, strokePaint);

    // Inner Phone Handset Shape
    // Centered telephone handset angled ~45 deg
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-0.08); // slight tilt adjustment

    final phonePath = Path();
    final pw = w * 0.46;
    final ph = h * 0.46;

    // Detailed telephone handset receiver path
    phonePath.moveTo(-pw * 0.38, -ph * 0.18);
    phonePath.cubicTo(-pw * 0.42, -ph * 0.30, -pw * 0.28, -ph * 0.44, -pw * 0.14, -ph * 0.40);
    phonePath.lineTo(-pw * 0.02, -ph * 0.28);
    phonePath.cubicTo(pw * 0.06, -ph * 0.20, pw * 0.04, -ph * 0.08, -pw * 0.04, ph * 0.00);
    phonePath.lineTo(-pw * 0.09, ph * 0.05);
    phonePath.cubicTo(-pw * 0.06, ph * 0.12, pw * 0.02, ph * 0.20, pw * 0.10, ph * 0.26);
    phonePath.cubicTo(pw * 0.18, ph * 0.32, pw * 0.26, ph * 0.34, pw * 0.33, ph * 0.30);
    phonePath.lineTo(pw * 0.38, ph * 0.25);
    phonePath.cubicTo(pw * 0.45, ph * 0.18, pw * 0.58, ph * 0.20, pw * 0.64, ph * 0.32);
    phonePath.lineTo(pw * 0.74, ph * 0.44);
    phonePath.cubicTo(pw * 0.78, ph * 0.58, pw * 0.66, ph * 0.72, pw * 0.52, ph * 0.70);
    phonePath.cubicTo(pw * 0.32, ph * 0.68, pw * 0.04, ph * 0.54, -pw * 0.18, ph * 0.32);
    phonePath.cubicTo(-pw * 0.40, ph * 0.10, -pw * 0.52, -ph * 0.18, -pw * 0.48, -ph * 0.38);
    phonePath.close();

    // Scale and center handset inside speech bubble
    canvas.scale(0.68, 0.68);
    canvas.translate(-pw * 0.14, -ph * 0.12);
    canvas.drawPath(phonePath, fillPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WhatsAppPainter oldDelegate) =>
      oldDelegate.color != color;
}
