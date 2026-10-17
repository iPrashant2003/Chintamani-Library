import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/ambient_background.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../branch/providers/branch_provider.dart';

final universalQrDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final client = ref.read(apiClientProvider);
    final branch = ref.read(activeBranchProvider);
    final response = await client.dio.get(
      ApiEndpoints.portalQr,
      queryParameters: {'branchId': branch.id},
    );
    final data = response.data as Map<String, dynamic>;
    data['portalUrl'] = UniversalQrScreen.buildPortalUrl();
    return data;
  } catch (_) {
    final branch = ref.read(activeBranchProvider);
    return {
      'portalUrl': UniversalQrScreen.buildPortalUrl(),
      'branchName': branch.name,
      'isOffline': true,
    };
  }
});

class UniversalQrScreen extends ConsumerWidget {
  const UniversalQrScreen({super.key});

  /// Permanent global public production URL hosted on GitHub Pages (24/7 HTTPS, accessible worldwide)
  static const String publicProductionUrl = 'https://iprashant2003.github.io/Chintamani-Library/';

  /// Builds the portal URL from the production deployment or active HTTPS backend.
  static String buildPortalUrl() {
    final base = ApiEndpoints.baseUrl.trim();
    if (base.startsWith('https://') && !base.contains('localhost') && !base.contains('127.0.0.1')) {
      final stripped = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
      return '$stripped/portal/index.html';
    }
    return publicProductionUrl;
  }

  void _shareViaWhatsApp(BuildContext context, String url, String branchName) async {
    final msg = Uri.encodeComponent(
      '🏛️ *CHINTAMANI LIBRARY — MEMBER PORTAL*\n'
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
      '📍 *Branch*: $branchName\n\n'
      'Scan or tap the link below to access self-service features:\n'
      '👉 $url\n\n'
      '✨ *What you can do*:\n'
      '• 👤 New Student Registration & Admission\n'
      '• 💳 Fee & Maintenance Payment via UPI\n'
      '• 🪑 Real-Time Seat & Shift Availability\n'
      '• 🛠 Facility Support & Complaints Desk\n'
      '• 📋 Application Status Tracking\n\n'
      '📞 *Helpline*: +91 9415919277 / 7388389944\n'
      '_Chintamani Library — Infinity under a roof_',
    );

    final directUri = Uri.parse('whatsapp://send?text=$msg');
    try {
      final launched = await launchUrl(directUri, mode: LaunchMode.externalApplication);
      if (!launched) throw Exception('Could not launch WhatsApp');
    } catch (_) {
      try {
        final webUri = Uri.parse('https://api.whatsapp.com/send?text=$msg');
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (context.mounted) {
          Share.share(
            'Chintamani Library Member Portal:\n$url\n\n'
            'Register for admissions, pay monthly fees via UPI, track applications & submit support tickets.',
          );
        }
      }
    }
  }

