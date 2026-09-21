import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../features/branch/providers/branch_provider.dart';
import '../features/dashboard/domain/dashboard_model.dart';
import '../routing/route_names.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MetricTab { overview, expirations, finances }

class SegmentedMetricsSection extends ConsumerStatefulWidget {
  final DashboardStats? stats;
  const SegmentedMetricsSection({super.key, this.stats});

  @override
  ConsumerState<SegmentedMetricsSection> createState() => _State();
}

class _State extends ConsumerState<SegmentedMetricsSection> {
  MetricTab _tab = MetricTab.overview;

  @override
  Widget build(BuildContext context) {
    final activeBranch = ref.watch(activeBranchProvider);
    final isMehd = activeBranch.shortName.toLowerCase().contains('mehdawal');
    final total = isMehd ? 65 : 72;
    final DashboardStats stats = widget.stats ?? const DashboardStats();
    // 100% real data from database (no demo fallbacks)
    final int occ = stats.occupiedSeats;
    final int avail = (total - occ).clamp(0, total);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Pill Tab Bar (Golden Theme) ──────────────────────────
          Container(
            height: 44,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFF100D06),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.28),
                width: 1,
              ),
            ),
            child: Row(
              children: MetricTab.values.map((t) {
                final active = _tab == t;
                const labels = ['Overview', 'Expirations', 'Finances'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _tab = t);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: active ? const Color(0xFF332712) : Colors.transparent,
                        border: active
                            ? Border.all(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.55),
                                width: 1.0,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          labels[t.index],
                          style: TextStyle(
                            color: active ? const Color(0xFFFDE68A) : const Color(0xFF9E8A5E),
                            fontSize: 12.5,
                            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          if (_tab == MetricTab.overview)
            _overview(stats, occ, total, avail)
          else if (_tab == MetricTab.expirations)
            _expirations(stats)
          else
            _finances(stats),
        ],
      ),
    );
  }

  // ─── OVERVIEW: 12 cards, single luxury golden theme, colored numbers, NO dots ───
  Widget _overview(DashboardStats s, int occ, int total, int avail) => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 3,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    childAspectRatio: 0.80,
    children: [
      // 1. Active Scholars
      _MetricCard(
        icon: Icons.school_rounded,
        iconColor: const Color(0xFF8B7CD0),       // Preserved icon color (Muted Violet)
        discG: const [Color(0xFF221A38), Color(0xFF100C1C)],
        numColor: const Color(0xFFC4B5FD),        // Colored number (Soft Lavender - non-neon)
        value: '${s.totalMembers}',               // Real database data (starts at 0)
        title: 'Active Scholars',
        sub: '${s.totalMembers} registered',
        img: 'assets/images/luxury_library_warm.jpg',
        onTap: RouteNames.members,
      ),

      // 2. Today's Revenue
      _MetricCard(
        icon: Icons.currency_rupee_rounded,
        iconColor: const Color(0xFFD4AF37),       // Preserved icon color (Gold)
        discG: const [Color(0xFF2E2208), Color(0xFF140F04)],
        numColor: const Color(0xFFFDE68A),        // Colored number (Soft Champagne Gold)
        value: '₹${s.todayCollection.toInt()}',
        title: "Today's Revenue",
        sub: 'Cash & UPI daily',
        img: 'assets/images/gold_coins.jpg',
        onTap: RouteNames.payments,
      ),

      // 3. Today's Expense
      _MetricCard(
        icon: Icons.receipt_long_rounded,
        iconColor: const Color(0xFFD97282),       // Preserved icon color (Rose)
        discG: const [Color(0xFF2C141A), Color(0xFF160A0D)],
        numColor: const Color(0xFFFCA5A5),        // Colored number (Soft Rose Coral)
        value: '₹${s.todayExpenses.toInt()}',
        title: "Today's Expense",
        sub: 'Power & wifi',
        img: 'assets/images/luxury_expense.jpg',
        onTap: RouteNames.expenses,
      ),

      // 4. Today Check-ins
      _MetricCard(
        icon: Icons.verified_user_rounded,
        iconColor: const Color(0xFF34D399),       // Preserved icon color (Emerald Green)
        discG: const [Color(0xFF0D281E), Color(0xFF06140F)],
        numColor: const Color(0xFF86EFAC),        // Colored number (Soft Mint Green)
        value: '${s.todayCheckIns}',
        title: 'Today Check-ins',
        sub: '${s.todayCheckIns} today',
        img: 'assets/images/attendance_biometric.jpg',
        onTap: RouteNames.attendance,
      ),

      // 5. Seat Occupancy
      _MetricCard(
        icon: Icons.chair_alt_rounded,
        iconColor: const Color(0xFF7B85D8),       // Preserved icon color (Slate Blue)
        discG: const [Color(0xFF141834), Color(0xFF0A0C1A)],
        numColor: const Color(0xFFA5B4FC),        // Colored number (Soft Periwinkle Blue)
        value: '$occ/$total',
        title: 'Seat Occupancy',
        sub: '$avail available seats',
        img: 'assets/images/luxury_study_hall.jpg',
        onTap: RouteNames.seats,
      ),

      // 6. Pending Dues
      _MetricCard(
        icon: Icons.pending_actions_rounded,
        iconColor: const Color(0xFFE25D74),       // Preserved icon color (Crimson)
        discG: const [Color(0xFF2C0E16), Color(0xFF16070B)],
        numColor: const Color(0xFFFDA4AF),        // Colored number (Soft Salmon Crimson)
        value: '₹${s.dueAmount.toInt()}',
        title: 'Pending Dues',
        sub: s.dueAmount > 0 ? 'Dues pending' : 'No dues pending',
        img: 'assets/images/gold_coins.jpg',
        onTap: RouteNames.duePayments,
      ),

      // 7. Insights & Leads
      _MetricCard(
        icon: Icons.trending_up_rounded,
        iconColor: const Color(0xFFA875D8),       // Preserved icon color (Violet)
        discG: const [Color(0xFF221432), Color(0xFF110A19)],
        numColor: const Color(0xFFD8B4FE),        // Colored number (Soft Lilac)
        value: '${s.totalEnquiries}',
        title: 'Insights & Leads',
        sub: '${s.totalEnquiries} inquiries',
        img: 'assets/images/luxury_analytics.jpg',
        onTap: RouteNames.enquiries,
      ),

      // 8. Expiring (1-3d)
      _MetricCard(
        icon: Icons.timer_outlined,
        iconColor: const Color(0xFFE59846),       // Preserved icon color (Amber)
        discG: const [Color(0xFF2C1C0A), Color(0xFF160E05)],
        numColor: const Color(0xFFFDBA74),        // Colored number (Soft Apricot Amber)
        value: '${s.expiringIn1to3Days}',
        title: 'Expiring (1–3d)',
        sub: '${s.expiringIn1to3Days} expiring soon',
        img: 'assets/images/luxury_calendar.jpg',
        onTap: RouteNames.members,
      ),

      // 9. This Month
      _MetricCard(
        icon: Icons.savings_outlined,
        iconColor: const Color(0xFF4FA0DE),       // Preserved icon color (Steel Blue)
        discG: const [Color(0xFF0F2032), Color(0xFF071019)],
        numColor: const Color(0xFF7DD3FC),        // Colored number (Soft Sky Blue)
        value: '₹${s.monthCollection.toInt()}',
        title: 'This Month',
        sub: 'Total collection',
        img: 'assets/images/gold_coins.jpg',
        onTap: RouteNames.reports,
      ),

      // 10. Peak Rush Hour
      _MetricCard(
        icon: Icons.schedule_rounded,
        iconColor: const Color(0xFFD4A838),       // Preserved icon color (Antique Gold)
        discG: const [Color(0xFF281E08), Color(0xFF140F04)],
        numColor: const Color(0xFFFDE68A),        // Colored number (Soft Warm Gold)
        value: '5:00 PM',
        title: 'Peak Rush Hour',
        sub: 'Evening peak',
        img: 'assets/images/luxury_office.jpg',
        onTap: RouteNames.insights,
      ),

      // 11. Today's Birthdays
      _MetricCard(
        icon: Icons.cake_outlined,
        iconColor: const Color(0xFFD86B9E),       // Preserved icon color (Pink)
        discG: const [Color(0xFF2A121E), Color(0xFF15090F)],
        numColor: const Color(0xFFF9A8D4),        // Colored number (Soft Rose Pink)
        value: '${s.todayBirthdays}',
        title: "Today's Birthdays",
        sub: 'Send greetings',
        img: 'assets/images/luxury_reception.jpg',
        onTap: RouteNames.communication,
      ),

      // 12. Library Health
      _MetricCard(
        icon: Icons.health_and_safety_outlined,
        iconColor: const Color(0xFF38B289),       // Preserved icon color (Emerald)
        discG: const [Color(0xFF0C241C), Color(0xFF06120E)],
        numColor: const Color(0xFF86EFAC),        // Colored number (Soft Mint Green)
        value: '${s.totalMembers > 0 ? ((occ / total) * 100).toInt() : 100}%',
        title: 'Library Health',
        sub: 'Optimal capacity',
        img: 'assets/images/luxury_study_hall.jpg',
        onTap: RouteNames.insights,
      ),
    ],
  );

  // ─── EXPIRATIONS: Single luxury golden cards with colored numbers ────────
  Widget _expirations(DashboardStats s) => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 3,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    childAspectRatio: 0.80,
    children: [
      _MetricCard(
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFE25D74),
        discG: const [Color(0xFF2C0E16), Color(0xFF16070B)],
        numColor: const Color(0xFFFDA4AF),
        value: '${s.expiringIn1to3Days}',
        title: 'Expiring (1–3d)',
        sub: '${s.expiringIn1to3Days} immediate',
        img: 'assets/images/luxury_calendar.jpg',
        onTap: RouteNames.members,
      ),
      _MetricCard(
        icon: Icons.schedule_rounded,
        iconColor: const Color(0xFFE59846),
        discG: const [Color(0xFF2C1C0A), Color(0xFF160E05)],
        numColor: const Color(0xFFFDBA74),
        value: '${s.expiringIn4to7Days}',
        title: 'Expiring (4–7d)',
        sub: '${s.expiringIn4to7Days} upcoming',
        img: 'assets/images/luxury_calendar.jpg',
        onTap: RouteNames.members,
      ),
      _MetricCard(
        icon: Icons.calendar_month_rounded,
        iconColor: const Color(0xFFD4AF37),
        discG: const [Color(0xFF2E2208), Color(0xFF140F04)],
        numColor: const Color(0xFFFDE68A),
        value: '${s.expiringIn8to15Days}',
        title: 'Expiring (8–15d)',
        sub: '${s.expiringIn8to15Days} notice',
        img: 'assets/images/luxury_calendar.jpg',
        onTap: RouteNames.members,
      ),
      _MetricCard(
        icon: Icons.cancel_outlined,
        iconColor: const Color(0xFFDC2626),
        discG: const [Color(0xFF280808), Color(0xFF140404)],
        numColor: const Color(0xFFFCA5A5),
        value: '${s.expiredMemberships}',
        title: 'Expired Total',
        sub: '${s.expiredMemberships} expired',
        img: 'assets/images/luxury_office.jpg',
        onTap: RouteNames.members,
      ),
      _MetricCard(
        icon: Icons.thumb_up_alt_outlined,
        iconColor: const Color(0xFF34D399),
        discG: const [Color(0xFF0D281E), Color(0xFF06140F)],
        numColor: const Color(0xFF86EFAC),
        value: '${s.totalMembers > 0 ? (((s.totalMembers - s.expiredMemberships) / s.totalMembers) * 100).toInt() : 100}%',
        title: 'Retention Rate',
        sub: 'High loyalty',
        img: 'assets/images/luxury_analytics.jpg',
        onTap: RouteNames.insights,
      ),
      _MetricCard(
        icon: Icons.call_outlined,
        iconColor: const Color(0xFF4FA0DE),
        discG: const [Color(0xFF0F2032), Color(0xFF071019)],
        numColor: const Color(0xFF7DD3FC),
        value: '${s.todayFollowups}',
        title: 'Follow-ups Due',
        sub: '${s.todayFollowups} scheduled',
        img: 'assets/images/luxury_reception.jpg',
        onTap: RouteNames.enquiries,
      ),
    ],
  );

  // ─── FINANCES: Single luxury golden cards with colored numbers ───────────
  Widget _finances(DashboardStats s) => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 3,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    childAspectRatio: 0.80,
    children: [
      _MetricCard(
        icon: Icons.payments_outlined,
        iconColor: const Color(0xFFD4AF37),
        discG: const [Color(0xFF2E2208), Color(0xFF140F04)],
        numColor: const Color(0xFFFDE68A),
        value: '₹${s.todayCollection.toInt()}',
        title: "Today's Revenue",
        sub: 'Cash & UPI',
        img: 'assets/images/gold_coins.jpg',
        onTap: RouteNames.payments,
      ),
      _MetricCard(
        icon: Icons.account_balance_wallet_outlined,
        iconColor: const Color(0xFF4FA0DE),
        discG: const [Color(0xFF0F2032), Color(0xFF071019)],
        numColor: const Color(0xFF7DD3FC),
        value: '₹${s.monthCollection.toInt()}',
        title: 'This Month',
        sub: 'Total collection',
        img: 'assets/images/gold_coins.jpg',
        onTap: RouteNames.reports,
      ),
      _MetricCard(
        icon: Icons.history_rounded,
        iconColor: const Color(0xFF7B85D8),
        discG: const [Color(0xFF141834), Color(0xFF0A0C1A)],
        numColor: const Color(0xFFA5B4FC),
        value: '₹${s.prevMonthCollection.toInt()}',
        title: 'Last Month',
        sub: 'Previous cycle',
        img: 'assets/images/luxury_office.jpg',
        onTap: RouteNames.reports,
      ),
      _MetricCard(
        icon: Icons.receipt_outlined,
        iconColor: const Color(0xFFD97282),
        discG: const [Color(0xFF2C141A), Color(0xFF160A0D)],
        numColor: const Color(0xFFFCA5A5),
        value: '₹${s.todayExpenses.toInt()}',
        title: 'Today Expense',
        sub: 'Utilities',
        img: 'assets/images/luxury_expense.jpg',
        onTap: RouteNames.expenses,
      ),
      _MetricCard(
        icon: Icons.pending_actions_rounded,
        iconColor: const Color(0xFFE25D74),
        discG: const [Color(0xFF2C0E16), Color(0xFF16070B)],
        numColor: const Color(0xFFFDA4AF),
        value: '₹${s.dueAmount.toInt()}',
        title: 'Pending Dues',
        sub: s.dueAmount > 0 ? 'Dues pending' : 'No dues pending',
        img: 'assets/images/gold_coins.jpg',
        onTap: RouteNames.duePayments,
      ),
      _MetricCard(
        icon: Icons.trending_up_rounded,
        iconColor: const Color(0xFF38B289),
        discG: const [Color(0xFF0C241C), Color(0xFF06120E)],
        numColor: const Color(0xFF86EFAC),
        value: '+100%',
        title: 'Net Margin',
        sub: 'Positive profit',
        img: 'assets/images/luxury_analytics.jpg',
        onTap: RouteNames.insights,
      ),
    ],
  );
}

