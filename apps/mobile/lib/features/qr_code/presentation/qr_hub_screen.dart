import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/ambient_background.dart';
import '../../../widgets/glass_text_field.dart';
import '../../../widgets/primary_button.dart';
import '../../attendance/data/attendance_repository.dart';
import '../../branch/providers/branch_provider.dart';

class QrHubScreen extends ConsumerStatefulWidget {
  const QrHubScreen({super.key});

  @override
  ConsumerState<QrHubScreen> createState() => _QrHubScreenState();
}

class _QrHubScreenState extends ConsumerState<QrHubScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController(text: 'CML-942810');
  String _qrData = 'CML-942810';
  String _simulatedMemberName = 'Aarav Sharma';

  static const String _admissionQrUrl =
      'https://wa.me/919415919277?text=Hello%20Chinta%20Mani%20Library%20Management%2C%20I%20visited%20the%20library%20and%20want%20to%20apply%20for%20admission%20%2F%20reserve%20a%20study%20seat.%20Please%20guide%20me%20with%20available%20shifts%20and%20plans.';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _testAdmissionWhatsApp() async {
    HapticFeedback.mediumImpact();
    final uri = Uri.parse(_admissionQrUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeBranch = ref.watch(activeBranchProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF090B0A),
        title: const Text(
          'QR Hub & Notice Poster',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00E5BC),
          labelColor: const Color(0xFF00E5BC),
          unselectedLabelColor: AppColors.textSecondary,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(icon: Icon(Icons.campaign_rounded, size: 18), text: 'Admission Poster QR'),
            Tab(icon: Icon(Icons.badge_rounded, size: 18), text: 'Scholar Pass QR'),
            Tab(icon: Icon(Icons.qr_code_scanner_rounded, size: 18), text: 'Scan Attendance'),
          ],
        ),
      ),
      body: AmbientBackground(
        child: TabBarView(
          controller: _tabController,
          children: [
            // ── Tab 1: Notice Board Admission Poster QR ───────────────────────
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF00E5BC).withValues(alpha: 0.20),
                          const Color(0xF7151518),
                          const Color(0xFA080808),
                          Colors.black,
                        ],
                        stops: const [0.0, 0.40, 0.75, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFF00E5BC).withValues(alpha: 0.55), width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: Color(0x4000E5BC), blurRadius: 24, offset: Offset(0, 6)),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header
                        const Text(
                          'CHINTA MANI LIBRARY',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${activeBranch.name} • Notice Board Poster',
                          style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),

                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5BC).withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF00E5BC).withValues(alpha: 0.6)),
                          ),
                          child: const Text(
                            'SCAN TO JOIN & RESERVE STUDY SEAT',
                            style: TextStyle(color: Color(0xFF00E5BC), fontSize: 10.5, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // QR Code in high contrast card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [
                              BoxShadow(color: Color(0x55D4AF37), blurRadius: 20, spreadRadius: 2),
                            ],
                          ),
                          child: QrImageView(
                            data: _admissionQrUrl,
                            version: QrVersions.auto,
                            size: 190,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Point Phone Camera to Scan',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Opens WhatsApp with pre-filled admission enquiry',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5),
                        ),
                        const SizedBox(height: 14),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone_rounded, color: Color(0xFF00E5BC), size: 14),
                              SizedBox(width: 6),
                              Text(
                                'Director Hotline: +91 9415919277',
                                style: TextStyle(color: Color(0xFF00E5BC), fontSize: 11, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _testAdmissionWhatsApp,
                          icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                          label: const Text('Test Scan Link', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Color(0xFF10B981),
                                content: Text('✅ Printable poster ready at: Chintamani-Library-Notice-Board-QR.png'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.print_rounded, size: 18),
                          label: const Text('Poster Ready', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFD4AF37),
                            side: const BorderSide(color: Color(0xFFD4AF37)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Tab 2: Generate Scholar Pass QR ──────────────────────────────
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GlassTextField(
                    controller: _searchController,
                    label: 'Member Code to Generate QR',
                    hintText: 'e.g. CML-942810',
                    prefixIcon: const Icon(Icons.qr_code, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: 'Generate QR Pass',
                    onPressed: () {
                      setState(() {
                        _qrData = _searchController.text.trim();
                        _simulatedMemberName = 'Member (${_searchController.text.trim()})';
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  // Digital ID Card Preview
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.bgCard,
                          AppColors.primaryTeal.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryGreen.withOpacity(0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.08),
                          blurRadius: 16,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryGreen.withOpacity(0.2),
                              ),
                              child: const Icon(Icons.person, color: AppColors.primaryGreen),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _simulatedMemberName,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Code: $_qrData',
                                    style: const TextStyle(
                                      color: AppColors.accentNeon,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: QrImageView(
                            data: _qrData,
                            version: QrVersions.auto,
                            size: 160.0,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Show this QR at library entrance scanner',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Tab 3: Scanner Simulation ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accentNeon, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.2),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.qr_code_scanner, size: 80, color: AppColors.accentNeon),
                          const SizedBox(height: 14),
                          Text(
                            'Point Camera at QR Code',
                            style: TextStyle(color: AppColors.textPrimary.withOpacity(0.9), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: 'Simulate Scan for Aarav Sharma (CML-942810)',
                    icon: Icons.camera_alt,
                    onPressed: () async {
                      final branch = ref.read(activeBranchProvider);
                      await ref.read(attendanceRepositoryProvider).markAttendance(
                            memberId: 'mem-1',
                            branchId: branch.id,
                            method: 'QR',
                          );
                      ref.invalidate(todayAttendanceProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.statusActive,
                            content: Text('✅ QR Verified: Aarav Sharma checked in successfully!'),
                          ),
                        );
                      }
                    },
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
