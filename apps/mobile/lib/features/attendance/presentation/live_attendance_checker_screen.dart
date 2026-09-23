import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/ambient_background.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/member_avatar.dart';
import '../../branch/providers/branch_provider.dart';
import '../../members/data/member_repository.dart';
import '../../members/domain/member_model.dart';
import '../data/attendance_repository.dart';
import '../domain/attendance_model.dart';

enum AttendanceFilter { all, present, absent }

class MemberAttendanceStatus {
  final Member member;
  final Attendance? attendance;

  bool get isPresent => attendance != null;
  DateTime? get checkInTime => attendance?.checkIn;
  DateTime? get checkOutTime => attendance?.checkOut;
  String get method => attendance?.method ?? 'NONE';

  const MemberAttendanceStatus({
    required this.member,
    this.attendance,
  });
}

final liveAttendanceListProvider = FutureProvider.autoDispose<List<MemberAttendanceStatus>>((ref) async {
  final branch = ref.watch(activeBranchProvider);
  final memberRepo = ref.read(memberRepositoryProvider);
  final attRepo = ref.read(attendanceRepositoryProvider);

  // Fetch active members and today's attendance records concurrently
  final results = await Future.wait([
    memberRepo.getMembers(branchId: branch.id, status: 'active', limit: 1000),
    attRepo.getTodayAttendance(branch.id),
  ]);

  final membersResponse = results[0] as dynamic;
  final List<Member> members = membersResponse.data as List<Member>;
  final List<Attendance> attendances = results[1] as List<Attendance>;

  // Map of memberId -> Attendance
  final Map<String, Attendance> attMap = {};
  for (final att in attendances) {
    if (att.memberId.isNotEmpty) {
      attMap[att.memberId] = att;
    }
    if (att.memberCode != null && att.memberCode!.isNotEmpty) {
      attMap[att.memberCode!] = att;
    }
  }

  return members.map((m) {
    final att = attMap[m.id] ?? attMap[m.memberCode];
    return MemberAttendanceStatus(member: m, attendance: att);
  }).toList();
});

class LiveAttendanceCheckerScreen extends ConsumerStatefulWidget {
  const LiveAttendanceCheckerScreen({super.key});

  @override
  ConsumerState<LiveAttendanceCheckerScreen> createState() => _LiveAttendanceCheckerScreenState();
}

