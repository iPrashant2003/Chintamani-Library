import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/chintamani_logo.dart';
import '../../../widgets/card_3d.dart';
import '../../../widgets/icon_3d.dart';
import '../../branch/providers/branch_provider.dart';
import '../../auth/providers/auth_provider.dart';

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
                              '${activeBranch.occupiedSeats}/${activeBranch.totalSeats} Seats Active • 20 Lockers',
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
              accentColor: AppColors.tealPrimary,
              items: [
                _MoreItem(
                  title: '3D Seats Grid',
                  subtitle: 'Visual chair allocation, floor layout & status',
                  icon: Icons.chair_rounded,
                  icon3d: Icon3DType.seat,
                  badge: '3D',
                  color: AppColors.emeraldPrimary,
                  route: RouteNames.seats,
                ),
                _MoreItem(
                  title: '3D Lockers Grid',
                  subtitle: 'Personal storage lockers L01-L20 management',
                  icon: Icons.lock_clock_rounded,
                  icon3d: Icon3DType.locker,
                  badge: '3D',
                  color: AppColors.purplePrimary,
                  route: RouteNames.lockers,
                ),
                _MoreItem(
                  title: 'Smart Attendance Hub',
                  subtitle: 'Biometric & QR pass scanning for check-ins',
                  icon: Icons.how_to_reg_rounded,
                  icon3d: Icon3DType.attendance,
                  color: AppColors.blueAqua,
                  route: RouteNames.attendance,
                ),
                _MoreItem(
                  title: 'Members Directory',
                  subtitle: 'Active scholar profiles, plans & cards',
                  icon: Icons.people_alt_rounded,
                  icon3d: Icon3DType.members,
                  color: AppColors.emeraldPrimary,
                  route: RouteNames.members,
                ),
                _MoreItem(
                  title: 'Financial Pulse',
                  subtitle: "Today's cashflow, expenses & operating margin",
                  icon: Icons.account_balance_wallet_rounded,
                  badge: 'LIVE',
                  color: AppColors.goldPrimary,
                  route: RouteNames.expenses,
                ),
                _MoreItem(
                  title: 'Payments Ledger',
                  subtitle: 'Approve, verify & track all student payments',
                  icon: Icons.payments_rounded,
                  badge: 'VERIFY',
                  color: AppColors.emeraldPrimary,
                  route: RouteNames.payments,
                ),
                _MoreItem(
                  title: 'Shift & Batch Timings',
                  subtitle: 'Morning, afternoon & night shift seat allocations',
                  icon: Icons.schedule_rounded,
                  color: AppColors.blueAqua,
                  route: RouteNames.plans,
                ),
                _MoreItem(
                  title: 'Facilities & Maintenance',
                  subtitle: 'Infrastructure tickets, repairs & upkeep log',
                  icon: Icons.build_rounded,
                  badge: 'NEW',
                  color: AppColors.amberPrimary,
                  route: RouteNames.maintenance,
                ),
              ],
            ),

            // SECTION 2: FINANCIAL MANAGEMENT (Sapphire Blue)
            _buildSectionCategory(
              context,
              title: 'FINANCIAL MANAGEMENT',
              accentColor: AppColors.bluePrimary,
              items: [
                _MoreItem(
                  title: 'Fee & Collections',
                  subtitle: 'Record student payments & generate digital receipts',
                  icon: Icons.payments_rounded,
                  icon3d: Icon3DType.finance,
                  color: AppColors.bluePrimary,
                  route: RouteNames.payments,
                ),
                _MoreItem(
                  title: 'Due Payments & Balances',
                  subtitle: 'Track outstanding dues & overdue subscriptions',
                  icon: Icons.pending_actions_rounded,
                  badge: 'OVERDUE',
                  color: AppColors.redPrimary,
                  route: RouteNames.duePayments,
                ),
                _MoreItem(
                  title: 'Expense Tracker',
                  subtitle: 'Electricity, generator diesel, rent & maintenance',
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.amberPrimary,
                  route: RouteNames.expenses,
                ),
                _MoreItem(
                  title: 'Membership Plans',
                  subtitle: 'Daily, 1-month, 3-month & annual packages',
                  icon: Icons.card_membership_rounded,
                  color: AppColors.goldPrimary,
                  route: RouteNames.plans,
                ),
              ],
            ),

            // SECTION 3: INTELLIGENCE & ANALYTICS (Imperial Gold)
            _buildSectionCategory(
              context,
              title: 'INTELLIGENCE & ANALYTICS',
              accentColor: AppColors.goldPrimary,
              items: [
                _MoreItem(
                  title: 'Library Insights',
                  subtitle: 'Peak study hours, seat duration & retention',
                  icon: Icons.insights_rounded,
                  icon3d: Icon3DType.insights,
                  badge: 'NEW',
                  color: AppColors.goldBright,
                  route: RouteNames.insights,
                ),
                _MoreItem(
                  title: 'Branch Comparison',
                  subtitle: 'Khalilabad vs Mehdawal live side-by-side analytics',
                  icon: Icons.compare_arrows_rounded,
                  badge: 'DUAL',
                  color: AppColors.goldPrimary,
                  route: RouteNames.branchComparison,
                ),
                _MoreItem(
                  title: 'Reports & Audits',
                  subtitle: 'Export monthly revenue, attendance & audits to PDF',
                  icon: Icons.bar_chart_rounded,
                  color: AppColors.blueAqua,
                  route: RouteNames.reports,
                ),
              ],
            ),

            // SECTION 4: CRM & OUTREACH (Ruby Red & Amber)
            _buildSectionCategory(
              context,
              title: 'INQUIRIES & COMMUNICATION',
              accentColor: AppColors.redPrimary,
              items: [
                _MoreItem(
                  title: 'WhatsApp Hub',
                  subtitle: 'Broadcast messages, fee reminders & per-member chat',
                  icon: Icons.chat_rounded,
                  badge: 'WA',
                  color: const Color(0xFF25D366),
                  route: RouteNames.whatsapp,
                ),
                _MoreItem(
                  title: 'Enquiries & Admissions',
                  subtitle: 'New student admissions, desk visits & follow-ups',
                  icon: Icons.contact_mail_rounded,
                  color: AppColors.redPrimary,
                  route: RouteNames.enquiries,
                ),
                _MoreItem(
                  title: 'Communication Center',
                  subtitle: 'Send SMS & WhatsApp fee and expiry reminders',
                  icon: Icons.chat_rounded,
                  color: AppColors.emeraldPrimary,
                  route: RouteNames.communication,
                ),
                _MoreItem(
                  title: 'Notifications Hub',
                  subtitle: 'Real-time library broadcasts & alerts',
                  icon: Icons.notifications_active_rounded,
                  color: AppColors.amberPrimary,
                  route: RouteNames.notifications,
                ),
              ],
            ),

            // SECTION 5: BRAND, SUPPORT & THEME (Luxury Champagne)
            _buildSectionCategory(
              context,
              title: 'CHINTA MANI & SETTINGS',
              accentColor: AppColors.goldLight,
              items: [
                _MoreItem(
                  title: 'Library Photos & Campus Tour',
                  subtitle: 'Khalilabad & Mehdawal campus photos on Google Maps',
                  icon: Icons.photo_library_rounded,
                  badge: 'GALLERY',
                  color: AppColors.goldPrimary,
                  route: RouteNames.photos,
                ),
                _MoreItem(
                  title: 'About Chinta Mani Library',
                  subtitle: 'Our vision, study environment & official branches',
                  icon: Icons.info_outline_rounded,
                  icon3d: Icon3DType.branch,
                  color: AppColors.goldPrimary,
                  route: RouteNames.about,
                ),
                _MoreItem(
                  title: 'Contact & Directions',
                  subtitle: 'Direct call, WhatsApp & Google Maps navigation',
                  icon: Icons.phone_in_talk_rounded,
                  color: AppColors.emeraldPrimary,
                  route: RouteNames.contact,
                ),

                _MoreItem(
                  title: 'Database Master Backup',
                  subtitle: '1-Tap export, WhatsApp/Drive share & local restore',
                  icon: Icons.cloud_sync_rounded,
                  badge: 'SAFETY',
                  color: AppColors.emeraldPrimary,
                  route: RouteNames.databaseBackup,
                ),
                _MoreItem(
                  title: 'Live App Updates (OTA)',
                  subtitle: '1-Tap update check & automatic background installer',
                  icon: Icons.system_update_rounded,
                  badge: 'v2.2.0',
                  color: const Color(0xFFD4AF37),
                  route: RouteNames.settings,
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
  final Icon3DType? icon3d;
  final String? badge;
  final Color color;
  final String? route;

  const _MoreItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.icon3d,
    this.badge,
    required this.color,
    this.route,
  });
}