  void _showFullScreenQr(BuildContext context, String url, String branchName) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.94),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0C1018),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFC9A84C), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC9A84C).withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.auto_stories_rounded,
                            color: Color(0xFFC9A84C),
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'CHINTAMANI LIBRARY',
                        style: TextStyle(
                          color: Color(0xFFE8C97A),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    branchName,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: QrImageView(
                      data: url,
                      version: QrVersions.auto,
                      size: 260,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                      dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Scan with Phone Camera or Google Lens',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Admissions • UPI Payment • Complaints • Seat Info',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrDataAsync = ref.watch(universalQrDataProvider);
    final activeBranch = ref.watch(activeBranchProvider);

    final portalUrl = qrDataAsync.value?['portalUrl'] as String? ?? buildPortalUrl();
    final branchName = qrDataAsync.value?['branchName'] as String? ?? activeBranch.name;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Universal Member Portal QR',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Counter Display Mode',
            icon: const Icon(Icons.fullscreen_rounded, color: Color(0xFFC9A84C), size: 24),
            onPressed: () => _showFullScreenQr(context, portalUrl, branchName),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFC9A84C)),
            onPressed: () => ref.invalidate(universalQrDataProvider),
          ),
        ],
      ),
      body: AmbientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            children: [
              // ── 4D Premium Interactive QR Card ──
              _UniversalQr4DCard(
                portalUrl: portalUrl,
                branchName: branchName,
                onTapQr: () => _showFullScreenQr(context, portalUrl, branchName),
              ),

              const SizedBox(height: 20),

              // ── Quick Sharing & Browser Actions ──
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                        elevation: 3,
                      ),
                      onPressed: () => _shareViaWhatsApp(context, portalUrl, branchName),
                      icon: const Icon(Icons.chat_rounded, size: 16),
                      label: const Text('Send on WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC9A84C),
                        foregroundColor: const Color(0xFF080B12),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                        elevation: 3,
                      ),
                      onPressed: () async {
                        final uri = Uri.parse(portalUrl);
                        try {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening portal in browser...')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                      label: const Text('Open in Browser', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF06B6D4),
                        side: BorderSide(color: const Color(0xFF06B6D4).withValues(alpha: 0.45), width: 0.9),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                      ),
                      onPressed: () => _showFullScreenQr(context, portalUrl, branchName),
                      icon: const Icon(Icons.crop_free_rounded, size: 16),
                      label: const Text('Counter Display Mode', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8B5CF6),
                        side: BorderSide(color: const Color(0xFF8B5CF6).withValues(alpha: 0.45), width: 0.9),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                      ),
                      onPressed: () {
                        Share.share(
                          '🏛️ Chintamani Library ($branchName)\n'
                          'Scan or tap to access the self-service member portal:\n$portalUrl\n\n'
                          '• New Student Registration & Seat Booking\n'
                          '• Direct UPI Fee Payments\n'
                          '• Complaints Desk & Inquiries\n'
                          '• Live Seat & Shift Availability',
                        );
                      },
                      icon: const Icon(Icons.share_rounded, size: 16),
                      label: const Text('Share Portal Link', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14121B),
                    foregroundColor: const Color(0xFF00E5BC),
                    side: BorderSide(color: const Color(0xFF00E5BC).withValues(alpha: 0.45), width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                  ),
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                  label: const Text('Launch Camera Attendance Scanner', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push(RouteNames.attendance);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 4D Premium Animated QR Card Widget
/// Features:
/// - Multi-layered depth and subtle 3D perspective tilt
/// - Animated light reflection / specular glint sweep across frame every 3.5s
/// - Fine dot-matrix accent in the background
/// - High-contrast, completely unobstructed 100% scannable QR code
class _UniversalQr4DCard extends StatefulWidget {
  final String portalUrl;
  final String branchName;
  final VoidCallback onTapQr;

  const _UniversalQr4DCard({
    required this.portalUrl,
    required this.branchName,
    required this.onTapQr,
  });

  @override
  State<_UniversalQr4DCard> createState() => _UniversalQr4DCardState();
}

class _UniversalQr4DCardState extends State<_UniversalQr4DCard>
    with TickerProviderStateMixin {
  late final AnimationController _tiltController;
  late final Animation<double> _tiltAnimation;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    // Gentle 4D floating tilt animation (3.8 seconds reverse cycle)
    _tiltController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat(reverse: true);
    _tiltAnimation = CurvedAnimation(
      parent: _tiltController,
      curve: Curves.easeInOutSine,
    );

    // Specular light sweep across card frame every 3.5 seconds
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat();
  }

  @override
  void dispose() {
    _tiltController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _tiltAnimation,
      builder: (context, child) {
        final tiltY = ((_tiltAnimation.value - 0.5) * 2) * 0.025; // Subtle Y rotation
        final tiltX = math.sin(_tiltAnimation.value * math.pi) * 0.015;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // 3D Perspective
            ..rotateX(tiltX)
            ..rotateY(tiltY),
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xF40A0D15),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: const Color(0xFFC9A84C).withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.85),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: const Color(0xFFC9A84C).withValues(alpha: 0.12),
              blurRadius: 36,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background Fine Dot Matrix Accent
            Positioned.fill(
              child: CustomPaint(
                painter: _DotMatrixAccentPainter(),
              ),
            ),

            // Main Card Content
            Column(
              children: [
                // Header: Logo & Chintamani Library Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 26,
                        height: 26,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.auto_stories_rounded,
                          color: Color(0xFFC9A84C),
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'CHINTAMANI LIBRARY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.branchName,
                  style: const TextStyle(
                    color: Color(0xFFE8C97A),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 20),

                // ── QR Container with Specular Glint Border ──
                GestureDetector(
                  onTap: widget.onTapQr,
                  child: AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _FrameSpecularPainter(progress: _shimmerController.value),
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: const Color(0xFFC9A84C).withValues(alpha: 0.25),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      // Completely crisp, un-occluded QR code
                      child: QrImageView(
                        data: widget.portalUrl,
                        version: QrVersions.auto,
                        size: 220,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                        errorStateBuilder: (cxt, err) => const SizedBox(
                          width: 220,
                          height: 220,
                          child: Center(
                            child: Icon(Icons.qr_code_2_rounded, size: 80, color: Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Instructions & Features List
                const Text(
                  'Scan with Phone Camera or Google Lens',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Admissions • UPI Payment • Complaints • Seat Info',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer glint traveling along the border frame of the QR container
class _FrameSpecularPainter extends CustomPainter {
  final double progress;

  _FrameSpecularPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(-4, -4, size.width + 8, size.height + 8);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));

    final sweepX = (progress * 2.0 - 0.5) * size.width;
    const sweepWidth = 80.0;

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFFD4AF37).withValues(alpha: 0.6),
          Colors.white.withValues(alpha: 0.9),
          const Color(0xFFD4AF37).withValues(alpha: 0.6),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(sweepX - sweepWidth, -4, sweepWidth * 2, size.height + 8))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_FrameSpecularPainter oldDelegate) => oldDelegate.progress != progress;
}

/// Fine Background Dot-Matrix Accent
class _DotMatrixAccentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = const Color(0xFFC9A84C).withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    const spacing = 18.0;
    for (double x = 8.0; x < size.width; x += spacing) {
      for (double y = 8.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
