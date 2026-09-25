import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/route_names.dart';
import '../../../widgets/ambient_background.dart';
import '../../../widgets/swipeable_branch_card.dart';
import '../../../widgets/chintamani_photo_facilities.dart';
import '../../../widgets/multicolor_quick_access_bar.dart';
import '../../../widgets/segmented_metrics_section.dart';
import '../../../widgets/app_drawer.dart';
import '../../../core/services/app_update_service.dart';
import '../../../widgets/app_update_dialog.dart';
import '../../branch/providers/branch_provider.dart';
import '../data/dashboard_repository.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUpdate());
  }

  Future<void> _checkUpdate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final service = ref.read(appUpdateServiceProvider);
    final autoCheck = await service.isAutoCheckEnabled();
    if (!autoCheck || !mounted) return;

    final update = await service.checkForUpdate();
    if (update != null && mounted) {
      AppUpdateDialog.show(context, update);
    }
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final activeBranch = ref.watch(activeBranchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      drawer: const AppDrawer(),
      body: AmbientBackground(
        imagePath: 'assets/images/dashboard_bg.png',
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: const Color(0xFFD4AF37),
            backgroundColor: const Color(0xFF141218),
            onRefresh: () async => ref.invalidate(dashboardStatsProvider),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                // ── TOP BAR WITH IMPERIAL GLOWING LOGO ───────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        // Imperial Gold Glowing Logo
                        Builder(
                          builder: (ctx) => GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Scaffold.of(ctx).openDrawer();
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  colors: [Color(0xFF281E0C), Color(0xFF120E06)],
                                ),
                                border: Border.all(
                                  color: const Color(0xFFE5C07B).withValues(alpha: 0.7),
                                  width: 1.4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFD4AF37).withValues(alpha: 0.55),
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.8),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(5.5),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.auto_stories_rounded,
                                    color: Color(0xFFD4AF37),
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Title
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'CHINTA MANI LIBRARY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                activeBranch.shortName,
                                style: const TextStyle(
                                  color: Color(0xFFD4AF37),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Search & Notifications
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          icon: const Icon(Icons.search_rounded,
                              color: Color(0xFFD4AF37), size: 21),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.push(RouteNames.search);
                          },
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          icon: const Icon(Icons.notifications_none_rounded,
                              color: Color(0xFFD4AF37), size: 22),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.push(RouteNames.notifications);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // ── SWIPEABLE BRANCH CARD (Photo in BG with Vignette & Reduced Opacity) ──
                SliverToBoxAdapter(
                  child: statsAsync.when(
                    data: (s) => SwipeableBranchCard(stats: s),
                    loading: () => const SwipeableBranchCard(),
                    error: (_, __) => const SwipeableBranchCard(),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // ── GREETING ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${_greeting()}, Manglesh Ji',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // ── FACILITIES SLIDING CARDS ─────────────────────────────
                const SliverToBoxAdapter(child: ChintamaniPhotoFacilities()),

                const SliverToBoxAdapter(child: SizedBox(height: 14)),

                // ── QUICK ACCESS (5 CARDS AS IN 4TH PHOTO WITH ANIMATIONS) ────
                const SliverToBoxAdapter(child: MulticolorQuickAccessBar()),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── OVERVIEW / EXPIRATIONS / FINANCES (3D GRAPHICS, MULTICOLOUR & MOTIONS)
                SliverToBoxAdapter(
                  child: statsAsync.when(
                    data: (s) => SegmentedMetricsSection(stats: s),
                    loading: () => const SegmentedMetricsSection(),
                    error: (_, __) => const SegmentedMetricsSection(),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
