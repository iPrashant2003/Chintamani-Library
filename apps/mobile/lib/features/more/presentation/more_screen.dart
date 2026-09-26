import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/chintamani_logo.dart';
import '../../../widgets/icon_3d.dart';
import '../../branch/providers/branch_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/services/app_update_service.dart';
import '../../registrations/data/registration_repository.dart';
import '../../complaints/data/complaint_repository.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBranch = ref.watch(activeBranchProvider);
    final authState = ref.watch(authProvider).value;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final pendingRegs = ref.watch(pendingRegistrationsCountProvider).value ?? 0;
    final pendingVerifs = ref.watch(pendingVerificationsCountProvider).value ?? 0;
    final openComplaints = ref.watch(openComplaintsCountProvider).value ?? 0;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Top Brand Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.9,
                          ),
                        ),
                        Text(
                          'Operations & Intelligence Hub',
                          style: TextStyle(
                            color: AppColors.goldPrimary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _ClayBadge(
                      label: activeBranch.shortName,
                      color: AppColors.goldPrimary,
                    ),
                  ],
                ),
              ),
            ),

            // ── Premium Profile Hero Card ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: _ProfileHeroCard(user: user, activeBranch: activeBranch),
              ),
            ),

            // ── Sections ──
            _buildSectionCategory(
              context,
              title: 'UNIVERSAL PORTAL & ADMISSIONS',
              accentColor: AppColors.goldPrimary,
              items: [
                _MoreItem(
                  title: 'Universal QR Portal',
                  subtitle: 'Permanent QR code for student registration & fee pay',
                  icon: Icons.qr_code_2_rounded,
                  badge: 'PORTAL QR',
                  color: AppColors.goldPrimary,
                  route: RouteNames.universalQr,
                ),
                _MoreItem(
                  title: 'Member Registrations',
                  subtitle: 'Review student applications & allocate seats',
                  icon: Icons.how_to_reg_rounded,
                  badge: pendingRegs > 0 ? '$pendingRegs PENDING' : 'ACTIVE',
                  color: const Color(0xFF059669),
                  route: RouteNames.registrations,
                ),
                _MoreItem(
                  title: 'Payment Verifications',
                  subtitle: 'Inspect UPI screenshots & approve fee receipts',
                  icon: Icons.verified_user_rounded,
                  badge: pendingVerifs > 0 ? '$pendingVerifs PENDING' : 'VERIFIED',
                  color: const Color(0xFF8B5CF6),
                  route: RouteNames.paymentVerifications,
                ),
                _MoreItem(
                  title: 'Complaints & Support',
                  subtitle: 'AC cooling, power sockets, seats & Wi-Fi tickets',
                  icon: Icons.report_problem_rounded,
                  badge: openComplaints > 0 ? '$openComplaints OPEN' : 'ALL CLEAR',
                  color: const Color(0xFFDC2626),
                  route: RouteNames.complaints,
                ),
              ],
            ),

            _buildSectionCategory(
              context,
              title: 'LIBRARY OPERATIONS',
              accentColor: AppColors.emeraldPrimary,
              items: [
                _MoreItem(
                  title: 'Student QR Self-Attendance',
                  subtitle: 'Students scan branch QR pass to self-mark attendance',
                  icon: Icons.qr_code_scanner_rounded,
                  icon3d: Icon3DType.attendance,
                  badge: 'SELF-SCAN',
                  color: AppColors.emeraldPrimary,
                  route: RouteNames.universalQr,
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
                  color: AppColors.bluePrimary,
                  route: RouteNames.plans,
                ),
              ],
            ),

            _buildSectionCategory(
              context,
              title: 'FINANCIAL MANAGEMENT',
              accentColor: AppColors.bluePrimary,
              items: [
                _MoreItem(
                  title: 'Fee Collections & Receipts',
                  subtitle: 'Record student payments & generate receipts',
                  icon: Icons.payments_rounded,
                  icon3d: Icon3DType.finance,
                  color: AppColors.emeraldPrimary,
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
                  color: AppColors.amberPrimary,
                  route: RouteNames.expenses,
                ),
                _MoreItem(
                  title: 'Reports & Audits',
                  subtitle: 'Monthly revenue, attendance & audits PDF export',
                  icon: Icons.bar_chart_rounded,
                  color: AppColors.bluePrimary,
                  route: RouteNames.reports,
                ),
              ],
            ),

            _buildSectionCategory(
              context,
              title: 'COMMUNICATION & OUTREACH',
              accentColor: const Color(0xFF25D366),
              items: [
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
                  color: AppColors.amberPrimary,
                  route: RouteNames.notifications,
                ),
              ],
            ),

            _buildSectionCategory(
              context,
              title: 'SYSTEM & PREFERENCES',
              accentColor: AppColors.goldPrimary,
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
                  title: 'Database Master Backup',
                  subtitle: '1-Tap export, WhatsApp/Drive share & restore',
                  icon: Icons.cloud_sync_rounded,
                  badge: 'SAFETY',
                  color: AppColors.emeraldPrimary,
                  route: RouteNames.databaseBackup,
                ),
                _MoreItem(
                  title: 'Live App Updates (OTA)',
                  subtitle: '1-Tap update check & background installer',
                  icon: Icons.system_update_rounded,
                  badge: 'v${AppUpdateService.currentVersion}',
                  color: AppColors.bluePrimary,
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

            // ── Logout ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                child: _LogoutButton(ref: ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSectionCategory(
    BuildContext context, {
    required String title,
    required Color accentColor,
    required List<_MoreItem> items,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: _ClaySectionCard(
          title: title,
          accentColor: accentColor,
          items: items,
          context: context,
        ),
      ),
    );
  }
}

