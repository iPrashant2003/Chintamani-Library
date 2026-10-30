import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/services/app_update_service.dart';

class AppUpdateDialog extends StatefulWidget {
  final AppUpdateInfo updateInfo;

  const AppUpdateDialog({super.key, required this.updateInfo});

  static bool _isShowing = false;

  static Future<void> show(BuildContext context, AppUpdateInfo info) async {
    // Mutex: never stack two update dialogs
    if (_isShowing) return;
    _isShowing = true;
    AppUpdateService.markPrompted();
    try {
      await showDialog(
        context: context,
        barrierDismissible: !info.forceUpdate,
        builder: (ctx) => AppUpdateDialog(updateInfo: info),
      );
    } catch (e) {
      debugPrint('[AppUpdateDialog] showDialog error: $e');
    } finally {
      _isShowing = false;
    }
  }

  @override
  State<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String _statusText = '';
  String? _errorMessage;
  Timer? _connectingTicker;
  int _connectingSeconds = 0;

  @override
  void dispose() {
    _connectingTicker?.cancel();
    super.dispose();
  }

  void _startConnectingTicker() {
    _connectingSeconds = 0;
    _connectingTicker?.cancel();
    _connectingTicker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      _connectingSeconds++;
      if (_progress < 0.05) {
        setState(() {
          _statusText = 'Connecting to server... (${_connectingSeconds}s)';
        });
      } else {
        t.cancel();
      }
    });
  }

  Future<void> _startUpdate() async {
    HapticFeedback.heavyImpact();
    setState(() {
      _isDownloading = true;
      _progress = 0.01;
      _statusText = 'Connecting to server...';
      _errorMessage = null;
    });
    _startConnectingTicker();

    final service = AppUpdateService();

    int lastReceived = 0;
    DateTime lastTime = DateTime.now();
    double currentSpeedMbS = 0.0;

    final success = await service.downloadAndInstall(
      info: widget.updateInfo,
      onProgress: (p, received, total) {
        if (!mounted) return;
        if (p > 0.03) _connectingTicker?.cancel();
        final now = DateTime.now();
        final elapsedMs = now.difference(lastTime).inMilliseconds;
        if (elapsedMs >= 350) {
          final bytesDelta = received - lastReceived;
          if (bytesDelta >= 0) {
            currentSpeedMbS = (bytesDelta / 1048576) / (elapsedMs / 1000);
          }
          lastReceived = received;
          lastTime = now;
        }

        final recMb = (received / 1048576).toStringAsFixed(1);
        final totMb = total > 0 ? (total / 1048576).toStringAsFixed(1) : '--';
        final speedStr = currentSpeedMbS > 0.05 ? ' • ${currentSpeedMbS.toStringAsFixed(1)} MB/s' : '';

        setState(() {
          _progress = p;
          _statusText = '${(p * 100).toInt()}% ($recMb / $totMb MB$speedStr)';
        });
      },
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _isDownloading = false;
        _statusText = 'Launching Installer...';
      });
      Navigator.of(context).pop();
    } else {
      setState(() {
        _isDownloading = false;
        _errorMessage = service.lastErrorMessage ?? 'Update interrupted. Tap Retry Update to continue.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.updateInfo;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B150C), Color(0xFF0F0C08), Color(0xFF151009)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.8),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.22),
              blurRadius: 36,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            const BoxShadow(
              color: Colors.black,
              blurRadius: 25,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Subtle ambient gold radial glow behind the top logo
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                height: 160,
                child: Center(
                  child: Container(
                    width: 220,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFD4AF37).withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Dismiss button (top-right close cross) if not forced and not downloading
              if (!info.forceUpdate && !_isDownloading)
                Positioned(
                  top: 14,
                  right: 14,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.close_rounded,
                          color: Color(0xFFD4AF37),
                          size: 17,
                        ),
                      ),
                    ),
                  ),
                ),

              // Main Card Content
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Live 3D Interactive Logo ──
                    const Live3DLogo(),
                    const SizedBox(height: 12),

                    // Header titles
                    const Text(
                      'CHINTAMANI LIBRARY',
                      style: TextStyle(
                        color: Color(0xFFFDE68A),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.2,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Version Pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFD4AF37).withValues(alpha: 0.25),
                                const Color(0xFF854D0E).withValues(alpha: 0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.7),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'v${info.version}',
                            style: const TextStyle(
                              color: Color(0xFFFFDF73),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (info.releaseDate.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            info.releaseDate,
                            style: const TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ── Changes List Section ──
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "WHAT'S NEW",
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Scrollable Changes Container
                    Container(
                      constraints: const BoxConstraints(maxHeight: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C0905),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.22),
                          width: 1,
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: info.releaseNotes.isNotEmpty
                              ? info.releaseNotes.map((note) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 5, right: 9),
                                          width: 5.5,
                                          height: 5.5,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFD4AF37),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                                                blurRadius: 4,
                                                spreadRadius: 0.5,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            note,
                                            style: const TextStyle(
                                              color: Color(0xFFECEFF1),
                                              fontSize: 12,
                                              height: 1.42,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList()
                              : const [
                                  Text(
                                    'Performance enhancements, security updates, and new features.',
                                    style: TextStyle(
                                      color: Color(0xFFB0BEC5),
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                        ),
                      ),
                    ),

                    // Error Message (if any)
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C1010),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: Color(0xFFEF4444), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Color(0xFFFCA5A5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Progress indicator if downloading
                    if (_isDownloading) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _progress > 0 ? _progress : null,
                          minHeight: 8,
                          backgroundColor: const Color(0xFF241B0E),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _statusText,
                        style: const TextStyle(
                          color: Color(0xFFFDE68A),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ── Primary Action: Update Button Only ──
                    GestureDetector(
                      onTap: _isDownloading ? null : _startUpdate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFDF73), Color(0xFFD4AF37), Color(0xFFB4851E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.38),
                              blurRadius: 16,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isDownloading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2.4,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _errorMessage != null
                                          ? Icons.refresh_rounded
                                          : Icons.arrow_circle_down_rounded,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _errorMessage != null ? 'Retry Update' : 'Update Now',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A custom animated, interactive 3D Floating Emblem with perspective lighting.
class Live3DLogo extends StatefulWidget {
  const Live3DLogo({super.key});

  @override
  State<Live3DLogo> createState() => _Live3DLogoState();
}

class _Live3DLogoState extends State<Live3DLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _touchTiltX = 0.0;
  double _touchTiltY = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _touchTiltY = (_touchTiltY + details.delta.dx * 0.015).clamp(-0.4, 0.4);
          _touchTiltX = (_touchTiltX - details.delta.dy * 0.015).clamp(-0.4, 0.4);
        });
      },
      onPanEnd: (_) {
        setState(() {
          _touchTiltX = 0.0;
          _touchTiltY = 0.0;
        });
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final val = _controller.value;
          // Smooth continuous float up/down
          final floatY = math.sin(val * 2 * math.pi) * 4.5;
          // Gentle organic 3D yaw/pitch
          final autoYaw = math.sin(val * 2 * math.pi) * 0.22;
          final autoPitch = math.cos(val * 2 * math.pi) * 0.08;

          final currentYaw = autoYaw + _touchTiltY;
          final currentPitch = autoPitch + _touchTiltX;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 3D Perspective Transform
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0022) // 3D perspective depth
                  ..setTranslationRaw(0.0, floatY, 0.0)
                  ..rotateX(currentPitch)
                  ..rotateY(currentYaw),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const SweepGradient(
                      colors: [
                        Color(0xFFFFDF73),
                        Color(0xFFD4AF37),
                        Color(0xFF854D0E),
                        Color(0xFFFFDF73),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: Offset(currentYaw * 12, 6 - floatY * 0.5),
                      ),
                      const BoxShadow(
                        color: Colors.black,
                        blurRadius: 14,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.5),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFF261D10),
                            Color(0xFF0F0B06),
                          ],
                        ),
                      ),
                      child: Center(
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.local_library_rounded,
                                color: Color(0xFFD4AF37),
                                size: 36,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Dynamic Floor Ambient Shadow (reacts to floatY)
              Container(
                width: math.max(16, 52 - floatY * 2),
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: (0.45 - (floatY / 20)).clamp(0.15, 0.6)),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
