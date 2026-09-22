import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../features/branch/domain/branch_model.dart';
import '../features/branch/providers/branch_provider.dart';
import '../features/auth/providers/auth_provider.dart';
import '../routing/route_names.dart';
import 'chintamani_logo.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBranch = ref.watch(activeBranchProvider);
    final authState = ref.watch(authProvider).value;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Drawer(
      backgroundColor: const Color(0xF8100C05), // Luxury golden obsidian
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header with Official Chinta Mani Brand & Interactive Branch Switch
            Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0x33D4AF37), width: 1),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x33D4AF37),
                    Color(0x08000000),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const ChintaManiLogo(
                        size: 46,
                        showGlow: true,
                        showCircularBackground: true,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CHINTA MANI',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Text(
                              'LIBRARY',
                              style: TextStyle(
                                color: AppColors.goldPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Infinity under a roof',
                              style: TextStyle(
                                color: AppColors.goldLight.withValues(alpha: 0.7),
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Interactive Quick Branch Switcher Chip
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      final isKhl = activeBranch.shortName == 'Khalilabad';
                      ref.read(activeBranchProvider.notifier).state =
                          isKhl ? Branch.mehdawalBranch : Branch.khalilabadBranch;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0x22D4AF37),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.borderGold, width: 0.8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.emeraldPrimary,
                              boxShadow: [
                                BoxShadow(color: AppColors.emeraldGlow, blurRadius: 6),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activeBranch.name,
                                  style: const TextStyle(
                                    color: AppColors.goldLight,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Text(
                                  'Tap to switch branch (Khalilabad / Mehdawal)',
                                  style: TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.swap_horiz_rounded,
                            color: AppColors.goldBright,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Organized Navigation List Items
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  // SECTION 1: QUICK DESK UTILITIES (Not duplicated in More)
                  _buildSectionHeader('QUICK UTILITIES', const Color(0xFF06B6D4)),
                  _buildDrawerItem(
                    context,
                    title: 'Quick QR Scanner',
                    subtitle: 'Scan member ID & check-in pass',
                    icon: Icons.qr_code_scanner_rounded,
                    accentColor: const Color(0xFF06B6D4),
                    badge: 'FAST SCAN',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(RouteNames.qr);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Branch Comparison',
                    subtitle: 'Khalilabad vs Mehdawal performance',
                    icon: Icons.compare_arrows_rounded,
                    accentColor: const Color(0xFF3B82F6),
                    badge: 'COMPARE',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(RouteNames.branchComparison);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Library Insights & Trends',
                    subtitle: 'Occupancy patterns & study rush hours',
                    icon: Icons.insights_rounded,
                    accentColor: const Color(0xFF8B5CF6),
                    badge: 'ANALYTICS',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(RouteNames.insights);
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Director Helpline',
                    subtitle: 'Manglesh Mani Tripathi • 9415919277',
                    icon: Icons.phone_in_talk_rounded,
                    accentColor: const Color(0xFFD4AF37),
                    badge: 'DIRECT',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(RouteNames.contact);
                    },
                  ),

                  const SizedBox(height: 12),

                  // SECTION 2: ACCESS ALL OPERATIONS
                  _buildSectionHeader('MORE OPERATIONS', const Color(0xFF10B981)),
                  _buildDrawerItem(
                    context,
                    title: 'More Features Hub',
                    subtitle: 'Lockers, Timings, Dues, Expenses & System',
                    icon: Icons.dashboard_customize_rounded,
                    accentColor: const Color(0xFF10B981),
                    badge: 'ALL MODULES',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(RouteNames.more);
                    },
                  ),

                  const SizedBox(height: 14),

                  // Mandatory Developer Credit
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0x1AD4AF37),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x33D4AF37), width: 0.8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: AppColors.goldPrimary, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Developed by Prashant Mani Tripathi',
                                style: TextStyle(
                                  color: AppColors.goldLight,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Chinta Mani Library • Enterprise System',
                                style: TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 9.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),

            // Bottom Profile / Sign Out
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0x22FFFFFF), width: 1),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.goldPrimary.withValues(alpha: 0.2),
                    child: Text(
                      user?.name.substring(0, 1).toUpperCase() ?? 'A',
                      style: const TextStyle(
                        color: AppColors.goldPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Chinta Mani Admin',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user?.role ?? 'ADMINISTRATOR',
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: AppColors.redPrimary, size: 20),
                    tooltip: 'Sign Out',
                    onPressed: () async {
                      Navigator.pop(context);
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.go(RouteNames.login);
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

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? customIcon,
    required Color accentColor,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.5),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 0.8),
          ),
          child: customIcon ?? Icon(icon, color: accentColor, size: 18),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 0.6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 10.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0x44FFFFFF), size: 16),
        onTap: onTap,
      ),
    );
  }
}
