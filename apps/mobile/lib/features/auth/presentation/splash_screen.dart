import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/chintamani_logo.dart';
import '../../../core/services/app_update_service.dart';
import '../../../widgets/app_update_dialog.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _rayController;
  late final AnimationController _progressController;

  /// Update info fetched during splash; shown after navigation completes.
  AppUpdateInfo? _pendingUpdate;

  @override
  void initState() {
    super.initState();

    // Pulse animation for logo illumination
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Rotating ambient golden aura rays
    _rayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    // 3-second progress indicator
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..forward();

    // Start synchronized splash sequence
    _startSplashSequence();
  }

  /// Synchronized splash sequence: ensures golden branding plays while awaiting
  /// cloud update manifest, displaying update dialog immediately if available.
  Future<void> _startSplashSequence() async {
    final minSplashDuration = Future.delayed(const Duration(milliseconds: 2800));

    AppUpdateInfo? update;
    try {
      final service = ref.read(appUpdateServiceProvider);
      // Actively await update check with a 3.5s timeout
      update = await service.checkForUpdate().timeout(
        const Duration(milliseconds: 3500),
        onTimeout: () => null,
      );
    } catch (e) {
      debugPrint('[SplashScreen] Update check error: $e');
    }

    // Ensure splash branding animation displays for at least 2.8 seconds
    await minSplashDuration;
    if (!mounted) return;

    HapticFeedback.lightImpact();

    // If an update was discovered:
    if (update != null) {
      final autoCheck = await ref.read(appUpdateServiceProvider).isAutoCheckEnabled();
      if (update.forceUpdate || autoCheck) {
        await AppUpdateDialog.show(context, update);
        if (!mounted) return;
        if (update.forceUpdate) {
          // Mandatory update: user must complete update before continuing
          return;
        }
      }
    }

    final authState = ref.read(authProvider).value;
    if (authState is AuthAuthenticated) {
      context.go(RouteNames.dashboard);
    } else {
      // User explicitly signed out: request login credentials
      context.go(RouteNames.login);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rayController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark, // Deep luxury black
      body: Stack(
        children: [
          // Background Golden Aura & Light Rays
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _rayController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _GoldenAuraPainter(
                    angle: _rayController.value * 2 * math.pi,
                    pulse: _pulseController.value,
                  ),
                );
              },
            ),
          ),

          // Main Center Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // Illuminated Official Chinta Mani Logo with Golden Aura
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = 1.0 + (_pulseController.value * 0.06);
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.goldPrimary
                                      .withValues(alpha: 0.35 + _pulseController.value * 0.35),
                                  blurRadius: 40 + (_pulseController.value * 20),
                                  spreadRadius: 4 + (_pulseController.value * 6),
                                ),
                                BoxShadow(
                                  color: AppColors.goldBright
                                      .withValues(alpha: 0.2 + _pulseController.value * 0.2),
                                  blurRadius: 70,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: const ChintaManiLogo(
                              size: 110,
                              showGlow: true,
                              showCircularBackground: true,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // Official Brand Title
                    const Text(
                      'CHINTA MANI LIBRARY',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            color: AppColors.goldGlow,
                            blurRadius: 16,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Dual Branches Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.goldPrimary.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'Khalilabad • Mehdawal',
                        style: TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Official Quote
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '“Where Silence Meets Ambition • Infinity Under A Roof”',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.goldLight.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 3-Second Golden Progress Bar
                    SizedBox(
                      width: 180,
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, _) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: _progressController.value,
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
                              minHeight: 4,
                            ),
                          );
                        },
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Mandatory Footer: Developed by Prashant Mani Tripathi
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0x1AD4AF37),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0x33D4AF37),
                          width: 0.8,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            size: 14,
                            color: AppColors.goldPrimary,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Developed by Prashant Mani Tripathi',
                            style: TextStyle(
                              color: AppColors.goldLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldenAuraPainter extends CustomPainter {
  final double angle;
  final double pulse;

  _GoldenAuraPainter({required this.angle, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.42);
    final maxRadius = size.width * 0.75;

    // Ambient radial gradient
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.16),
        radius: 0.8,
        colors: [
          AppColors.goldPrimary.withValues(alpha: 0.15 + pulse * 0.08),
          AppColors.bluePrimary.withValues(alpha: 0.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Radiating golden branches / light rays
    final rayPaint = Paint()
      ..color = AppColors.goldPrimary.withValues(alpha: 0.03 + pulse * 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const numRays = 16;
    for (int i = 0; i < numRays; i++) {
      final a = angle + (i * 2 * math.pi / numRays);
      final p1 = Offset(center.dx + math.cos(a) * 70, center.dy + math.sin(a) * 70);
      final p2 = Offset(center.dx + math.cos(a) * maxRadius, center.dy + math.sin(a) * maxRadius);
      canvas.drawLine(p1, p2, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GoldenAuraPainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.pulse != pulse;
  }
}
