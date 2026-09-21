import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/app_lock_service.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/ambient_background.dart';
import '../../../widgets/chintamani_logo.dart';

class AppLockScreen extends StatefulWidget {
  final VoidCallback? onUnlocked;
  const AppLockScreen({super.key, this.onUnlocked});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen>
    with SingleTickerProviderStateMixin {
  bool _isChecking = false;
  bool _failed = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    // Auto-trigger on open
    Future.delayed(const Duration(milliseconds: 600), _triggerBiometricAuth);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _triggerBiometricAuth() async {
    if (_isChecking) return;
    setState(() {
      _isChecking = true;
      _failed = false;
    });
    final success = await AppLockService.instance.authenticateWithBiometrics();
    if (mounted) {
      setState(() => _isChecking = false);
      if (success) {
        _handleSuccess();
      } else {
        setState(() => _failed = true);
        HapticFeedback.heavyImpact();
      }
    }
  }

  void _handleSuccess() {
    HapticFeedback.mediumImpact();
    AppLockService.instance.unlock();
    if (widget.onUnlocked != null) {
      widget.onUnlocked!();
    } else {
      context.go(RouteNames.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: AmbientBackground(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const ChintaManiLogo(
                      size: 78,
                      showGlow: true,
                      showCircularBackground: true,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'CHINTA MANI LIBRARY',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'App Lock',
                      style: TextStyle(
                        color: AppColors.goldPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 52),

                    // Biometric button — pulsing ring
                    GestureDetector(
                      onTap: _isChecking ? null : _triggerBiometricAuth,
                      child: AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _isChecking ? 1.0 : _pulseAnim.value,
                            child: child,
                          );
                        },
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.goldPrimary.withValues(alpha: 0.18),
                                Colors.black.withValues(alpha: 0.0),
                              ],
                            ),
                            border: Border.all(
                              color: _failed
                                  ? AppColors.redPrimary
                                  : AppColors.goldPrimary,
                              width: 1.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _failed
                                    ? AppColors.redPrimary.withValues(alpha: 0.28)
                                    : AppColors.goldPrimary.withValues(alpha: 0.30),
                                blurRadius: 28,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: _isChecking
                              ? const Center(
                                  child: SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.goldPrimary,
                                    ),
                                  ),
                                )
                              : Icon(
                                  _failed
                                      ? Icons.fingerprint_rounded
                                      : Icons.fingerprint_rounded,
                                  color: _failed
                                      ? AppColors.redPrimary
                                      : AppColors.goldPrimary,
                                  size: 58,
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      _isChecking
                          ? 'Verifying...'
                          : _failed
                              ? 'Not recognized — tap to retry'
                              : 'Tap to unlock',
                      style: TextStyle(
                        color: _failed ? AppColors.redLight : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 8),
                    const Text(
                      'Use phone fingerprint or face unlock',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