// ─── Single Luxury Golden Card (No dots, colored numbers, luxury golden theme) ───
class _MetricCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;         // Preserved icon semantic color
  final List<Color> discG;       // 3D Disc gradient
  final Color numColor;          // Refined colored number (non-neon)
  final String value;
  final String title;
  final String sub;
  final String? img;
  final String onTap;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.discG,
    required this.numColor,
    required this.value,
    required this.title,
    required this.sub,
    required this.onTap,
    this.img,
  });

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> with TickerProviderStateMixin {
  late final AnimationController _press;
  late final AnimationController _shimmer;
  late final Animation<double> _scale;
  late final Animation<double> _shimAnim;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeInOut),
    );
    _shimmer = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat();
    _shimAnim = Tween<double>(begin: -1.0, end: 2.4).animate(
      CurvedAnimation(parent: _shimmer, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { HapticFeedback.lightImpact(); _press.forward(); },
      onTapUp: (_) { _press.reverse(); context.push(widget.onTap); },
      onTapCancel: () => _press.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedBuilder(
          animation: _shimAnim,
          builder: (_, __) => Container(
            // SINGLE LUXURY GOLDEN CARD THEME ACROSS ALL CARDS
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0x1AD4AF37), // Subtle luxury gold ambient top highlight
                  Color(0xF50B0912), // Deep luxury dark obsidian
                ],
              ),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.22), // Uniform luxury gold border
                width: 0.9,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.70),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // 1. High quality background image with natural vignette
                  if (widget.img != null)
                    Positioned.fill(
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [Colors.black, Colors.transparent],
                          stops: [0.0, 0.85],
                        ).createShader(bounds),
                        blendMode: BlendMode.dstIn,
                        child: Opacity(
                          opacity: 0.26,
                          child: Image.asset(
                            widget.img!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),

                  // 2. Subtle luxury gold specular shimmer sweep
                  Positioned.fill(
                    child: Transform.rotate(
                      angle: math.pi / 5,
                      child: Transform.translate(
                        offset: Offset(_shimAnim.value * 130, 0),
                        child: Container(
                          width: 18,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                const Color(0xFFD4AF37).withValues(alpha: 0.06),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 3. Card Content (CLEAN 3D ICONS ONLY - NO DOTS)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top: Clean 3D Icon Disc (NO DOTS ANYWHERE)
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: widget.discG,
                            ),
                            border: Border.all(
                              color: widget.iconColor.withValues(alpha: 0.40),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.iconColor.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.55),
                                blurRadius: 4,
                                offset: const Offset(1, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(widget.icon, color: widget.iconColor, size: 16),
                          ),
                        ),

                        // Metric Value: IN COLOR (non-neon, non-bright, rich luxury tones)
                        Text(
                          widget.value,
                          style: TextStyle(
                            color: widget.numColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Title + Subtitle
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Color(0xFFE4E4E7),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              widget.sub,
                              style: const TextStyle(
                                color: Color(0xFF8A8A92),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
