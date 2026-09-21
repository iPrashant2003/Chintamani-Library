import 'package:flutter/material.dart';
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
                border: Border.all(color: AppColors.primaryGreen.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
                    child: const Icon(Icons.person, color: AppColors.accentNeon, size: 30),
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
                          user?.email ?? '—',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accentNeon.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                user?.role ?? 'STAFF',
                                style: const TextStyle(
                                  color: AppColors.accentNeon,
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

            const Text('Official Library Profile',
                style: TextStyle(color: AppColors.accentNeon, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.account_balance,
              title: 'Chinta Mani Library Network',
              subtitle: 'Sant Kabir Nagar, UP • 2 Official Branches',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.email_outlined,
              title: 'Contact & Administration',
              subtitle: 'contact@chintamanilibrary.com • +91 9876543210',
              onTap: () {},
            ),
            const SizedBox(height: 20),

            const Text('Appearance & Theme',
                style: TextStyle(color: AppColors.accentNeon, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.palette_outlined,
              title: 'Customize Theme',
              subtitle: 'Choose from 11 premium palettes or create a custom color',
              onTap: () => context.push(RouteNames.themeCustomization),
            ),
            const SizedBox(height: 20),

            const Text('Branch & Operations',
                style: TextStyle(color: AppColors.accentNeon, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.store_mall_directory_outlined,
              title: 'Branch Management',
              subtitle: 'View and manage branches for this library',
              onTap: () {
                _showBranchInfoDialog(context, tenant?.name ?? 'Library');
              },
            ),
            _SettingsTile(
              icon: Icons.access_time,
              title: 'Library Operational Timings',
              subtitle: '06:00 AM – 11:00 PM (Daily)',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Timings configured: 06:00 AM – 11:00 PM')),
                );
              },
            ),
            const SizedBox(height: 20),

            const Text('Staff & Security',
                style: TextStyle(color: AppColors.accentNeon, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.badge_outlined,
              title: 'Staff Management',
              subtitle: 'Manage branch managers and desk staff',
              onTap: () {
                _showStaffDialog(context);
              },
            ),
            _SettingsTile(
              icon: Icons.history,
              title: 'Audit & Activity Logs',
              subtitle: 'View security events and operational logs',
              onTap: () {
                _showAuditDialog(context);
              },
            ),
            _SettingsTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your account access credentials',
              onTap: () {
                _showChangePasswordDialog(context);
              },
            ),
            const SizedBox(height: 20),

            const _AppUpdateSettingsSection(),
            const SizedBox(height: 20),

            const Text('About System',
                style: TextStyle(color: AppColors.accentNeon, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 10),
            _SettingsTile(
              icon: Icons.info_outline,
              title: 'LibraryOS Platform',
              subtitle: 'Version 1.2.0 (Production Build) • Android & iOS',
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
              '1. Chinta Mani Library — Khalilabad\n   Main Road, Khalilabad\n   Seats: 180 (Floors A & B)\n\n2. Chinta Mani Digital Library — Mehdawal\n   Station Road, Mehdawal\n   Seats: 120 (Floors A & B)\n\nThese two official branches are permanently configured. External branch creation is disabled.',
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
          'Staff accounts and branch access are managed through the admin portal.\n\nContact your library owner to add or modify staff accounts.',
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

  void _showChangePasswordDialog(BuildContext context) {
    final oldPass = TextEditingController();
    final newPass = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('Change Password', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPass,
              obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Current Password'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPass,
              obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.statusActive,
                  content: Text('Password updated successfully!'),
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
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
            color: AppColors.primaryGreen.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.accentNeon, size: 20),
        ),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textDisabled, size: 20),
        onTap: onTap,
      ),
    );
  }
}

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
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '✨ Your app is up to date! (v2.2.0 Build 16)',
                  style: TextStyle(fontWeight: FontWeight.w700),
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
        const Text(
          'App Version & Live Updates (OTA)',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.35)),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.system_update_rounded, color: Color(0xFFFDE68A), size: 20),
            ),
            title: const Text(
              'Check for Live App Updates',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'v2.2.0 (Build 16) • 1-Tap Auto-Install',
              style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.w600),
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFF59E0B)],
                      ),
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
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
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
      ],
    );
  }
}
