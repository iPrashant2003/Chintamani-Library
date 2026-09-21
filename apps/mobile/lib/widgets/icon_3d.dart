import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum Icon3DType {
  seat,
  locker,
  branch,
  members,
  finance,
  attendance,
  insights,
  wifi,
  airConditioner,
  security,
  power,
  water,
}

class Icon3D extends StatelessWidget {
  final Icon3DType type;
  final double size;
  final Color? color;
  final Color? secondaryColor;
  final bool isOccupied;
  final bool isAvailable;

  const Icon3D({
    super.key,
    required this.type,
    this.size = 48,
    this.color,
    this.secondaryColor,
    this.isOccupied = false,
    this.isAvailable = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _Icon3DPainter(
          type: type,
          primaryColor: color ?? _defaultPrimary,
          secondaryColor: secondaryColor ?? _defaultSecondary,
          isOccupied: isOccupied,
          isAvailable: isAvailable,
        ),
      ),
    );
  }

  Color get _defaultPrimary {
    switch (type) {
      case Icon3DType.seat:
        if (isOccupied) return AppColors.redPrimary;
        return isAvailable ? AppColors.emeraldPrimary : AppColors.goldPrimary;
      case Icon3DType.locker:
        return AppColors.purplePrimary;
      case Icon3DType.branch:
        return AppColors.goldPrimary;
      case Icon3DType.members:
        return AppColors.emeraldPrimary;
      case Icon3DType.finance:
        return AppColors.bluePrimary;
      case Icon3DType.attendance:
        return AppColors.blueAqua;
      case Icon3DType.insights:
        return AppColors.amberPrimary;
      case Icon3DType.wifi:
        return AppColors.blueAqua;
      case Icon3DType.airConditioner:
        return const Color(0xFF38BDF8);
      case Icon3DType.security:
        return AppColors.redPrimary;
      case Icon3DType.power:
        return AppColors.goldBright;
      case Icon3DType.water:
        return const Color(0xFF06B6D4);
    }
  }

  Color get _defaultSecondary {
    switch (type) {
      case Icon3DType.seat:
        return Colors.white;
      case Icon3DType.locker:
        return const Color(0xFFC084FC);
      case Icon3DType.branch:
        return AppColors.goldLight;
      case Icon3DType.members:
        return const Color(0xFF86EFAC);
      case Icon3DType.finance:
        return AppColors.goldPrimary;
      case Icon3DType.attendance:
        return Colors.white;
      case Icon3DType.insights:
        return AppColors.goldBright;
      case Icon3DType.wifi:
        return Colors.white;
      case Icon3DType.airConditioner:
        return Colors.white;
      case Icon3DType.security:
        return const Color(0xFFFCA5A5);
      case Icon3DType.power:
        return Colors.white;
      case Icon3DType.water:
        return Colors.white;
    }
  }
}

class _Icon3DPainter extends CustomPainter {
  final Icon3DType type;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isOccupied;
  final bool isAvailable;

