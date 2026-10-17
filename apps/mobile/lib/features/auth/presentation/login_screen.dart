import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/route_names.dart';
import '../../../widgets/card_3d.dart';
import '../../../widgets/ambient_background.dart';
import '../../../widgets/chintamani_logo.dart';
import '../../../theme/app_colors.dart';
import '../../../core/services/app_update_service.dart';
import '../../../widgets/app_update_dialog.dart';
import '../providers/auth_provider.dart';

// ---------------------------------------------------------------------------
// Particle data model
// ---------------------------------------------------------------------------
class _Particle {
  final double x; // 0..1 fractional position
  final double y;
  final double size;
  final double speed;
  final double phase; // phase offset for sin/cos drift
  final Color color;

  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
    required this.color,
  });
}

// ---------------------------------------------------------------------------
// Particle painter
// ---------------------------------------------------------------------------
class _ParticlePainter extends CustomPainter {
  final double progress; // 0..1 looping
  final List<_Particle> particles;

  _ParticlePainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress + p.phase) % 1.0;
      final dx = p.x * size.width + math.sin(t * 2 * math.pi + p.phase) * 28;
      final dy = p.y * size.height + math.cos(t * 2 * math.pi * p.speed + p.phase) * 22;

      // Glow outer ring
      final glowPaint = Paint()
        ..color = p.color.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(dx, dy), p.size * 3.5, glowPaint);

      // Core dot
      final corePaint = Paint()
        ..color = p.color.withValues(alpha: 0.75)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      canvas.drawCircle(Offset(dx, dy), p.size, corePaint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

// ---------------------------------------------------------------------------
// Shimmer painter for the login button
// ---------------------------------------------------------------------------
class _ShimmerPainter extends CustomPainter {
  final double progress; // 0..1
  final BorderRadius borderRadius;

  _ShimmerPainter({required this.progress, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndCorners(
      Offset.zero & size,
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );
    canvas.clipRRect(rrect);

    // Sweep from -30% to +130% of width
    final sweepX = (progress * 1.6 - 0.3) * size.width;
    const sweepWidth = 60.0;

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.38),
          Colors.white.withValues(alpha: 0.55),
          Colors.white.withValues(alpha: 0.38),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(sweepX - sweepWidth, 0, sweepWidth * 2, size.height));

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.progress != progress;
}

// ---------------------------------------------------------------------------
// LoginScreen
// ---------------------------------------------------------------------------
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // ── original state ──────────────────────────────────────────────────────
  final _loginIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // ── animation controllers ───────────────────────────────────────────────
  late AnimationController _particleController; // particles drift loop
  late AnimationController _pulseController; // logo ring pulse
  late AnimationController _shimmerController; // button shimmer
  late AnimationController _shakeController; // error shake
  late AnimationController _typingController; // subtitle typing

  late Animation<double> _pulseAnim;
  late Animation<double> _shakeAnim;

  // ── typing state ─────────────────────────────────────────────────────────
  static const _fullSubtitle = 'Infinity under a roof';
  String _typedSubtitle = '';

  // ── particles ─────────────────────────────────────────────────────────────
  static final _particles = <_Particle>[
    _Particle(x: 0.08, y: 0.12, size: 3.0, speed: 0.7, phase: 0.00, color: AppColors.goldPrimary),
    _Particle(x: 0.85, y: 0.18, size: 2.2, speed: 1.1, phase: 0.15, color: const Color(0xFF00E5BC)),
    _Particle(x: 0.55, y: 0.07, size: 1.8, speed: 0.9, phase: 0.33, color: AppColors.goldLight),
    _Particle(x: 0.20, y: 0.75, size: 2.6, speed: 0.6, phase: 0.52, color: AppColors.goldPrimary),
    _Particle(x: 0.90, y: 0.62, size: 1.5, speed: 1.3, phase: 0.71, color: const Color(0xFF00E5BC)),
    _Particle(x: 0.40, y: 0.88, size: 2.0, speed: 0.8, phase: 0.44, color: AppColors.goldLight),
    _Particle(x: 0.70, y: 0.45, size: 1.6, speed: 1.0, phase: 0.62, color: AppColors.goldPrimary),
    _Particle(x: 0.15, y: 0.42, size: 3.2, speed: 0.5, phase: 0.83, color: const Color(0xFF00E5BC)),
    _Particle(x: 0.60, y: 0.93, size: 1.4, speed: 1.2, phase: 0.27, color: AppColors.goldLight),
    _Particle(x: 0.33, y: 0.30, size: 2.4, speed: 0.75, phase: 0.90, color: AppColors.goldPrimary),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUpdate());

    // 1. Particle field
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // 2. Pulsating golden ring
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.93, end: 1.07).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 3. Shimmer sweep
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // 4. Shake controller for error
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    // 5. Typing animation
    _typingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _fullSubtitle.length * 75 + 400),
    );
    _typingController.addListener(_onTypingTick);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _typingController.forward();
    });
  }

  void _onTypingTick() {
    final charsToShow =
        (_typingController.value * _fullSubtitle.length).round().clamp(0, _fullSubtitle.length);
    final partial = _fullSubtitle.substring(0, charsToShow);
    if (partial != _typedSubtitle) {
      setState(() => _typedSubtitle = partial);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkUpdate();
    }
  }

  Future<void> _checkUpdate({bool force = false}) async {
    try {
      if (!mounted) return;
      final service = ref.read(appUpdateServiceProvider);
      final update = await service.checkForUpdate(force: force);
      if (update != null && mounted) {
        final autoCheck = await service.isAutoCheckEnabled();
        if (update.forceUpdate || autoCheck) {
          AppUpdateDialog.show(context, update);
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _loginIdController.dispose();
    _passwordController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _shakeController.dispose();
    _typingController.removeListener(_onTypingTick);
    _typingController.dispose();
    super.dispose();
  }

  void _login() async {
    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final loginId = _loginIdController.text.trim();
    final password = _passwordController.text.trim();

    final success = await ref.read(authProvider.notifier).login(loginId, password, forceDemo: false);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.go(RouteNames.dashboard);
      } else {
        setState(() {
          _errorMessage = 'Invalid credentials. Please try again.';
        });
        // Trigger shake
        _shakeController
          ..reset()
          ..forward();
      }
    }
  }

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: AmbientBackground(
        child: Stack(
          children: [
            // ── Layer 0: Floating particle field ──────────────────────────
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _particleController,
                builder: (_, __) => CustomPaint(
                  painter: _ParticlePainter(
                    progress: _particleController.value,
                    particles: _particles,
                  ),
                ),
              ),
            ),

            // ── Layer 1: Main scrollable content ─────────────────────────
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Pulsating ring + logo ─────────────────────────
                      AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (_, child) => Transform.scale(
                          scale: _pulseAnim.value,
                          child: child,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Golden ring glow
                            Container(
                              width: 108,
                              height: 108,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.goldPrimary.withValues(alpha: 0.55),
                                  width: 2.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.goldPrimary.withValues(alpha: 0.28),
                                    blurRadius: 22,
                                    spreadRadius: 4,
                                  ),
                                  BoxShadow(
                                    color: AppColors.goldLight.withValues(alpha: 0.12),
                                    blurRadius: 40,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            const ChintaManiLogo(
                              size: 92,
                              showGlow: true,
                              showCircularBackground: true,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms).scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.0, 1.0),
                            duration: 700.ms,
                            curve: Curves.easeOutBack,
                          ),

                      const SizedBox(height: 14),

                      // ── Library name ───────────────────────────────────
                      const Text(
                        'CHINTA MANI LIBRARY',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 500.ms)
                          .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOut),

                      const SizedBox(height: 6),

                      // ── Typing subtitle ────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.goldPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _typedSubtitle,
                              style: const TextStyle(
                                color: AppColors.goldLight,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            // blinking cursor
                            _BlinkingCursor(
                              visible: _typedSubtitle.length < _fullSubtitle.length,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(
                            begin: 0.3,
                            end: 0,
                            duration: 500.ms,
                            curve: Curves.easeOut,
                          ),

                      const SizedBox(height: 6),

                      const Text(
                        'Khalilabad • Mehdawal',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 500.ms)
                          .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOut),

                      const SizedBox(height: 20),

                      // ── Login Form Card ────────────────────────────────
                      Card3D(
                        theme: Card3DTheme.purple,
                        borderRadius: 22,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Admin Sign In',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Session saved securely on this device',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── Error message with shake ───────────────
                            if (_errorMessage != null) ...[
                              AnimatedBuilder(
                                animation: _shakeAnim,
                                builder: (_, child) => Transform.translate(
                                  offset: Offset(_shakeAnim.value, 0),
                                  child: child,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.redPrimary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: AppColors.redPrimary.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded,
                                          color: AppColors.redPrimary, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: const TextStyle(
                                              color: AppColors.redLight, fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 300.ms)
                                  .slideY(begin: -0.2, end: 0, duration: 300.ms),
                              const SizedBox(height: 12),
                            ],

                            // ── Login ID (Empty box with only prefix icon) ──────────────
                            TextField(
                              controller: _loginIdController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person_rounded,
                                    color: Color(0xFF00E5BC), size: 18),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.04),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFF00E5BC), width: 1.4),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 400.ms, duration: 450.ms)
                                .slideY(
                                    begin: 0.3, end: 0, duration: 450.ms, curve: Curves.easeOut),

                            const SizedBox(height: 12),

                            // ── Password ──────────────────────────────
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(
                                  color: AppColors.textPrimary, fontSize: 14, letterSpacing: 1.5),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle:
                                    const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                prefixIcon: const Icon(Icons.lock_outline_rounded,
                                    color: Color(0xFF00E5BC), size: 18),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.textTertiary,
                                    size: 18,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.04),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.borderSubtle),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFF00E5BC), width: 1.4),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 500.ms, duration: 450.ms)
                                .slideY(
                                    begin: 0.3, end: 0, duration: 450.ms, curve: Curves.easeOut),

                            const SizedBox(height: 16),

                            // ── Login button with shimmer ──────────────
                            _ShimmerButton(
                              shimmerController: _shimmerController,
                              isLoading: _isLoading,
                              onPressed: _isLoading ? null : _login,
                            )
                                .animate()
                                .fadeIn(delay: 600.ms, duration: 450.ms)
                                .slideY(
                                    begin: 0.3, end: 0, duration: 450.ms, curve: Curves.easeOut),

                            const SizedBox(height: 12),

                            // ── Change password ────────────────────────
                            TextButton.icon(
                              onPressed: () => _showChangePasswordDialog(context),
                              icon: const Icon(Icons.lock_reset_rounded,
                                  color: Color(0xFFD4AF37), size: 16),
                              label: const Text(
                                'Change App Password',
                                style: TextStyle(
                                  color: Color(0xFFFDE68A),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 700.ms, duration: 450.ms)
                                .slideY(
                                    begin: 0.3, end: 0, duration: 450.ms, curve: Curves.easeOut),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 350.ms, duration: 600.ms)
                          .slideY(begin: 0.25, end: 0, duration: 600.ms, curve: Curves.easeOut),

                      const SizedBox(height: 20),

                      // ── Footer ─────────────────────────────────────────
                      const Text(
                        'Developed by Prashant Mani Tripathi',
                        style: TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 500.ms)
                          .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOut),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Change password dialog (with eye toggles and authoritative auth) ─────
  void _showChangePasswordDialog(BuildContext context) {
    final oldPass = TextEditingController();
    final newPass = TextEditingController();
    final confirmPass = TextEditingController();
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0x44D4AF37), width: 1),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_reset_rounded, color: Color(0xFFD4AF37), size: 22),
              SizedBox(width: 10),
              Text('Change Password',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPass,
                  obscureText: obscureOld,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.04),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderSubtle),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD4AF37), width: 1.4),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureOld ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textTertiary,
                        size: 18,
                      ),
                      onPressed: () => setDialogState(() => obscureOld = !obscureOld),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPass,
                  obscureText: obscureNew,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.04),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderSubtle),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD4AF37), width: 1.4),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textTertiary,
                        size: 18,
                      ),
                      onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPass,
                  obscureText: obscureConfirm,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.04),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderSubtle),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD4AF37), width: 1.4),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textTertiary,
                        size: 18,
                      ),
                      onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
              ),
              onPressed: isLoading
                  ? null
                  : () async {
                      final oldP = oldPass.text.trim();
                      final newP = newPass.text.trim();
                      final cfP = confirmPass.text.trim();

                      if (oldP.isEmpty || newP.isEmpty || cfP.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All fields are required')),
                        );
                        return;
                      }
                      if (newP.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('New password must be at least 6 characters')),
                        );
                        return;
                      }
                      if (newP != cfP) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('New passwords do not match')),
                        );
                        return;
                      }
                      setDialogState(() => isLoading = true);
                      final loginId = _loginIdController.text.trim();
                      final ok = await ref.read(authProvider.notifier).changePassword(
                            oldP,
                            newP,
                            identifier: loginId.isNotEmpty ? loginId : null,
                          );
                      setDialogState(() => isLoading = false);

                      if (ctx.mounted) Navigator.pop(ctx);
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok ? '✅ Password changed successfully!' : '❌ Current password is wrong',
                          ),
                          backgroundColor:
                              ok ? const Color(0xFF10B981) : const Color(0xFFDC2626),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Text('Update', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer-overlaid login button
// ---------------------------------------------------------------------------
class _ShimmerButton extends StatelessWidget {
  final AnimationController shimmerController;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _ShimmerButton({
    required this.shimmerController,
    required this.isLoading,
    required this.onPressed,
  });

  static final _borderRadius = BorderRadius.circular(14);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: _borderRadius,
      child: Stack(
        children: [
          // Base button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFACC15),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: _borderRadius),
                elevation: 4,
                shadowColor: const Color(0x66FACC15),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF06140D)),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_open_rounded, size: 18, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Sign In to Library Desk',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                              color: Colors.black),
                        ),
                      ],
                    ),
            ),
          ),

          // Shimmer overlay (pointer-transparent)
          if (!isLoading)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: shimmerController,
                  builder: (_, __) => CustomPaint(
                    painter: _ShimmerPainter(
                      progress: shimmerController.value,
                      borderRadius: _borderRadius,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Blinking cursor widget for typing animation
// ---------------------------------------------------------------------------
class _BlinkingCursor extends StatefulWidget {
  final bool visible;
  const _BlinkingCursor({required this.visible});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();
    return FadeTransition(
      opacity: _ctrl,
      child: const Text(
        '|',
        style: TextStyle(
          color: AppColors.goldLight,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
