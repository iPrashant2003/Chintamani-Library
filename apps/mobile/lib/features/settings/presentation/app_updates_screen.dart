import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../core/services/app_update_service.dart';
import '../../../widgets/app_update_dialog.dart';

/// Dedicated standalone screen for OTA Live App Updates.
class AppUpdatesScreen extends ConsumerStatefulWidget {
  const AppUpdatesScreen({super.key});

  @override
  ConsumerState<AppUpdatesScreen> createState() => _AppUpdatesScreenState();
}

class _AppUpdatesScreenState extends ConsumerState<AppUpdatesScreen> {
  bool _isChecking = false;

  Future<void> _checkUpdate() async {
    setState(() => _isChecking = true);
    final service = ref.read(appUpdateServiceProvider);
    final update = await service.checkForUpdate(force: true);
    if (!mounted) return;
    setState(() => _isChecking = false);

    if (update != null) {
      AppUpdateDialog.show(context, update);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '✨ You are on the latest version! (v${AppUpdateService.currentVersion} Build ${AppUpdateService.currentBuildNumber})',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF14120E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final autoCheckAsync = ref.watch(isAppUpdateAutoCheckProvider);
    final autoCheck = autoCheckAsync.value ?? true;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.goldPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'App Updates (OTA)',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0x22D4AF37)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current version card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0x33D4AF37), Color(0x08000000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.system_update_rounded, color: Color(0xFFD4AF37), size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Version ${AppUpdateService.currentVersion}',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Build ${AppUpdateService.currentBuildNumber} • Android',
                    style: const TextStyle(color: AppColors.goldPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      '● Live OTA Updates Enabled',
                      style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Check for update button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: _isChecking
                  ? Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0x33D4AF37)),
                      ),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2.5),
                            ),
                            SizedBox(width: 12),
                            Text('Checking for updates...', style: TextStyle(color: AppColors.goldPrimary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.cloud_download_rounded, size: 22),
                      label: const Text(
                        'Check for Updates Now',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      onPressed: _checkUpdate,
                    ),
            ),
            const SizedBox(height: 24),

            // Auto-check toggle
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              ),
              child: SwitchListTile.adaptive(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_mode_rounded, color: Color(0xFFD4AF37), size: 20),
                ),
                title: const Text(
                  'Auto-Check on App Launch',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Automatically notify when a new APK is deployed',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                value: autoCheck,
                activeTrackColor: const Color(0xFFD4AF37),
                activeThumbColor: const Color(0xFFFDE68A),
                onChanged: (val) async {
                  await ref.read(appUpdateServiceProvider).setAutoCheckEnabled(val);
                  ref.invalidate(isAppUpdateAutoCheckProvider);
                },
              ),
            ),
            const SizedBox(height: 24),

            // How OTA works
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.2)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Color(0xFF3B82F6), size: 18),
                      SizedBox(width: 8),
                      Text('How Live Updates Work', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  SizedBox(height: 10),
                  _InfoRow('Tap "Check for Updates Now" to see if a new build is available'),
                  _InfoRow('If available, tap Install to download and install the APK instantly'),
                  _InfoRow('No Play Store needed — all updates are delivered OTA directly'),
                  _InfoRow('Enable Auto-Check to be notified automatically each time you open the app'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String text;
  const _InfoRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w700)),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
        ],
      ),
    );
  }
}
