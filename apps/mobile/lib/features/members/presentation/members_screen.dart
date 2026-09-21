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

class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: Colors.black,
          elevation: 4,
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Add Member', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () => context.push(RouteNames.addMember),
        ),
      ),
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
                      onPressed: () => HapticFeedback.lightImpact(),
                    ),
                    // Filter Icon
                    IconButton(
                      icon: const Icon(Icons.filter_list_rounded, color: Colors.white, size: 22),
                      tooltip: 'Filter',
                      onPressed: () => HapticFeedback.lightImpact(),
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
                    // Add Member Icon (Yellow)
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
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryCard(
                        ref: ref,
                        title: 'Expired\nMemberships',
                        count: stats['expired'] ?? 0,
                        statusKey: 'expired',
                        currentStatus: filter.status,
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryCard(
                        ref: ref,
                        title: 'Expiring\n(1-3 Days)',
                        count: stats['expiring1_3'] ?? 0,
                        statusKey: 'expiring1_3',
                        currentStatus: filter.status,
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryCard(
                        ref: ref,
                        title: 'Expiring\n(4-7 Days)',
                        count: stats['expiring4_7'] ?? 0,
                        statusKey: 'expiring4_7',
                        currentStatus: filter.status,
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryCard(
                        ref: ref,
                        title: 'Expiring\n(8-15 Days)',
                        count: stats['expiring8_15'] ?? 0,
                        statusKey: 'expiring8_15',
                        currentStatus: filter.status,
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryCard(
                        ref: ref,
                        title: 'All\nMembers',
                        count: stats['all'] ?? 0,
                        statusKey: 'all',
                        currentStatus: filter.status,
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
                  color: const Color(0xFFDC2626),
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

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.only(bottom: 90, top: 4),
                        itemCount: res.data.length,
                        itemBuilder: (context, index) {
                          final member = res.data[index];
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
        width: 108,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF332712) : const Color(0xFF130F08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFFD4AF37).withValues(alpha: 0.20),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
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
                color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF261D0C),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.50),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF100C05) : const Color(0xFFFDE68A),
                    fontSize: 11,
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