// ── Claymorphism Section Card ──────────────────────────────────────────────
class _ClaySectionCard extends StatelessWidget {
  final String title;
  final Color accentColor;
  final List<_MoreItem> items;
  final BuildContext context;

  const _ClaySectionCard({
    required this.title,
    required this.accentColor,
    required this.items,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D14),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.16),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: accentColor.withValues(alpha: 0.05),
            blurRadius: 40,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header banner
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.10),
                  accentColor.withValues(alpha: 0.02),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(
                bottom: BorderSide(
                  color: accentColor.withValues(alpha: 0.10),
                  width: 0.6,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.5),
                        blurRadius: 6,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 9),
                Text(
                  title,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
              ],
            ),
          ),
          // Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              children: List.generate(items.length, (idx) {
                final item = items[idx];
                final isLast = idx == items.length - 1;
                return Column(
                  children: [
                    _ClayItemTile(item: item),
                    if (!isLast)
                      Divider(
                        color: Colors.white.withValues(alpha: 0.05),
                        height: 1,
                        indent: 52,
                        endIndent: 8,
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Claymorphism Item Tile ────────────────────────────────────────────────
class _ClayItemTile extends StatefulWidget {
  final _MoreItem item;
  const _ClayItemTile({required this.item});

  @override
  State<_ClayItemTile> createState() => _ClayItemTileState();
}

class _ClayItemTileState extends State<_ClayItemTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.forward();
  void _onTapUp(TapUpDetails _) => _ctrl.reverse();
  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        HapticFeedback.lightImpact();
        if (item.route != null) context.push(item.route!);
      },
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Icon
              Builder(
                builder: (context) {
                  if (item.icon3d != null) {
                    return Icon3D(type: item.icon3d!, size: 36);
                  }
                  return Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: item.color.withValues(alpha: 0.30),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: item.color.withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(item.icon, color: item.color, size: 20),
                  );
                },
              ),
              const SizedBox(width: 13),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (item.badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: item.color.withValues(alpha: 0.45),
                                width: 0.6,
                              ),
                            ),
                            child: Text(
                              item.badge!,
                              style: TextStyle(
                                color: item.color,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.2),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Profile Hero Card ──────────────────────────────────────────────────────
class _ProfileHeroCard extends StatelessWidget {
  final dynamic user;
  final dynamic activeBranch;

  const _ProfileHeroCard({required this.user, required this.activeBranch});

  @override
  Widget build(BuildContext context) {
    final initial = (user?.name as String? ?? 'A').isNotEmpty
        ? (user?.name as String).substring(0, 1).toUpperCase()
        : 'A';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1408), Color(0xFF100E06), Color(0xFF0A0906)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.goldPrimary.withValues(alpha: 0.28),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.75),
            blurRadius: 36,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.goldPrimary.withValues(alpha: 0.06),
            blurRadius: 48,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with gold glow ring
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.goldPrimary.withValues(alpha: 0.35),
                  AppColors.goldPrimary.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: AppColors.goldPrimary.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldPrimary.withValues(alpha: 0.25),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: AppColors.goldBright,
                  fontSize: 24,
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
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${activeBranch.name} • ${user?.role ?? 'OWNER'}',
                  style: const TextStyle(
                    color: AppColors.goldPrimary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldPrimary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.emeraldPrimary.withValues(alpha: 0.25),
                      width: 0.6,
                    ),
                  ),
                  child: Text(
                    '${activeBranch.occupiedSeats}/${activeBranch.totalSeats} Seats Active • 9 Lockers Vault',
                    style: const TextStyle(
                      color: AppColors.emeraldPrimary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Clay Badge (compact pill) ─────────────────────────────────────────────
class _ClayBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _ClayBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Logout Button ─────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final WidgetRef ref;

  const _LogoutButton({required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        await ref.read(authProvider.notifier).logout();
        if (context.mounted) {
          context.go(RouteNames.login);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.redPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.redPrimary.withValues(alpha: 0.28),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: AppColors.redPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
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
    );
  }
}

// ── Data Model ───────────────────────────────────────────────────────────
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
