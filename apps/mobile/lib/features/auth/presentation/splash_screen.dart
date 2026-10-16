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

// ---------------------------------------------------------------------------
// Particle data model matching login page
// ---------------------------------------------------------------------------
class _SplashParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double phase;
  final Color color;

  const _SplashParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
    required this.color,
  });
}

class _SplashParticlePainter extends CustomPainter {
  final double progress;
  final List<_SplashParticle> particles;

  _SplashParticlePainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress + p.phase) % 1.0;
      final dx = p.x * size.width + math.sin(t * 2 * math.pi + p.phase) * 28;
      final dy = p.y * size.height + math.cos(t * 2 * math.pi * p.speed + p.phase) * 22;

      final glowPaint = Paint()
        ..color = p.color.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(dx, dy), p.size * 3.5, glowPaint);

      final corePaint = Paint()
        ..color = p.color.withValues(alpha: 0.75)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      canvas.drawCircle(Offset(dx, dy), p.size, corePaint);
    }
  }

  @override
  bool shouldRepaint(_SplashParticlePainter old) => old.progress != progress;
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;
  late final AnimationController _particleController;
  late final AnimationController _progressController;

  bool _hasError = false;
  String _errorMessage = '';

  static final _particles = <_SplashParticle>[
    const _SplashParticle(x: 0.08, y: 0.12, size: 3.0, speed: 0.7, phase: 0.00, color: AppColors.goldPrimary),
    const _SplashParticle(x: 0.85, y: 0.18, size: 2.2, speed: 1.1, phase: 0.15, color: Color(0xFF00E5BC)),
    const _SplashParticle(x: 0.55, y: 0.07, size: 1.8, speed: 0.9, phase: 0.33, color: AppColors.goldLight),
    const _SplashParticle(x: 0.20, y: 0.75, size: 2.6, speed: 0.6, phase: 0.52, color: AppColors.goldPrimary),
    const _SplashParticle(x: 0.90, y: 0.62, size: 1.5, speed: 1.3, phase: 0.71, color: Color(0xFF00E5BC)),
    const _SplashParticle(x: 0.40, y: 0.88, size: 2.0, speed: 0.8, phase: 0.44, color: AppColors.goldLight),
    const _SplashParticle(x: 0.70, y: 0.45, size: 1.6, speed: 1.0, phase: 0.62, color: AppColors.goldPrimary),
    const _SplashParticle(x: 0.15, y: 0.42, size: 3.2, speed: 0.5, phase: 0.83, color: Color(0xFF00E5BC)),
  ];

  @override
  void initState() {
    super.initState();

    // 1. Particle field animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // 2. Pulsating golden ring matching login page
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.93, end: 1.07).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 3. Progress bar indicator
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();

    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });
    _progressController.reset();
    _progressController.forward();

    final minDuration = Future.delayed(const Duration(milliseconds: 2500));

    AppUpdateInfo? update;
    try {
      final service = ref.read(appUpdateServiceProvider);
      update = await service.checkForUpdate().timeout(
        const Duration(milliseconds: 3500),
        onTimeout: () => null,
      );
    } catch (e) {
      debugPrint('[SplashScreen] Update check note: $e');
    }

    await minDuration;
    if (!mounted) return;

    try {
      if (update != null) {
        final autoCheck = await ref.read(appUpdateServiceProvider).isAutoCheckEnabled();
        if (update.forceUpdate || autoCheck) {
          await AppUpdateDialog.show(context, update);
          if (!mounted) return;
          if (update.forceUpdate) {
            return;
          }
        }
      }

      final authState = ref.read(authProvider).value;
      if (authState is AuthAuthenticated) {
        context.go(RouteNames.dashboard);
      } else {
        context.go(RouteNames.login);
      }
    } catch (err) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Initialization timed out or connection failed.';
        });
      }
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          // ── Layer 0: Matching Floating Particle Field ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (_, __) => CustomPaint(
                painter: _SplashParticlePainter(
                  progress: _particleController.value,
                  particles: _particles,
                ),
              ),
            ),
          ),

          // ── Layer 1: Center Brand Symbol (Infinity Under a Roof) ──
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // Pulsating golden ring + Official Logo
                    AnimatedBuilder(
                      animation: _pulseAnim,
                      builder: (_, child) => Transform.scale(
                        scale: _pulseAnim.value,
                        child: child,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 114,
                            height: 114,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.goldPrimary.withValues(alpha: 0.55),
                                width: 2.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.goldPrimary.withValues(alpha: 0.28),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                                BoxShadow(
                                  color: AppColors.goldLight.withValues(alpha: 0.12),
                                  blurRadius: 44,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const ChintaManiLogo(
                            size: 98,
                            showGlow: true,
                            showCircularBackground: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Brand Title
                    const Text(
                      'CHINTA MANI LIBRARY',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Infinity under a roof subtitle pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4)),
                      ),
                      child: const Text(
                        'Infinity under a roof',
                        style: TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Khalilabad • Mehdawal',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Progress or Error state
                    if (!_hasError) ...[
                      SizedBox(
                        width: 170,
                        child: AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, _) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: _progressController.value,
                                backgroundColor: Colors.white.withValues(alpha: 0.1),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
                                minHeight: 3.5,
                              ),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.redPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.redPrimary.withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _errorMessage,
                              style: const TextStyle(color: AppColors.redLight, fontSize: 11),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFACC15),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: _startSplashSequence,
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Spacer(flex: 3),

                    // Developer Credit
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                            size: 13,
                            color: AppColors.goldPrimary,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Developed by Prashant Mani Tripathi',
                            style: TextStyle(
                              color: AppColors.goldLight,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),
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
