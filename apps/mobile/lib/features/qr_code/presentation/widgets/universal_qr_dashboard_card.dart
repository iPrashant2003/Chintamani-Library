import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../theme/app_colors.dart';
import '../../../branch/providers/branch_provider.dart';
import '../universal_qr_screen.dart';

class UniversalQrDashboardCard extends ConsumerWidget {
  const UniversalQrDashboardCard({super.key});

  void _openPortal(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Portal link: $url')),
        );
      }
    }
  }

  void _copyPortalLink(BuildContext context, String url) {
    Clipboard.setData(ClipboardData(text: url));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Portal link copied to clipboard!'),
        duration: Duration(milliseconds: 1600),
      ),
    );
  }

  void _sharePortal(String url, String branchName) {
    Share.share(
      '🏛️ Chintamani Library — Official Member Portal ($branchName)\n'
      'One simple entry point for members.\n\n'
      'Scan or tap to access:\n'
      '👉 $url\n\n'
      '• New Admissions & Seat Booking\n'
      '• Direct UPI Fee Payments\n'
      '• Facility Feedback & Complaints Desk\n'
      '• Live Seat & Shift Availability\n\n'
      '📞 Helpline: 9415919277 / 7388389944',
    );
  }

  void _showFullscreenMode(BuildContext context, String url, String branchName) {
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
                    blurRadius: 32,
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
                        'CHINTAMANI',
                        style: TextStyle(
                          color: Color(0xFFE8C97A),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
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
                      size: 250,
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
                    'Registration • UPI Payments • Seat Status • Support',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBranch = ref.watch(activeBranchProvider);
    final portalUrl = UniversalQrScreen.buildPortalUrl();
    final branchName = activeBranch.name;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xF20D111A),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFC9A84C).withValues(alpha: 0.22),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: const Color(0xFFC9A84C).withValues(alpha: 0.05),
              blurRadius: 28,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top luxury gold accent line
              Container(
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color(0xFFC9A84C),
                      Color(0xFFE8C97A),
                      Color(0xFFC9A84C),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar: Title + Status Online badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFC9A84C).withValues(alpha: 0.3),
                                ),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.qr_code_2_rounded,
                                    color: Color(0xFFC9A84C),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'UNIVERSAL QR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Text(
                                  'Member Portal • $branchName',
                                  style: const TextStyle(
                                    color: Color(0xFFC9A84C),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Status: ● Online badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A7A5E).withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF1A7A5E).withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 3,
                                backgroundColor: Color(0xFF34D399),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Online',
                                style: TextStyle(
                                  color: Color(0xFF34D399),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Main Content: Left Branding text + Right QR code (Responsive Layout)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 350;

                        final qrWidget = GestureDetector(
                          onTap: () => _showFullscreenMode(context, portalUrl, branchName),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFC9A84C).withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: QrImageView(
                              data: portalUrl,
                              version: QrVersions.auto,
                              size: 130,
                              backgroundColor: Colors.white,
                              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                            ),
                          ),
                        );

                        final infoWidget = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'One QR. One simple entry point for members.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Scan to register, pay via UPI, submit feedback or raise complaints securely from any phone.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 11.5,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Clickable URL bar
                            GestureDetector(
                              onTap: () => _copyPortalLink(context, portalUrl),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.link_rounded, size: 12, color: Color(0xFFC9A84C)),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        portalUrl,
                                        style: const TextStyle(
                                          color: Color(0xFFE8C97A),
                                          fontSize: 10,
                                          fontFamily: 'monospace',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.copy_rounded, size: 11, color: Color(0xFFC9A84C)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );

                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: infoWidget),
                              const SizedBox(width: 14),
                              qrWidget,
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(child: qrWidget),
                              const SizedBox(height: 12),
                              infoWidget,
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Action Buttons Grid: [ Open Portal ] [ Copy Link ] [ Counter Display ] [ Share ]
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC9A84C),
                              foregroundColor: const Color(0xFF080B12),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            onPressed: () => _openPortal(context, portalUrl),
                            icon: const Icon(Icons.open_in_browser_rounded, size: 15),
                            label: const Text(
                              'Open Portal',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFE8C97A),
                              side: BorderSide(color: const Color(0xFFC9A84C).withValues(alpha: 0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => _copyPortalLink(context, portalUrl),
                            icon: const Icon(Icons.copy_rounded, size: 14),
                            label: const Text(
                              'Copy Link',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF06B6D4),
                              side: BorderSide(color: const Color(0xFF06B6D4).withValues(alpha: 0.4)),
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => _showFullscreenMode(context, portalUrl, branchName),
                            icon: const Icon(Icons.crop_free_rounded, size: 14),
                            label: const Text(
                              'Counter Mode',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF8B5CF6),
                              side: BorderSide(color: const Color(0xFF8B5CF6).withValues(alpha: 0.4)),
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => _sharePortal(portalUrl, branchName),
                            icon: const Icon(Icons.share_rounded, size: 14),
                            label: const Text(
                              'Share QR',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
                            ),
                          ),
                        ),
                      ],
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
