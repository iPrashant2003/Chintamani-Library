import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_colors.dart';
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
    // Always override portalUrl with the LAN-accessible URL
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

  /// Builds the portal URL from the backend's current base URL.
  /// Guarantees that localhost / 127.0.0.1 are never used for QR codes.
  static String buildPortalUrl() {
    String base = ApiEndpoints.baseUrl.trim();
    if (base.contains('localhost') || base.contains('127.0.0.1') || base.isEmpty) {
      base = ApiEndpoints.defaultWifiUrl;
    }
    final stripped = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    return '$stripped/portal/index.html';
  }

  /// Permanent fallback in case ApiEndpoints.baseUrl is empty/unavailable
  static const String _fallbackUrl = 'http://192.168.1.35:3000/portal/index.html';

  void _shareViaWhatsApp(BuildContext context, String url, String branchName) async {
    final msg = Uri.encodeComponent(
      '🏛️ *CHINTAMANI LIBRARY — OFFICIAL MEMBER PORTAL*\n'
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
            'Chintamani Library Official Member Portal:\n$url\n\n'
            'Register for admissions, pay monthly fees via UPI, track applications & submit support tickets.',
          );
        }
      }
    }
  }

  void _showFullScreenQr(BuildContext context, String url, String branchName) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF14120E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.goldPrimary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldPrimary.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'CHINTAMANI LIBRARY',
                    style: TextStyle(
                      color: AppColors.goldBright,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    branchName,
                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
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
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        title: const Text(
          'Universal Member Portal QR',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Fullscreen Reception Mode',
            icon: const Icon(Icons.fullscreen_rounded, color: AppColors.goldPrimary, size: 24),
            onPressed: () => _showFullScreenQr(context, portalUrl, branchName),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.goldPrimary),
            onPressed: () => ref.invalidate(universalQrDataProvider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          children: [
            // Permanent Luxury QR Poster Card (Zero network delay)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xF2131A24),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.goldPrimary.withOpacity(0.35), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldPrimary.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.goldPrimary.withOpacity(0.4)),
                    ),
                    child: const Text(
                      'PERMANENT OFFICIAL LIBRARY QR',
                      style: TextStyle(
                        color: AppColors.goldLight,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    'CHINTAMANI LIBRARY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    branchName,
                    style: const TextStyle(
                      color: AppColors.goldPrimary,
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
                  const SizedBox(height: 14),

                  const Text(
                    'Scan with Camera or Google Lens',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Admissions • UPI Payment • Complaints • Seats',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                  ),
                  const SizedBox(height: 16),

                  // URL copy chip
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
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0x22FFFFFF)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              portalUrl,
                              style: const TextStyle(color: AppColors.goldLight, fontSize: 11, fontFamily: 'monospace'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.copy_rounded, size: 14, color: AppColors.goldPrimary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Share & Open Buttons
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
                    label: const Text('Send on WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.goldPrimary,
                      side: const BorderSide(color: AppColors.goldPrimary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    label: const Text('Open in Browser', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                      side: const BorderSide(color: Color(0xFF06B6D4), width: 0.8),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      side: const BorderSide(color: Color(0xFF8B5CF6), width: 0.8),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Share.share(
                        'Scan to open Chintamani Library Universal Member Portal:\n$portalUrl\n\n'
                        '• New Student Registration & Seat Booking\n'
                        '• Direct UPI Fee Payments\n'
                        '• Complaint & Maintenance Desk\n'
                        '• Live Seat & Shift Availability',
                      );
                    },
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: const Text('Share Portal Link', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // What Members Can Do Checklist
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xF2141A24),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x22FFFFFF), width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'UNIVERSAL PORTAL CAPABILITIES',
                    style: TextStyle(
                      color: AppColors.goldPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(Icons.person_add_alt_1_rounded, 'New Member Registration', 'Self registration with selfie, Aadhaar & auto-seat booking'),
                  _buildFeatureItem(Icons.credit_card_rounded, 'Direct UPI Fee Payments', 'Deep link to UPI apps with screenshot proof upload'),
                  _buildFeatureItem(Icons.history_rounded, '6-Month Member History', 'Full payment, seat allocation, and plan timeline'),
                  _buildFeatureItem(Icons.event_seat_rounded, 'Live Seat & Plan Stats', 'Real-time available seat counts for 24h, 12h, 6h shifts'),
                  _buildFeatureItem(Icons.report_problem_outlined, 'Facility Complaint Desk', 'Rapid resolution for AC, electricity, sockets & seating'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.goldPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
