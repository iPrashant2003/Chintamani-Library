import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_colors.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../branch/providers/branch_provider.dart';

final universalQrDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final branch = ref.read(activeBranchProvider);
  final response = await client.dio.get(
    ApiEndpoints.portalQr,
    queryParameters: {'branchId': branch.id},
  );
  return response.data as Map<String, dynamic>;
});

class UniversalQrScreen extends ConsumerWidget {
  const UniversalQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrDataAsync = ref.watch(universalQrDataProvider);
    final activeBranch = ref.watch(activeBranchProvider);

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
            icon: const Icon(Icons.refresh_rounded, color: AppColors.goldPrimary),
            onPressed: () => ref.invalidate(universalQrDataProvider),
          ),
        ],
      ),
      body: qrDataAsync.when(
        data: (data) {
          final portalUrl = data['portalUrl'] as String? ?? 'https://chintamani-library.in/portal/index.html';
          final qrDataUrl = data['qrDataUrl'] as String? ?? '';
          final branchName = data['branchName'] as String? ?? activeBranch.name;

          Uint8List? qrBytes;
          if (qrDataUrl.startsWith('data:image/png;base64,')) {
            final base64Str = qrDataUrl.replaceFirst('data:image/png;base64,', '');
            try {
              qrBytes = base64Decode(base64Str);
            } catch (_) {}
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              children: [
                // Luxury QR Poster Card
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
                          'OFFICIAL UNIVERSAL LIBRARY QR',
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

                      // QR Box (White crisp container for reliable phone camera scanning)
                      Container(
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
                        child: qrBytes != null
                            ? Image.memory(
                                qrBytes,
                                width: 220,
                                height: 220,
                                fit: BoxFit.contain,
                              )
                            : Image.network(
                                '${ApiEndpoints.baseUrl}/qr/universal-portal-qr.png',
                                width: 220,
                                height: 220,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const SizedBox(
                                  width: 220,
                                  height: 220,
                                  child: Center(
                                    child: Icon(Icons.qr_code_2_rounded, size: 80, color: Colors.black54),
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
                        'Registration • UPI Payment • Seats • Complaints',
                        style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                      ),
                      const SizedBox(height: 16),

                      // URL copy chip
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: portalUrl));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Portal link copied to clipboard')),
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
                        onPressed: () {
                          Share.share(
                            'Scan to access the Chintamani Library Universal Member Portal:\n$portalUrl\n\n'
                            '• Register for new admission\n• Pay monthly membership fees via UPI\n• Track application status & submit complaints',
                          );
                        },
                        icon: const Icon(Icons.share_rounded, size: 16),
                        label: const Text('Share Portal Link', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                        label: const Text('Open in Browser', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.goldPrimary)),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.redPrimary, size: 36),
              const SizedBox(height: 8),
              Text('Failed to load portal QR: $err', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(universalQrDataProvider),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary),
                child: const Text('Retry', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
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