class _LiveAttendanceCheckerScreenState extends ConsumerState<LiveAttendanceCheckerScreen> {
  AttendanceFilter _filter = AttendanceFilter.all;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _markMemberPresent(Member member) async {
    HapticFeedback.mediumImpact();
    final activeBranch = ref.read(activeBranchProvider);
    final repo = ref.read(attendanceRepositoryProvider);

    try {
      await repo.markAttendance(
        memberId: member.id,
        branchId: activeBranch.id,
        method: 'MANUAL',
      );

      // Invalidate attendance providers to reload live stream
      ref.invalidate(todayAttendanceProvider);
      ref.invalidate(liveAttendanceListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            content: Text('✅ ${member.name} marked present for today!'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFEF4444),
            content: Text('Could not mark attendance for ${member.name}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeBranch = ref.watch(activeBranchProvider);
    final rosterAsync = ref.watch(liveAttendanceListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B12),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Everyday Live Attendance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              '${activeBranch.name} • ${DateFormat('EEEE, d MMM yyyy').format(DateTime.now())}',
              style: const TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFD4AF37)),
            onPressed: () {
              ref.invalidate(todayAttendanceProvider);
              ref.invalidate(liveAttendanceListProvider);
            },
          ),
        ],
      ),
      body: AmbientBackground(
        child: rosterAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
            ),
          ),
          error: (err, _) => Center(
            child: Text(
              'Error loading live roster: $err',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          data: (allRoster) {
            final totalMembers = allRoster.length;
            final presentCount = allRoster.where((r) => r.isPresent).length;
            final absentCount = totalMembers - presentCount;
            final percentage = totalMembers > 0 ? (presentCount / totalMembers * 100).round() : 0;

            // Apply filter
            var filtered = allRoster;
            if (_filter == AttendanceFilter.present) {
              filtered = filtered.where((r) => r.isPresent).toList();
            } else if (_filter == AttendanceFilter.absent) {
              filtered = filtered.where((r) => !r.isPresent).toList();
            }

            // Apply search
            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              filtered = filtered.where((r) {
                final m = r.member;
                final nameMatches = m.name.toLowerCase().contains(q);
                final codeMatches = m.memberCode.toLowerCase().contains(q);
                final phoneMatches = m.phone != null && m.phone!.contains(q);
                final seatMatches = (m.currentSeatNumber ?? '').toLowerCase().contains(q);
                return nameMatches || codeMatches || phoneMatches || seatMatches;
              }).toList();
            }

            return Column(
              children: [
                // ── SUMMARY METRICS HEADER ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xF2161A24),
                          Color(0xF80E1118),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMetricItem(
                              label: 'Total Active',
                              value: '$totalMembers',
                              color: const Color(0xFF38BDF8),
                              icon: Icons.groups_rounded,
                            ),
                            Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.1)),
                            _buildMetricItem(
                              label: 'Present Today',
                              value: '$presentCount',
                              color: const Color(0xFF10B981),
                              icon: Icons.check_circle_rounded,
                            ),
                            Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.1)),
                            _buildMetricItem(
                              label: 'Absent',
                              value: '$absentCount',
                              color: const Color(0xFFF43F5E),
                              icon: Icons.cancel_rounded,
                            ),
                            Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.1)),
                            _buildMetricItem(
                              label: 'Turnout',
                              value: '$percentage%',
                              color: const Color(0xFFE8C97A),
                              icon: Icons.pie_chart_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: totalMembers > 0 ? (presentCount / totalMembers) : 0,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFF43F5E).withValues(alpha: 0.35),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── SEARCH BAR ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF11151E),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: 'Search by student name, ID, phone or seat...',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 12.5,
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFD4AF37), size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: Colors.white54, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── FILTER CHIPS ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterChip('All ($totalMembers)', AttendanceFilter.all, const Color(0xFF38BDF8)),
                      const SizedBox(width: 8),
                      _buildFilterChip('Present ($presentCount)', AttendanceFilter.present, const Color(0xFF10B981)),
                      const SizedBox(width: 8),
                      _buildFilterChip('Absent ($absentCount)', AttendanceFilter.absent, const Color(0xFFF43F5E)),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ── MEMBER LIST ────────────────────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? EmptyState(
                          icon: Icons.person_search_rounded,
                          title: 'No members match filter',
                          subtitle: _searchQuery.isNotEmpty
                              ? 'No live members found matching "$_searchQuery"'
                              : 'No members in this category today.',
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return _buildMemberCard(item);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, AttendanceFilter filter, Color activeColor) {
    final isSelected = _filter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _filter = filter);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor.withValues(alpha: 0.18) : const Color(0xFF11151E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.08),
              width: isSelected ? 1.2 : 0.8,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : AppColors.textSecondary,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberCard(MemberAttendanceStatus item) {
    final m = item.member;
    final isPresent = item.isPresent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xF20F131D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPresent
              ? const Color(0xFF10B981).withValues(alpha: 0.40)
              : Colors.white.withValues(alpha: 0.08),
          width: isPresent ? 1.2 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          if (isPresent)
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          MemberAvatar.fromMember(
            member: m,
            radius: 22,
          ),
          const SizedBox(width: 12),

          // Name and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        m.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      m.memberCode,
                      style: const TextStyle(
                        color: Color(0xFFE8C97A),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),

                Row(
                  children: [
                    Icon(Icons.chair_alt_rounded, size: 12, color: Colors.white.withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    Text(
                      'Seat: ${m.currentSeatNumber ?? 'None'}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 3, height: 3, decoration: const BoxDecoration(color: Colors.white38, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        m.currentPlanName ?? 'Standard',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Status info chip
                if (isPresent)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircleAvatar(radius: 3, backgroundColor: Color(0xFF34D399)),
                            const SizedBox(width: 4),
                            Text(
                              'In: ${DateFormat('hh:mm a').format(item.checkInTime!)}',
                              style: const TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${item.method})',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF43F5E).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFF43F5E).withValues(alpha: 0.35)),
                    ),
                    child: const Text(
                      'ABSENT TODAY',
                      style: TextStyle(
                        color: Color(0xFFF43F5E),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // 1-Tap Action
          if (isPresent)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF10B981),
                size: 18,
              ),
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => _markMemberPresent(m),
              child: const Text(
                'Mark Present',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
