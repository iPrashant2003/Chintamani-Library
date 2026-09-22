import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/chintamani_logo.dart';
import '../../../widgets/card_3d.dart';
import '../../../widgets/icon_3d.dart';
import '../../../widgets/whatsapp_logo.dart';
import '../../branch/providers/branch_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/services/app_update_service.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBranch = ref.watch(activeBranchProvider);
    final authState = ref.watch(authProvider).value;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top App Bar Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const ChintaManiLogo(size: 36, showGlow: true),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CHINTA MANI LIBRARY',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          'Operations & Intelligence Hub',
                          style: TextStyle(
                            color: AppColors.goldPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.goldPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderGold, width: 0.8),
                      ),
                      child: Text(
                        activeBranch.shortName,
                        style: const TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Profile Header Card (Gold 3D Card)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card3D(
                  theme: Card3DTheme.gold,
                  borderRadius: 20,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.goldPrimary.withValues(alpha: 0.2),
                          border: Border.all(color: AppColors.goldPrimary, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            user?.name.substring(0, 1).toUpperCase() ?? 'A',
                            style: const TextStyle(
                              color: AppColors.goldBright,
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
                              user?.name ?? 'Chinta Mani Administrator',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${activeBranch.name} • ${user?.role ?? 'OWNER'}',
                              style: const TextStyle(
                                color: AppColors.goldPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${activeBranch.occupiedSeats}/${activeBranch.totalSeats} Seats Active • 9 Lockers Vault',
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // SECTION 1: LIBRARY OPERATIONS (Emerald/Cyan)
            _buildSectionCategory(
              context,
              title: 'LIBRARY OPERATIONS',
              accentColor: const Color(0xFF10B981),
              items: [
                _MoreItem(
                  title: 'Members Directory',
                  subtitle: 'Live memberships, expired & renew actions',
                  icon: Icons.people_alt_rounded,
                  icon3d: Icon3DType.members,
                  badge: 'LIVE',
                  color: const Color(0xFF10B981),
                  route: RouteNames.members,
                ),
                _MoreItem(
                  title: '3D Seats Grid',
                  subtitle: 'Visual chair allocation, floor layout & status',
                  icon: Icons.chair_rounded,
                  icon3d: Icon3DType.seat,
                  badge: '3D',
                  color: const Color(0xFF00E5BC),
                  route: RouteNames.seats,
                ),
                _MoreItem(
                  title: '9 Lockers Vault',
                  subtitle: 'Personal storage lockers L01-L09 • ₹200/mo fee',
                  icon: Icons.lock_clock_rounded,
                  icon3d: Icon3DType.locker,
                  badge: '9 VAULT',
                  color: const Color(0xFF8B5CF6),
                  route: RouteNames.lockers,
                ),
                _MoreItem(
                  title: 'Shift & Batch Timings',
                  subtitle: '6h ₹500 • 12h ₹800 • 24h ₹1,000 • Editable batches',
                  icon: Icons.schedule_rounded,
                  badge: 'EDITABLE',
                  color: const Color(0xFF3B82F6),
                  route: RouteNames.plans,
                ),
                _MoreItem(
                  title: 'Smart Attendance Hub',
                  subtitle: 'Biometric & QR pass scanning for check-ins',
                  icon: Icons.how_to_reg_rounded,
                  icon3d: Icon3DType.attendance,
                  color: const Color(0xFF06B6D4),
                  route: RouteNames.attendance,
                ),
              ],
            ),

            // SECTION 2: FINANCIAL MANAGEMENT (Sapphire Blue & Amber)
            _buildSectionCategory(
              context,
              title: 'FINANCIAL MANAGEMENT',
              accentColor: const Color(0xFF3B82F6),
              items: [
                _MoreItem(
                  title: 'Fee Collections & Receipts',
                  subtitle: 'Record student payments & generate receipts',
                  icon: Icons.payments_rounded,
                  icon3d: Icon3DType.finance,
                  color: const Color(0xFF10B981),
                  route: RouteNames.recordPayment,
                ),
                _MoreItem(
                  title: 'Due Payments & Balances',
                  subtitle: 'Track outstanding dues & overdue subscriptions',
                  icon: Icons.pending_actions_rounded,
                  badge: 'OVERDUE',
                  color: const Color(0xFFDC2626),
                  route: RouteNames.duePayments,
                ),
                _MoreItem(
                  title: 'Expense Tracker',
                  subtitle: 'Electricity, generator diesel, rent & maintenance',
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFFF59E0B),
                  route: RouteNames.expenses,
                ),
                _MoreItem(
                  title: 'Reports & Audits',
                  subtitle: 'Monthly revenue, attendance & audits PDF export',
                  icon: Icons.bar_chart_rounded,
                  color: const Color(0xFF3B82F6),
                  route: RouteNames.reports,
                ),
              ],
            ),

            // SECTION 3: COMMUNICATIONS & CRM (Emerald & Green)
            _buildSectionCategory(
              context,
              title: 'COMMUNICATION & OUTREACH',
              accentColor: const Color(0xFF25D366),
              items: [
                _MoreItem(
                  title: 'WhatsApp Hub',
                  subtitle: 'Broadcast messages, fee reminders & AI message writer',
                  icon: Icons.chat_rounded,
                  customIcon: const WhatsAppLogo(size: 20, color: Color(0xFF25D366)),
                  badge: 'AI WRITER',
                  color: const Color(0xFF25D366),
                  route: RouteNames.whatsapp,
                ),
                _MoreItem(
                  title: 'Enquiries & Admissions',
                  subtitle: 'New student admissions, desk visits & follow-ups',
                  icon: Icons.contact_mail_rounded,
                  color: const Color(0xFFEC4899),
                  route: RouteNames.enquiries,
                ),
                _MoreItem(
                  title: 'Notifications Hub',
                  subtitle: 'Real-time library broadcasts & alerts',
                  icon: Icons.notifications_active_rounded,
                  color: const Color(0xFFF59E0B),
                  route: RouteNames.notifications,
                ),
              ],
            ),

            // SECTION 4: SYSTEM, SECURITY & SETTINGS (Luxury Gold)
            _buildSectionCategory(
              context,
              title: 'SYSTEM & PREFERENCES',
              accentColor: const Color(0xFFD4AF37),
              items: [
                _MoreItem(
                  title: 'Change App Password',
                  subtitle: 'Update account password & app lock PIN',
                  icon: Icons.lock_reset_rounded,
                  badge: 'SECURITY',
                  color: const Color(0xFFDC2626),
                  route: RouteNames.changePassword,
                ),
                _MoreItem(
                  title: 'Customize App Theme',
                  subtitle: 'Choose from 11 palettes or create custom color',
                  icon: Icons.palette_outlined,
                  badge: '11 THEMES',
                  color: const Color(0xFFD4AF37),
                  route: RouteNames.themeCustomization,
                ),
                _MoreItem(
                  title: 'Database Master Backup',
                  subtitle: '1-Tap export, WhatsApp/Drive share & restore',
                  icon: Icons.cloud_sync_rounded,
                  badge: 'SAFETY',
                  color: const Color(0xFF10B981),
                  route: RouteNames.databaseBackup,
                ),
                _MoreItem(
                  title: 'Live App Updates (OTA)',
                  subtitle: '1-Tap update check & background installer',
                  icon: Icons.system_update_rounded,
                  badge: 'v${AppUpdateService.currentVersion}',
                  color: const Color(0xFF3B82F6),
                  route: RouteNames.appUpdates,
                ),
                _MoreItem(
                  title: 'Campus Tour & Photos',
                  subtitle: 'Khalilabad & Mehdawal campus photos on Google Maps',
                  icon: Icons.photo_library_rounded,
                  color: const Color(0xFF8B5CF6),
                  route: RouteNames.photos,
                ),
                _MoreItem(
                  title: 'System Settings',
                  subtitle: 'Branch timings, staff management & audit logs',
                  icon: Icons.settings_outlined,
                  color: AppColors.textSecondary,
                  route: RouteNames.settings,
                ),
              ],
            ),

            // Logout Action Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                child: GestureDetector(
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      context.go(RouteNames.login);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.redPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderRed, width: 1),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: AppColors.redPrimary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Sign Out from Chinta Mani System',
                          style: TextStyle(
                            color: AppColors.redPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCategory(
    BuildContext context, {
    required String title,
    required Color accentColor,
    required List<_MoreItem> items,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xF20F0F0F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x22FFFFFF), width: 0.8),
              ),
              child: Column(
                children: List.generate(items.length, (idx) {
                  final item = items[idx];
                  final isLast = idx == items.length - 1;
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (item.route != null) {
                            context.push(item.route!);
                          }
                        },
                        leading: Builder(
                          builder: (context) {
                            if (item.customIcon != null) {
                              return Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: item.color.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: item.color.withValues(alpha: 0.35), width: 0.8),
                                ),
                                child: Center(child: item.customIcon),
                              );
                            }
                            if (item.icon3d != null) {
                              return Icon3D(type: item.icon3d!, size: 36);
                            }
                            return Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: item.color.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: item.color.withValues(alpha: 0.35), width: 0.8),
                              ),
                              child: Icon(item.icon, color: item.color, size: 20),
                            );
                          },
                        ),
                        title: Row(
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (item.badge != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: item.color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: item.color.withValues(alpha: 0.5), width: 0.6),
                                ),
                                child: Text(
                                  item.badge!,
                                  style: TextStyle(
                                    color: item.color,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          item.subtitle,
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0x55FFFFFF), size: 18),
                      ),
                      if (!isLast)
                        const Divider(color: Color(0x15FFFFFF), height: 1, indent: 64),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? customIcon;
  final Icon3DType? icon3d;
  final String? badge;
  final Color color;
  final String? route;

  const _MoreItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.customIcon,
    this.icon3d,
    this.badge,
    required this.color,
    this.route,
  });
}
