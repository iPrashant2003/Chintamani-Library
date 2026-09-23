import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/ambient_background.dart';
import '../../../widgets/search_bar_widget.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../data/member_repository.dart';
import 'widgets/member_card.dart';

// Sort options
enum MemberSortOption { nameAZ, nameZA, newest, expiringSoon }

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  MemberSortOption _sortOption = MemberSortOption.newest;

  void _showSortSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortBottomSheet(
        current: _sortOption,
        onSelected: (opt) {
          setState(() => _sortOption = opt);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showFilterSheet() {
    HapticFeedback.lightImpact();
    final filter = ref.read(memberFilterProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterBottomSheet(
        currentStatus: filter.status,
        onSelected: (status) {
          ref.read(memberFilterProvider.notifier).state =
              filter.copyWith(status: status);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(memberFilterProvider);
    final membersAsync = ref.watch(membersListProvider);
    final statsAsync = ref.watch(memberStatsProvider);
    final stats = statsAsync.value ?? const {
      'active': 0,
      'expired': 0,
      'expiring1_3': 0,
      'expiring4_7': 0,
      'expiring8_15': 0,
      'all': 0,
    };

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header with Title and Screenshot-Style Action Icons
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(RouteNames.dashboard);
                        }
                      },
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Members',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    // Sort Icon
                    IconButton(
                      icon: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 22),
                      tooltip: 'Sort Members',
                      onPressed: _showSortSheet,
                    ),
                    // Filter Icon
                    IconButton(
                      icon: const Icon(Icons.filter_list_rounded, color: Colors.white, size: 22),
                      tooltip: 'Filter',
                      onPressed: _showFilterSheet,
                    ),
                    // Search Icon
                    IconButton(
                      icon: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
                      tooltip: 'Search',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.push(RouteNames.search);
                      },
                    ),
                    // Add Member Icon
                    IconButton(
                      icon: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFFFACC15), size: 24),
                      tooltip: 'Add Member',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.push(RouteNames.addMember);
                      },
                    ),
                  ],
                ),
              ),

              // Category Cards Row (Live Memberships, Expired, Expiring...)

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildCategoryCard(
                        ref: ref,
                        title: 'Live\nMemberships',
                        count: stats['active'] ?? 0,
                        statusKey: 'active',
                        currentStatus: filter.status,
                        accentColor: const Color(0xFF059669), // Sea Green
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryCard(
                        ref: ref,
                        title: 'Expired\nMemberships',
                        count: stats['expired'] ?? 0,
                        statusKey: 'expired',
                        currentStatus: filter.status,
                        accentColor: const Color(0xFFDC2626), // Red
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryCard(
                        ref: ref,
                        title: 'Expiring\n(1-3 Days)',
                        count: stats['expiring1_3'] ?? 0,
                        statusKey: 'expiring1_3',
                        currentStatus: filter.status,
                        accentColor: const Color(0xFFE11D48), // Pinkish Red
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryCard(
                        ref: ref,
                        title: 'Expiring\n(4-7 Days)',
                        count: stats['expiring4_7'] ?? 0,
                        statusKey: 'expiring4_7',
                        currentStatus: filter.status,
                        accentColor: const Color(0xFFD97706), // Dark Yellow
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryCard(
                        ref: ref,
                        title: 'Expiring\n(8-15 Days)',
                        count: stats['expiring8_15'] ?? 0,
                        statusKey: 'expiring8_15',
                        currentStatus: filter.status,
                        accentColor: const Color(0xFF2563EB), // Blue
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryCard(
                        ref: ref,
                        title: 'All\nMembers',
                        count: stats['all'] ?? 0,
                        statusKey: 'all',
                        currentStatus: filter.status,
                        accentColor: const Color(0xFF7C3AED), // Purple
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: SearchBarWidget(
                  hintText: 'Search by name, phone or CML code...',
                  onChanged: (query) {
                    ref.read(memberFilterProvider.notifier).state =
                        filter.copyWith(searchQuery: query);
                  },
                  onClear: () {
                    ref.read(memberFilterProvider.notifier).state =
                        filter.copyWith(searchQuery: '');
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Member list with smooth pull-to-refresh
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF059669),
                  backgroundColor: AppColors.bgCard,
                  onRefresh: () async => ref.invalidate(membersListProvider),
                  child: membersAsync.when(
                    data: (res) {
                      if (res.data.isEmpty) {
                        return EmptyState(
                          icon: Icons.group_off_rounded,
                          title: 'No members found',
                          subtitle: filter.searchQuery.isNotEmpty
                              ? 'No results matching "${filter.searchQuery}"'
                              : 'No members in this category.',
                          actionLabel: '+ Add Member',
                          onAction: () => context.push(RouteNames.addMember),
                        );
                      }

                      final sorted = [...res.data];
                      switch (_sortOption) {
                        case MemberSortOption.nameAZ:
                          sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                          break;
                        case MemberSortOption.nameZA:
                          sorted.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
                          break;
                        case MemberSortOption.expiringSoon:
                          sorted.sort((a, b) {
                            final da = a.activeSubscription?.endDate ?? DateTime(2099);
                            final db = b.activeSubscription?.endDate ?? DateTime(2099);
                            return da.compareTo(db);
                          });
                          break;
                        case MemberSortOption.newest:
                        default:
                          break; // keep server order (newest first)
                      }

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.only(bottom: 90, top: 4),
                        itemCount: sorted.length,
                        itemBuilder: (context, index) {
                          final member = sorted[index];
                          return MemberCard(
                            member: member,
                            onTap: () {
                              context.push(RouteNames.memberDetail.replaceFirst(':id', member.id));
                            },
                          ).animate().fadeIn(delay: (index * 25).ms, duration: 250.ms).slideY(begin: 0.04, end: 0);
                        },
                      );

                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Color(0xFFDC2626)),
                    ),
                    error: (e, _) => ErrorState(
                      message: 'Unable to load members: $e',
                      onRetry: () => ref.invalidate(membersListProvider),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required WidgetRef ref,
    required String title,
    required int count,
    required String statusKey,
    required String currentStatus,
    required Color accentColor,
  }) {
    final isSelected = currentStatus == statusKey;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(memberFilterProvider.notifier).state =
            ref.read(memberFilterProvider).copyWith(status: statusKey);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.25) : const Color(0xCC161412),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : accentColor.withOpacity(0.35),
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? accentColor.withOpacity(0.35) : Colors.black.withOpacity(0.3),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFA1A1AA),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : accentColor.withValues(alpha: 0.20),
                shape: BoxShape.circle,
                border: isSelected ? null : Border.all(color: accentColor.withValues(alpha: 0.6), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? accentColor : Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sort Bottom Sheet ─────────────────────────────────────────────────────────
class _SortBottomSheet extends StatelessWidget {
  final MemberSortOption current;
  final ValueChanged<MemberSortOption> onSelected;

  const _SortBottomSheet({required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const options = [
      (MemberSortOption.newest, Icons.schedule_rounded, 'Newest First', Color(0xFF2563EB)),
      (MemberSortOption.nameAZ, Icons.sort_by_alpha_rounded, 'Name A → Z', Color(0xFF059669)),
      (MemberSortOption.nameZA, Icons.sort_by_alpha_rounded, 'Name Z → A', Color(0xFF7C3AED)),
      (MemberSortOption.expiringSoon, Icons.timer_outlined, 'Expiring Soon', Color(0xFFD97706)),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Sort Members', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 12),
          ...options.map((opt) {
            final (optVal, icon, label, color) = opt;
            final isSelected = current == optVal;
            return GestureDetector(
              onTap: () => onSelected(optVal),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.18) : const Color(0xFF1C1C1C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? color.withValues(alpha: 0.6) : Colors.white12, width: 1.2),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: isSelected ? color : Colors.white54, size: 20),
                    const SizedBox(width: 12),
                    Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFFCCCCCC), fontSize: 14, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                    const Spacer(),
                    if (isSelected) Icon(Icons.check_circle_rounded, color: color, size: 18),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Filter Bottom Sheet ───────────────────────────────────────────────────────
class _FilterBottomSheet extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onSelected;

  const _FilterBottomSheet({required this.currentStatus, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const filters = [
      ('all', Icons.people_alt_rounded, 'All Members', Color(0xFF7C3AED)),
      ('active', Icons.verified_rounded, 'Live Memberships', Color(0xFF059669)),
      ('expired', Icons.cancel_rounded, 'Expired', Color(0xFFDC2626)),
      ('expiring1_3', Icons.warning_amber_rounded, 'Expiring in 1-3 Days', Color(0xFFE11D48)),
      ('expiring4_7', Icons.hourglass_bottom_rounded, 'Expiring in 4-7 Days', Color(0xFFD97706)),
      ('expiring8_15', Icons.event_rounded, 'Expiring in 8-15 Days', Color(0xFF2563EB)),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Filter Members', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 12),
          ...filters.map((f) {
            final (key, icon, label, color) = f;
            final isSelected = currentStatus == key;
            return GestureDetector(
              onTap: () => onSelected(key),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.18) : const Color(0xFF1C1C1C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? color.withValues(alpha: 0.6) : Colors.white12, width: 1.2),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: isSelected ? color : Colors.white54, size: 20),
                    const SizedBox(width: 12),
                    Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFFCCCCCC), fontSize: 14, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                    const Spacer(),
                    if (isSelected) Icon(Icons.check_circle_rounded, color: color, size: 18),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
