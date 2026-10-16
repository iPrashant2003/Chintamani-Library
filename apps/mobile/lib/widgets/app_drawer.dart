import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../features/branch/domain/branch_model.dart';
import '../features/branch/providers/branch_provider.dart';
import '../features/auth/providers/auth_provider.dart';
import '../routing/route_names.dart';
import '../core/services/app_update_service.dart';
import 'app_update_dialog.dart';
import 'chintamani_logo.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBranch = ref.watch(activeBranchProvider);
    final authState = ref.watch(authProvider).value;
    final user = authState is AuthAuthenticated ? authState.user : null;

    // True Deep Black base (#040404) for claymorphism
    return Drawer(
      backgroundColor: const Color(0xFF040404),
      child: SafeArea(
        child: Column(
          children: [
            // ── Claymorphic Drawer Header with Official Brand & Branch Switch ──
            Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0D),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    offset: const Offset(0, 6),
                    blurRadius: 16,
                  ),
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.05),
                    offset: const Offset(0, 1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const ChintaManiLogo(
                        size: 44,
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
                  const SizedBox(height: 12),

                  // Tactile Claymorphic Quick Branch Switcher Chip
                  _ClaymorphicBranchChip(
                    activeBranch: activeBranch,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      final isKhl = activeBranch.shortName == 'Khalilabad';
                      ref.read(activeBranchProvider.notifier).state =
                          isKhl ? Branch.mehdawalBranch : Branch.khalilabadBranch;
                    },
                  ),
                ],
              ),
            ),

            // ── Organized Claymorphic Navigation List ──
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                children: [
                  // SECTION 1: QUICK UTILITIES
                  _buildSectionHeader('QUICK UTILITIES', const Color(0xFF06B6D4)),
                  _ClaymorphicDrawerTile(
                    title: 'Universal Portal QR',
                    subtitle: 'Permanent library QR for registration & pay',
                    icon: Icons.qr_code_2_rounded,
                    accentColor: const Color(0xFFD4AF37),
                    badge: 'PORTAL QR',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(RouteNames.universalQr);
                    },
                  ),
                  _ClaymorphicDrawerTile(
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
                  _ClaymorphicDrawerTile(
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
                  _ClaymorphicDrawerTile(
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
                  _ClaymorphicDrawerTile(
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

                  const SizedBox(height: 10),

                  // SECTION 2: ACCESS ALL OPERATIONS
                  _buildSectionHeader('MORE OPERATIONS', const Color(0xFF10B981)),
                  _ClaymorphicDrawerTile(
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
                  _ClaymorphicDrawerTile(
                    title: 'Check for Updates',
                    subtitle: 'v${AppUpdateService.currentVersion} • Scan cloud releases',
                    icon: Icons.system_update_rounded,
                    accentColor: const Color(0xFF38BDF8),
                    badge: 'AUTO-UPDATE',
                    onTap: () async {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                              SizedBox(width: 12),
                              Text('Checking for latest updates...'),
                            ],
                          ),
                          duration: Duration(seconds: 2),
                          backgroundColor: Color(0xFF1E293B),
                        ),
                      );

                      final service = ref.read(appUpdateServiceProvider);
                      final update = await service.checkForUpdate(force: true);

                      if (!context.mounted) return;
                      if (update != null) {
                        AppUpdateDialog.show(context, update);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('App is up to date (v${AppUpdateService.currentVersion})!'),
                            backgroundColor: AppColors.emeraldPrimary,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  // Developer Credit Claymorphic Plaque
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF09090C),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          offset: const Offset(0, 3),
                          blurRadius: 8,
                        ),
                      ],
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

                  const SizedBox(height: 8),
                ],
              ),
            ),

            // ── Bottom Claymorphic Profile & Sign Out ──
            Container(
              margin: const EdgeInsets.fromLTRB(10, 4, 10, 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.7),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: AppColors.goldPrimary.withValues(alpha: 0.2),
                    child: Text(
                      user?.name.substring(0, 1).toUpperCase() ?? 'A',
                      style: const TextStyle(
                        color: AppColors.goldPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Chinta Mani Admin',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user?.role ?? 'ADMINISTRATOR',
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: AppColors.redPrimary, size: 19),
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
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Claymorphic Interactive Branch Chip
class _ClaymorphicBranchChip extends StatefulWidget {
  final Branch activeBranch;
  final VoidCallback onTap;

  const _ClaymorphicBranchChip({
    required this.activeBranch,
    required this.onTap,
  });

  @override
  State<_ClaymorphicBranchChip> createState() => _ClaymorphicBranchChipState();
}

class _ClaymorphicBranchChipState extends State<_ClaymorphicBranchChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 140),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _isPressed ? const Color(0xFF0E0E12) : const Color(0xFF0F0F14),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: _isPressed ? 0.45 : 0.28),
              width: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                offset: const Offset(0, 3),
                blurRadius: 6,
              ),
              if (!_isPressed)
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.03),
                  offset: const Offset(0, -1),
                  blurRadius: 2,
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
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
                      widget.activeBranch.name,
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
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tactile Deep-Black Claymorphism Navigation Tile
class _ClaymorphicDrawerTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String? badge;
  final VoidCallback onTap;

  const _ClaymorphicDrawerTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.badge,
    required this.onTap,
  });

  @override
  State<_ClaymorphicDrawerTile> createState() => _ClaymorphicDrawerTileState();
}

class _ClaymorphicDrawerTileState extends State<_ClaymorphicDrawerTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 130),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              // Claymorphic surface: slightly lifted above #040404 background
              color: _isPressed ? const Color(0xFF08080B) : const Color(0xFF0C0C10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isPressed
                    ? accent.withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.05),
                width: 1.0,
              ),
              boxShadow: [
                // Deep outer shadow giving tangible volume
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.85),
                  offset: const Offset(2, 4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
                // Subtle top edge highlight reflection
                if (!_isPressed)
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.03),
                    offset: const Offset(0, -1),
                    blurRadius: 2,
                  ),
              ],
            ),
            child: Row(
              children: [
                // Clay Inset Icon Pod
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.30),
                      width: 0.9,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        offset: const Offset(1, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(widget.icon, color: accent, size: 18),
                ),
                const SizedBox(width: 10),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.badge != null) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: accent.withValues(alpha: 0.45),
                                  width: 0.6,
                                ),
                              ),
                              child: Text(
                                widget.badge!,
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 10.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0x44FFFFFF),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