  _Icon3DPainter({
    required this.type,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isOccupied,
    required this.isAvailable,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    switch (type) {
      case Icon3DType.seat:
        _draw3DSeat(canvas, w, h);
        break;
      case Icon3DType.locker:
        _draw3DLocker(canvas, w, h);
        break;
      case Icon3DType.branch:
        _draw3DBranch(canvas, w, h);
        break;
      case Icon3DType.members:
        _draw3DMembers(canvas, w, h);
        break;
      case Icon3DType.finance:
        _draw3DFinance(canvas, w, h);
        break;
      case Icon3DType.attendance:
        _draw3DAttendance(canvas, w, h);
        break;
      case Icon3DType.insights:
        _draw3DInsights(canvas, w, h);
        break;
      case Icon3DType.wifi:
        _draw3DWifi(canvas, w, h);
        break;
      case Icon3DType.airConditioner:
        _draw3DAC(canvas, w, h);
        break;
      case Icon3DType.security:
        _draw3DSecurity(canvas, w, h);
        break;
      case Icon3DType.power:
        _draw3DPower(canvas, w, h);
        break;
      case Icon3DType.water:
        _draw3DWater(canvas, w, h);
        break;
    }
  }

  void _draw3DSeat(Canvas canvas, double w, double h) {
    // Drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.9), width: w * 0.7, height: h * 0.16),
      shadowPaint,
    );

    // 3D Legs & Base
    final metalLegPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF475569), const Color(0xFF94A3B8), const Color(0xFF1E293B)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    
    // Central stem
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.46, h * 0.65, w * 0.08, h * 0.22), const Radius.circular(2)),
      metalLegPaint,
    );
    // Base 5-star legs
    canvas.drawLine(Offset(w * 0.22, h * 0.88), Offset(w * 0.78, h * 0.88), metalLegPaint..strokeWidth = 3);
    canvas.drawLine(Offset(w * 0.35, h * 0.84), Offset(w * 0.65, h * 0.92), metalLegPaint..strokeWidth = 3);

    // 3D Cushion Base (Perspective Trapezoid / rounded rect)
    final cushionPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [primaryColor, primaryColor.withValues(alpha: 0.7), Colors.black],
      ).createShader(Rect.fromLTWH(w * 0.15, h * 0.52, w * 0.7, h * 0.18));

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.15, h * 0.52, w * 0.7, h * 0.16), const Radius.circular(8)),
      cushionPaint,
    );

    // Cushion Top Bevel / Sheen
    final cushionSheen = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withValues(alpha: 0.6), Colors.transparent],
      ).createShader(Rect.fromLTWH(w * 0.18, h * 0.53, w * 0.64, h * 0.06));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.18, h * 0.53, w * 0.64, h * 0.06), const Radius.circular(4)),
      cushionSheen,
    );

    // 3D Ergonomic Backrest
    final backrestPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          secondaryColor.withValues(alpha: 0.9),
          primaryColor,
          primaryColor.withValues(alpha: 0.6),
          Colors.black,
        ],
      ).createShader(Rect.fromLTWH(w * 0.22, h * 0.12, w * 0.56, h * 0.42));

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.22, h * 0.12, w * 0.56, h * 0.42), const Radius.circular(10)),
      backrestPaint,
    );

    // Lumbar & Headrest 3D Ribs
    final ribPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromLTWH(w * 0.26, h * 0.22, w * 0.48, h * 0.1), 0, math.pi, false, ribPaint);
    canvas.drawArc(Rect.fromLTWH(w * 0.26, h * 0.32, w * 0.48, h * 0.1), 0, math.pi, false, ribPaint);

    // 3D Armrests
    final armrestPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF64748B), const Color(0xFF0F172A)],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final leftArm = Path()
      ..moveTo(w * 0.15, h * 0.48)
      ..lineTo(w * 0.15, h * 0.38)
      ..lineTo(w * 0.24, h * 0.38);
    canvas.drawPath(leftArm, armrestPaint);

    final rightArm = Path()
      ..moveTo(w * 0.85, h * 0.48)
      ..lineTo(w * 0.85, h * 0.38)
      ..lineTo(w * 0.76, h * 0.38);
    canvas.drawPath(rightArm, armrestPaint);
  }

  void _draw3DLocker(Canvas canvas, double w, double h) {
    // Drop shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.92), width: w * 0.75, height: h * 0.14),
      Paint()..color = Colors.black.withValues(alpha: 0.65)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Outer Locker Box (Metallic cabinet)
    final cabinetPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFF334155), const Color(0xFF0F172A), Colors.black],
      ).createShader(Rect.fromLTWH(w * 0.15, h * 0.1, w * 0.7, h * 0.8));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.15, h * 0.1, w * 0.7, h * 0.8), const Radius.circular(8)), cabinetPaint);

    // Metallic Door Face
    final doorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryColor, primaryColor.withValues(alpha: 0.7), const Color(0xFF1E1B4B)],
      ).createShader(Rect.fromLTWH(w * 0.2, h * 0.14, w * 0.6, h * 0.72));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.2, h * 0.14, w * 0.6, h * 0.72), const Radius.circular(6)), doorPaint);

    // Top Ventilation Louvers
    final ventPaint = Paint()..color = Colors.black.withValues(alpha: 0.5)..strokeWidth = 2;
    canvas.drawLine(Offset(w * 0.3, h * 0.22), Offset(w * 0.7, h * 0.22), ventPaint);
    canvas.drawLine(Offset(w * 0.3, h * 0.28), Offset(w * 0.7, h * 0.28), ventPaint);
    canvas.drawLine(Offset(w * 0.3, h * 0.34), Offset(w * 0.7, h * 0.34), ventPaint);

    // 3D Circular Safe Dial / Knob
    final dialCenter = Offset(w * 0.5, h * 0.54);
    canvas.drawCircle(
      dialCenter,
      w * 0.12,
      Paint()..shader = RadialGradient(colors: [AppColors.goldLight, AppColors.goldPrimary, const Color(0xFF78350F)]).createShader(Rect.fromCircle(center: dialCenter, radius: w * 0.12)),
    );
    canvas.drawCircle(dialCenter, w * 0.04, Paint()..color = Colors.black);

    // Bevel Sheen
    canvas.drawArc(
      Rect.fromCircle(center: dialCenter, radius: w * 0.11),
      -math.pi * 0.75,
      math.pi * 0.5,
      false,
      Paint()..color = Colors.white.withValues(alpha: 0.8)..strokeWidth = 1.5..style = PaintingStyle.stroke,
    );
  }

  void _draw3DBranch(Canvas canvas, double w, double h) {
    // 3D Classical Library Pillar / Facade in Imperial Gold
    final goldShader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.goldLight, AppColors.goldPrimary, const Color(0xFF78350F)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    final goldPaint = Paint()..shader = goldShader;

    // Pediment / Roof Triangle
    final roof = Path()
      ..moveTo(w * 0.5, h * 0.12)
      ..lineTo(w * 0.15, h * 0.3)
      ..lineTo(w * 0.85, h * 0.3)
      ..close();
    canvas.drawPath(roof, goldPaint);

    // 3 Pillars with 3D cylindrical lighting
    for (int i = 0; i < 3; i++) {
      final px = w * 0.25 + i * (w * 0.22);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(px, h * 0.34, w * 0.08, h * 0.42), const Radius.circular(2)),
        goldPaint,
      );
    }

    // Base Steps
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.12, h * 0.78, w * 0.76, h * 0.06), const Radius.circular(3)), goldPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.08, h * 0.85, w * 0.84, h * 0.06), const Radius.circular(3)), goldPaint);
  }

  void _draw3DMembers(Canvas canvas, double w, double h) {
    // 3D Scholar silhouette with glowing golden graduation cap
    final bodyShader = LinearGradient(
      colors: [primaryColor, secondaryColor, Colors.black],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Head
    canvas.drawCircle(Offset(w * 0.5, h * 0.38), w * 0.18, Paint()..shader = bodyShader);

    // Shoulders
    final shoulders = Path()
      ..moveTo(w * 0.2, h * 0.85)
      ..quadraticBezierTo(w * 0.5, h * 0.6, w * 0.8, h * 0.85)
      ..lineTo(w * 0.8, h * 0.9)
      ..lineTo(w * 0.2, h * 0.9)
      ..close();
    canvas.drawPath(shoulders, Paint()..shader = bodyShader);

    // Golden Laurel / Graduation Cap Accent
    final capShader = LinearGradient(colors: [AppColors.goldLight, AppColors.goldPrimary]).createShader(Rect.fromLTWH(0, 0, w, h));
    final cap = Path()
      ..moveTo(w * 0.5, h * 0.12)
      ..lineTo(w * 0.8, h * 0.22)
      ..lineTo(w * 0.5, h * 0.3)
      ..lineTo(w * 0.2, h * 0.22)
      ..close();
    canvas.drawPath(cap, Paint()..shader = capShader);
  }

  void _draw3DFinance(Canvas canvas, double w, double h) {
    // 3D Stacks of Gold / Sapphire Currency with ₹ symbol
    final coinPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.goldLight, AppColors.goldPrimary, const Color(0xFF92400E)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Bottom coin
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.72), width: w * 0.7, height: h * 0.24), coinPaint);
    // Middle coin
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.54), width: w * 0.7, height: h * 0.24), coinPaint);
    // Top coin
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.36), width: w * 0.7, height: h * 0.24), coinPaint);

    // Rupee symbol in center of top coin
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '₹',
        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(w * 0.5 - textPainter.width / 2, h * 0.36 - textPainter.height / 2));
  }

  void _draw3DAttendance(Canvas canvas, double w, double h) {
    // 3D Calendar & Checkmark Pad
    final bgPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.blueAqua, AppColors.bluePrimary, const Color(0xFF0F172A)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.15, h * 0.18, w * 0.7, h * 0.68), const Radius.circular(10)), bgPaint);

    // Top Binder Rings
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.28, h * 0.12, w * 0.08, h * 0.12), const Radius.circular(3)), Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.64, h * 0.12, w * 0.08, h * 0.12), const Radius.circular(3)), Paint()..color = Colors.white);

    // Radiant Glowing Emerald Checkmark
    final checkPaint = Paint()
      ..color = AppColors.emeraldPrimary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final check = Path()
      ..moveTo(w * 0.32, h * 0.54)
      ..lineTo(w * 0.46, h * 0.68)
      ..lineTo(w * 0.72, h * 0.38);
    canvas.drawPath(check, checkPaint);
  }

  void _draw3DInsights(Canvas canvas, double w, double h) {
    // 3D Isometric Bar Chart
    final bar1Shader = LinearGradient(colors: [AppColors.blueAqua, AppColors.bluePrimary]).createShader(Rect.fromLTWH(0, 0, w, h));
    final bar2Shader = LinearGradient(colors: [AppColors.goldBright, AppColors.goldPrimary]).createShader(Rect.fromLTWH(0, 0, w, h));
    final bar3Shader = LinearGradient(colors: [AppColors.emeraldPrimary, const Color(0xFF059669)]).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.16, h * 0.55, w * 0.18, h * 0.32), const Radius.circular(4)), Paint()..shader = bar1Shader);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.41, h * 0.32, w * 0.18, h * 0.55), const Radius.circular(4)), Paint()..shader = bar2Shader);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.66, h * 0.18, w * 0.18, h * 0.69), const Radius.circular(4)), Paint()..shader = bar3Shader);

    // Trend sparkline curve on top
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(w * 0.25, h * 0.5)
      ..lineTo(w * 0.5, h * 0.28)
      ..lineTo(w * 0.75, h * 0.14);
    canvas.drawPath(path, linePaint);
  }

  void _draw3DWifi(Canvas canvas, double w, double h) {
    final wavePaint = Paint()
      ..shader = LinearGradient(colors: [AppColors.blueAqua, AppColors.bluePrimary]).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: Offset(w * 0.5, h * 0.72), radius: w * 0.4), -math.pi * 0.75, math.pi * 0.5, false, wavePaint);
    canvas.drawArc(Rect.fromCircle(center: Offset(w * 0.5, h * 0.72), radius: w * 0.26), -math.pi * 0.75, math.pi * 0.5, false, wavePaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.72), w * 0.08, Paint()..color = AppColors.blueAqua);
  }

  void _draw3DAC(Canvas canvas, double w, double h) {
    // 3D Split AC Unit
    final acPaint = Paint()
      ..shader = LinearGradient(colors: [Colors.white, const Color(0xFF94A3B8), const Color(0xFF1E293B)]).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.12, h * 0.24, w * 0.76, h * 0.36), const Radius.circular(6)), acPaint);
    canvas.drawLine(Offset(w * 0.16, h * 0.52), Offset(w * 0.84, h * 0.52), Paint()..color = const Color(0xFF0F172A)..strokeWidth = 3);

    // Blue Cooling Wind Rays
    final windPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.3, h * 0.65), Offset(w * 0.25, h * 0.85), windPaint);
    canvas.drawLine(Offset(w * 0.5, h * 0.65), Offset(w * 0.5, h * 0.88), windPaint);
    canvas.drawLine(Offset(w * 0.7, h * 0.65), Offset(w * 0.75, h * 0.85), windPaint);
  }

  void _draw3DSecurity(Canvas canvas, double w, double h) {
    // 3D Dome CCTV
    final domePaint = Paint()
      ..shader = LinearGradient(colors: [const Color(0xFF475569), const Color(0xFF0F172A), Colors.black]).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.18, h * 0.2, w * 0.64, h * 0.18), const Radius.circular(4)), domePaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.48), w * 0.28, domePaint);

    // Ruby Glowing Lens
    canvas.drawCircle(Offset(w * 0.5, h * 0.48), w * 0.14, Paint()..color = AppColors.redPrimary);
    canvas.drawCircle(Offset(w * 0.52, h * 0.46), w * 0.04, Paint()..color = Colors.white);
  }

  void _draw3DPower(Canvas canvas, double w, double h) {
    // 3D Lightning Bolt
    final boltShader = LinearGradient(colors: [AppColors.goldBright, AppColors.goldPrimary, const Color(0xFFD97706)]).createShader(Rect.fromLTWH(0, 0, w, h));
    final bolt = Path()
      ..moveTo(w * 0.55, h * 0.12)
      ..lineTo(w * 0.25, h * 0.52)
      ..lineTo(w * 0.48, h * 0.52)
      ..lineTo(w * 0.42, h * 0.88)
      ..lineTo(w * 0.75, h * 0.42)
      ..lineTo(w * 0.52, h * 0.42)
      ..close();
    canvas.drawPath(bolt, Paint()..shader = boltShader);
  }

  void _draw3DWater(Canvas canvas, double w, double h) {
    // 3D Water Droplet
    final waterShader = RadialGradient(
      center: const Alignment(-0.2, -0.3),
      colors: [Colors.white, const Color(0xFF06B6D4), const Color(0xFF0369A1)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final drop = Path()
      ..moveTo(w * 0.5, h * 0.15)
      ..cubicTo(w * 0.75, h * 0.5, w * 0.85, h * 0.7, w * 0.5, h * 0.88)
      ..cubicTo(w * 0.15, h * 0.7, w * 0.25, h * 0.5, w * 0.5, h * 0.15)
      ..close();
    canvas.drawPath(drop, Paint()..shader = waterShader);
  }

  @override
  bool shouldRepaint(covariant _Icon3DPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.isOccupied != isOccupied ||
        oldDelegate.isAvailable != isAvailable;
  }
}
