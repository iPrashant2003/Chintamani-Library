import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/database_backup_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/ambient_background.dart';
import '../../../widgets/chintamani_logo.dart';
import '../../../widgets/card_3d.dart';
import '../../../widgets/icon_3d.dart';
import '../../members/data/member_repository.dart';

class DatabaseBackupScreen extends ConsumerStatefulWidget {
  const DatabaseBackupScreen({super.key});

  @override
  ConsumerState<DatabaseBackupScreen> createState() => _DatabaseBackupScreenState();
}

class _DatabaseBackupScreenState extends ConsumerState<DatabaseBackupScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final s = await DatabaseBackupService.instance.getDatabaseSummary();
    if (mounted) setState(() => _summary = s);
  }

  Future<void> _exportBackup() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    final success = await DatabaseBackupService.instance.exportAndShare();
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Backup shared successfully!' : 'Backup export ready in app documents.',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadSummary();
    }
  }

  Future<void> _createSnapshot() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    await DatabaseBackupService.instance.autoCreateSnapshot();
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Instant local snapshot created successfully!'),
          backgroundColor: Color(0xFFD4AF37),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadSummary();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientBackground(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const ChintaManiLogo(size: 32, showGlow: true),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Database & Backups',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Local Persistence & Export',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Content Body
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Live Integrity Card
                    Card3D(
                      theme: Card3DTheme.gold,
                      borderRadius: 20,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.goldPrimary.withValues(alpha: 0.15),
                                  border: Border.all(color: AppColors.goldPrimary, width: 1.2),
                                ),
                                child: const Center(
                                  child: Icon(Icons.security_rounded, color: AppColors.goldPrimary, size: 24),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Master Database Active',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      'Zero demo records • Real scholar data only',
                                      style: TextStyle(
                                        color: AppColors.goldLight,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                                ),
                                child: const Text(
                                  '● LIVE',
                                  style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMetricBox('Total Scholars', '${_summary?['totalMembers'] ?? 0}'),
                              _buildMetricBox('Active Enrolled', '${_summary?['activeMembers'] ?? 0}'),
                              _buildMetricBox('Branches', '2 Official'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 1-Tap Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _exportBackup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.goldPrimary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.share_rounded, size: 18),
                            label: const Text('Export & Share Backup', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _createSnapshot,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0x33D4AF37)),
                              foregroundColor: AppColors.goldLight,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.save_alt_rounded, size: 18),
                            label: const Text('Create Local Snapshot', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xF2121212),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x22FFFFFF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: AppColors.blueAqua, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Data Safety & Backup Policy',
                                style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '1. Every time you register a scholar, record a payment, or delete a record, an automated local JSON snapshot is committed.\n2. Tap "Export & Share Backup" to send the database to WhatsApp or Google Drive for complete safety.\n3. The database is strictly linked to Director Manglesh Mani Tripathi (9415919277).',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, height: 1.45),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
