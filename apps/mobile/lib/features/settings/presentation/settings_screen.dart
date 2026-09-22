import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/branch_switcher.dart';
import '../../../core/services/app_update_service.dart';
import '../../../widgets/app_update_dialog.dart';
import '../../auth/providers/auth_provider.dart';
import '../../tenant/providers/tenant_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider).value;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final tenant = ref.watch(activeTenantProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        titleSpacing: 12,
        title: const BranchSwitcher(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFD4AF37).withOpacity(0.15),
                      border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'A',
                        style: const TextStyle(
                          color: Color(0xFFFDE68A),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? '—',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.phone ?? '—',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                user?.role ?? 'OWNER',
                                style: const TextStyle(
                                  color: Color(0xFFD4AF37),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (tenant != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accentElectricBlue.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  tenant.code,
                                  style: const TextStyle(
                                    color: AppColors.accentElectricBlue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Branch & Operations ──────────────────────────────────────
            _sectionLabel('Branch & Operations'),
            _SettingsTile(
              icon: Icons.store_mall_directory_outlined,
              iconColor: const Color(0xFF10B981),
              title: 'Branch Management',
              subtitle: 'Khalilabad • Mehdawal — 2 official branches',
              onTap: () => _showBranchInfoDialog(context, tenant?.name ?? 'Library'),
            ),
            _SettingsTile(
              icon: Icons.schedule_rounded,
              iconColor: const Color(0xFF3B82F6),
              title: 'Shift & Batch Timings',
              subtitle: '6 hrs / 12 hrs / 24 hrs — Add or edit custom batches',
              onTap: () => context.push(RouteNames.plans),
            ),
            _SettingsTile(
              icon: Icons.lock_clock_rounded,
              iconColor: const Color(0xFF8B5CF6),
              title: 'Locker Configuration',
              subtitle: '9 Lockers per branch • ₹200/month',
              onTap: () => context.push(RouteNames.lockers),
            ),

            const SizedBox(height: 20),

            // ── Fees & Pricing ──────────────────────────────────────────
            _sectionLabel('Fees & Pricing'),
            const _FeesPricingCard(),

            const SizedBox(height: 20),

            // ── Appearance ──────────────────────────────────────────────
            _sectionLabel('Appearance & Theme'),
            _SettingsTile(
              icon: Icons.palette_outlined,
              iconColor: const Color(0xFFD4AF37),
              title: 'Customize Theme',
              subtitle: 'Choose from 11 premium palettes or create a custom color',
              onTap: () => context.push(RouteNames.themeCustomization),
            ),

            const SizedBox(height: 20),

            // ── Security ────────────────────────────────────────────────
            _sectionLabel('Staff & Security'),
            _SettingsTile(
              icon: Icons.badge_outlined,
              iconColor: const Color(0xFFEC4899),
              title: 'Staff Management',
              subtitle: 'Manage branch managers and desk staff',
              onTap: () => _showStaffDialog(context),
            ),
            _SettingsTile(
              icon: Icons.history,
              iconColor: const Color(0xFFF59E0B),
              title: 'Audit & Activity Logs',
              subtitle: 'View security events and operational logs',
              onTap: () => _showAuditDialog(context),
            ),
            _SettingsTile(
              icon: Icons.lock_outline,
              iconColor: const Color(0xFFDC2626),
              title: 'Change App Password',
              subtitle: 'Update the password used to open this app',
              onTap: () => context.push(RouteNames.changePassword),
            ),

            const SizedBox(height: 20),

            // ── OTA Updates ─────────────────────────────────────────────
            _sectionLabel('Live Updates (OTA)'),
            _SettingsTile(
              icon: Icons.system_update_rounded,
              iconColor: const Color(0xFF3B82F6),
              title: 'Live App Updates (OTA)',
              subtitle: 'v${AppUpdateService.currentVersion} Build ${AppUpdateService.currentBuildNumber} • 1-Tap Auto-Install',
              onTap: () => context.push(RouteNames.appUpdates),
            ),
            const SizedBox(height: 20),

            // ── About ───────────────────────────────────────────────────
            _sectionLabel('About System'),
            _SettingsTile(
              icon: Icons.info_outline,
              iconColor: AppColors.textSecondary,
              title: 'LibraryOS Platform',
              subtitle: 'v${AppUpdateService.currentVersion} Build ${AppUpdateService.currentBuildNumber} • Android',
              onTap: () {},
            ),
            const SizedBox(height: 16),

            // Logout Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.statusExpired.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.statusExpired.withOpacity(0.3)),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppColors.statusExpired),
                title: const Text('Log Out of Account',
                    style: TextStyle(color: AppColors.statusExpired, fontWeight: FontWeight.bold)),
                onTap: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go(RouteNames.login);
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(width: 3, height: 14, decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  void _showBranchInfoDialog(BuildContext context, String libraryName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('Official Branches', style: TextStyle(color: AppColors.textPrimary)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Chinta Mani Library — Khalilabad\n   Main Road, Khalilabad\n   9 Lockers\n\n2. Chinta Mani Library — Mehdawal\n   Station Road, Mehdawal\n   9 Lockers\n\nThese two official branches are permanently configured.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showStaffDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('Staff Management', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Staff accounts and branch access are managed by the director.\n\nContact Manglesh Mani Tripathi to add or modify staff accounts.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
        ],
      ),
    );
  }

  void _showAuditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('Recent Activity Logs', style: TextStyle(color: AppColors.textPrimary)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('• Member enrolled successfully', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            SizedBox(height: 6),
            Text('• Seat status updated to OCCUPIED', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            SizedBox(height: 6),
            Text('• Payment verified via UPI', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            SizedBox(height: 6),
            Text('• Attendance check-in recorded', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}

// ── Fees & Pricing Card (static display of standard rates) ─────────────────
class _FeesPricingCard extends StatelessWidget {
  const _FeesPricingCard();

  @override
  Widget build(BuildContext context) {
    final items = [
      _PriceItem('6 Hrs Batch', '₹500 / month', const Color(0xFF3B82F6), Icons.wb_sunny_rounded),
      _PriceItem('12 Hrs Batch', '₹800 / month', const Color(0xFF8B5CF6), Icons.brightness_medium_rounded),
      _PriceItem('24 Hrs / Full Day', '₹1,000 / month', const Color(0xFF10B981), Icons.nightlight_round),
      _PriceItem('Registration Fee', '₹100 (one time)', const Color(0xFFD4AF37), Icons.how_to_reg_rounded),
      _PriceItem('Locker Facility', '₹200 / month', const Color(0xFFEC4899), Icons.lock_rounded),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x22D4AF37)),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: e.value.color.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(e.value.icon, color: e.value.color, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.value.title,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: e.value.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: e.value.color.withOpacity(0.3), width: 0.8),
                    ),
                    child: Text(
                      e.value.price,
                      style: TextStyle(color: e.value.color, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 10),
                const Divider(color: Color(0x15FFFFFF), height: 1),
                const SizedBox(height: 10),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _PriceItem {
  final String title;
  final String price;
  final Color color;
  final IconData icon;
  const _PriceItem(this.title, this.price, this.color, this.icon);
}

// ── Reusable Settings Tile ─────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textDisabled, size: 20),
        onTap: onTap,
      ),
    );
  }
}

// ── OTA App Update Settings ────────────────────────────────────────────────
class _AppUpdateSettingsSection extends ConsumerStatefulWidget {
  const _AppUpdateSettingsSection();

  @override
  ConsumerState<_AppUpdateSettingsSection> createState() => _AppUpdateSettingsSectionState();
}

class _AppUpdateSettingsSectionState extends ConsumerState<_AppUpdateSettingsSection> {
  bool _isChecking = false;

  Future<void> _checkUpdate() async {
    setState(() => _isChecking = true);
    final service = ref.read(appUpdateServiceProvider);
    final update = await service.checkForUpdate();
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
                  '✨ Your app is up to date! (v${AppUpdateService.currentVersion} Build ${AppUpdateService.currentBuildNumber})',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(width: 3, height: 14, decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              const Text(
                'APP VERSION & LIVE UPDATES (OTA)',
                style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.35)),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.system_update_rounded, color: Color(0xFFFDE68A), size: 20),
            ),
            title: const Text(
              'Check for Live App Updates',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'v${AppUpdateService.currentVersion} (Build ${AppUpdateService.currentBuildNumber}) • 1-Tap Auto-Install',
              style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.w600),
            ),
            trailing: _isChecking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFF59E0B)]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Check',
                      style: TextStyle(color: Colors.black, fontSize: 11.5, fontWeight: FontWeight.w800),
                    ),
                  ),
            onTap: _isChecking ? null : _checkUpdate,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: SwitchListTile.adaptive(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.12), shape: BoxShape.circle),
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
      ],
    );
  }
}
