import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_colors.dart';
import '../../../core/api/api_endpoints.dart';
import '../../branch/providers/branch_provider.dart';
import 'universal_qr_screen.dart';

class QrHubScreen extends ConsumerWidget {
  const QrHubScreen({super.key});

  void _shareViaWhatsApp(BuildContext context, String url, String branchName) async {
    final msg = Uri.encodeComponent(
      '🏛️ *CHINTAMANI LIBRARY — OFFICIAL MEMBER PORTAL*\n'
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
      '📍 *Branch*: $branchName\n\n'
      'Scan or tap the link below to access self-service features:\n'
      '👉 $url\n\n'
      '✨ *Portal Features*:\n'
      '• 👤 New Student Registration & Admission\n'
      '• 💳 Fee & Maintenance Payment via UPI\n'
      '• ⏱️ Student Self-Attendance Check-In\n'
      '• 🪑 Real-Time Seat & Shift Availability\n'
      '• 🛠 Facility Support & Complaints Desk\n\n'
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
            'Chintamani Library Official Member Portal:\n$url\n\n'
            'Register for admissions, mark attendance, pay monthly fees via UPI, and submit support tickets.',
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
                    'Universal Access: Self Check-In • Admissions • UPI • Support',
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
    final activeBranch = ref.watch(activeBranchProvider);
    final qrDataAsync = ref.watch(universalQrDataProvider);

    final portalUrl = qrDataAsync.value?['portalUrl'] as String? ?? UniversalQrScreen.buildPortalUrl();
    final branchName = qrDataAsync.value?['branchName'] as String? ?? activeBranch.name;

    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B12),
        elevation: 0,
        title: const Text(
          'Universal QR & Attendance Hub',
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          children: [
            // ── 1. MAIN UNIVERSAL QR CARD ────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xF20D111A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFC9A84C).withValues(alpha: 0.28),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: const Color(0xFFC9A84C).withValues(alpha: 0.06),
                    blurRadius: 28,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9A84C).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFC9A84C).withValues(alpha: 0.35)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(radius: 3.5, backgroundColor: Color(0xFF34D399)),
                        SizedBox(width: 6),
                        Text(
                          'OFFICIAL MEMBER PORTAL • LIVE',
                          style: TextStyle(
                            color: Color(0xFFE8C97A),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.auto_stories_rounded,
                            color: Color(0xFFC9A84C),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'CHINTAMANI LIBRARY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    branchName,
                    style: const TextStyle(
                      color: Color(0xFFC9A84C),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // QR Box — Always renders natively on device with QrImageView
                  GestureDetector(
                    onTap: () => _showFullScreenQr(context, portalUrl, branchName),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFC9A84C).withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: portalUrl,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                        dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                        errorStateBuilder: (cxt, err) => const SizedBox(
                          width: 200,
                          height: 200,
                          child: Center(
                            child: Icon(Icons.qr_code_2_rounded, size: 80, color: Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'Point Phone Camera to Open Portal',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Admissions • UPI Payment • Complaints • Attendance Check-In',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 10.5),
                  ),
                  const SizedBox(height: 14),

                  // URL Copy Chip
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: portalUrl));
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Portal link copied to clipboard!'),
                          duration: Duration(milliseconds: 1400),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.link_rounded, size: 14, color: Color(0xFFC9A84C)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              portalUrl,
                              style: const TextStyle(
                                color: Color(0xFFE8C97A),
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.copy_rounded, size: 14, color: Color(0xFFC9A84C)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Share & Open Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _shareViaWhatsApp(context, portalUrl, branchName),
                    icon: const Icon(Icons.chat_rounded, size: 16),
                    label: const Text('Send on WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A84C),
                      foregroundColor: const Color(0xFF080B12),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      final uri = Uri.parse(portalUrl);
                      try {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Portal link: $portalUrl')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                    label: const Text('Open in Browser', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Fullscreen & Share Sheet buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF06B6D4),
                      side: BorderSide(color: const Color(0xFF06B6D4).withValues(alpha: 0.4), width: 0.8),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _showFullScreenQr(context, portalUrl, branchName),
                    icon: const Icon(Icons.crop_free_rounded, size: 16),
                    label: const Text('Counter Display Mode', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF8B5CF6),
                      side: BorderSide(color: const Color(0xFF8B5CF6).withValues(alpha: 0.4), width: 0.8),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Share.share(
                        '🏛️ Chintamani Library — Official Member Portal ($branchName)\n'
                        'Scan or tap to access:\n$portalUrl\n\n'
                        '• New Student Registration & Seat Booking\n'
                        '• Direct UPI Fee Payments\n'
                        '• Student Self-Attendance Check-In\n'
                        '• Facility Support & Complaints Desk',
                      );
                    },
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: const Text('Share Portal Link', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Brand statement info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xF20D111A),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CHINTAMANI LIBRARY UNIVERSAL QR ECOSYSTEM',
                    style: TextStyle(
                      color: Color(0xFFC9A84C),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'One QR for Every Member & Scholar Service',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Members can scan this universal QR code from anywhere to record their daily attendance, register for study seats, submit UPI payment proofs, or raise facility support tickets.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
