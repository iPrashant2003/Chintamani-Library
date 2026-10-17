import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/search_bar_widget.dart';
import '../../branch/providers/branch_provider.dart';
import '../data/search_repository.dart';
import '../domain/search_result_model.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _query = '';
  bool _isLoading = false;
  String? _errorMessage;
  SearchResultGroup? _results;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      setState(() {
        _query = '';
        _isLoading = false;
        _errorMessage = null;
        _results = null;
      });
      return;
    }

    setState(() {
      _query = trimmed;
      _isLoading = true;
      _errorMessage = null;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _executeSearch(trimmed);
    });
  }

  Future<void> _executeSearch(String query) async {
    final activeBranch = ref.read(activeBranchProvider);
    final repo = ref.read(searchRepositoryProvider);

    try {
      final res = await repo.search(query, branchId: activeBranch.id);
      if (mounted && _query == query) {
        setState(() {
          _results = res;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted && _query == query) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to complete search. Please check your network connection.';
        });
      }
    }
  }

  void _applyQuickSuggestion(String term) {
    HapticFeedback.lightImpact();
    _searchController.text = term;
    _onQueryChanged(term);
  }

  @override
  Widget build(BuildContext context) {
    final activeBranch = ref.watch(activeBranchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF070709),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0E12),
        elevation: 0,
        title: const Text(
          'Global Library Search',
          style: TextStyle(
            color: Color(0xFFF3E5AB),
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFD4AF37), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Search input field
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0E0E12),
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
            ),
            child: SearchBarWidget(
              controller: _searchController,
              hintText: 'Search scholars, seats, lockers, complaints, admissions...',
              onChanged: _onQueryChanged,
              onClear: () => _onQueryChanged(''),
            ),
          ),

          // Main body content
          Expanded(
            child: _buildBody(activeBranch.shortName),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(String branchName) {
    if (_query.isEmpty) {
      return _buildEmptyState(branchName);
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2.5),
            SizedBox(height: 14),
            Text(
              'Searching library records...',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, color: Color(0xFFEF4444), size: 44),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16151D),
                  side: const BorderSide(color: Color(0xFFD4AF37)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFFD4AF37), size: 18),
                label: const Text('Retry Search', style: TextStyle(color: Color(0xFFF3E5AB))),
                onPressed: () => _executeSearch(_query),
              ),
            ],
          ),
        ),
      );
    }

    final results = _results;
    if (results == null || results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF141218),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: const Icon(Icons.search_off_rounded, size: 42, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 16),
              Text(
                'No matching records found for "$_query"',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFE5E7EB), fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Verify the scholar name, mobile number, seat number, or locker identifier and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      physics: const BouncingScrollPhysics(),
      children: [
        // Summary header
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '${results.totalCount} authoritative result${results.totalCount == 1 ? '' : 's'} in $branchName',
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),

        // 1. Members
        if (results.members.isNotEmpty) ...[
          _buildSectionHeader('Scholars & Members', results.members.length, Icons.people_alt_rounded, const Color(0xFF00E5BC)),
          ...results.members.map((m) => _buildMemberTile(m)),
          const SizedBox(height: 14),
        ],

        // 2. Lockers (authoritative strictly 9 lockers)
        if (results.lockers.isNotEmpty) ...[
          _buildSectionHeader('9 Locker Vault', results.lockers.length, Icons.lock_rounded, const Color(0xFF8B5CF6)),
          ...results.lockers.map((l) => _buildLockerTile(l)),
          const SizedBox(height: 14),
        ],

        // 3. Seats
        if (results.seats.isNotEmpty) ...[
          _buildSectionHeader('Single Hall Seats', results.seats.length, Icons.event_seat_rounded, const Color(0xFF3B82F6)),
          ...results.seats.map((s) => _buildSeatTile(s)),
          const SizedBox(height: 14),
        ],

        // 4. Complaints
        if (results.complaints.isNotEmpty) ...[
          _buildSectionHeader('Complaints & Grievances', results.complaints.length, Icons.feedback_rounded, const Color(0xFFEC4899)),
          ...results.complaints.map((c) => _buildComplaintTile(c)),
          const SizedBox(height: 14),
        ],

        // 5. Registrations
        if (results.registrations.isNotEmpty) ...[
          _buildSectionHeader('Online Registrations', results.registrations.length, Icons.app_registration_rounded, const Color(0xFFF97316)),
          ...results.registrations.map((r) => _buildRegistrationTile(r)),
          const SizedBox(height: 14),
        ],

        // 6. Notifications
        if (results.notifications.isNotEmpty) ...[
          _buildSectionHeader('Authoritative Broadcasts', results.notifications.length, Icons.campaign_rounded, const Color(0xFFD4AF37)),
          ...results.notifications.map((n) => _buildNotificationTile(n)),
          const SizedBox(height: 14),
        ],
      ],
    );
  }

  Widget _buildEmptyState(String branchName) {
    final quickChips = [
      'Scholar Profiles',
      'Seats: K01–K72',
      'Seats: M01–M65',
      'Lockers: L01–L09',
      'Pending Dues',
      'Online Admissions',
      'Director: 9415919277',
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          children: [
            const Icon(Icons.search_rounded, color: Color(0xFFD4AF37), size: 20),
            const SizedBox(width: 8),
            Text(
              'Search Entities in $branchName',
              style: const TextStyle(
                color: Color(0xFFE5E7EB),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickChips.map((chip) {
            return ActionChip(
              backgroundColor: const Color(0xFF16151D),
              side: BorderSide(color: const Color(0xFFD4AF37).withValues(alpha: 0.28)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              label: Text(
                chip,
                style: const TextStyle(
                  color: Color(0xFFFDE68A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => _applyQuickSuggestion(chip),
            );
          }).toList(),
        ),

        const SizedBox(height: 28),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF121118),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Comprehensive Entity Search',
                style: TextStyle(
                  color: Color(0xFFF3E5AB),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Search across active scholars, hall seat allocations, secure locker assignments, student grievances, and admission leads. Results are authoritative and isolated per branch.',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFE5E7EB),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(SearchMemberItem m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF121118),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF00E5BC).withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00E5BC).withValues(alpha: 0.3)),
          ),
          child: const Center(
            child: Icon(Icons.person_rounded, color: Color(0xFF00E5BC), size: 20),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                m.name,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0x2200E5BC),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                m.memberCode,
                style: const TextStyle(color: Color(0xFF00E5BC), fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${m.phone ?? 'No Phone'} • ${m.seatNumber != null ? 'Seat ${m.seatNumber}' : 'No Seat'} • ${m.planName ?? 'General Plan'}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textTertiary, size: 14),
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(RouteNames.members);
        },
      ),
    );
  }

  Widget _buildLockerTile(SearchLockerItem l) {
    final isAssigned = l.isAssigned;
    final color = isAssigned ? AppColors.accentPurple : AppColors.primaryGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF121118),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Icon(Icons.lock_rounded, color: color, size: 20),
          ),
        ),
        title: Text(
          'Locker ${l.lockerNumber}',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isAssigned
              ? 'Assigned to ${l.currentMemberName}'
              : 'Unassigned • Ready for allocation',
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Text(
            isAssigned ? 'ASSIGNED' : 'UNASSIGNED',
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(RouteNames.lockers);
        },
      ),
    );
  }

  Widget _buildSeatTile(SearchSeatItem s) {
    final isAvailable = s.isAvailable;
    final color = isAvailable ? AppColors.primaryGreen : AppColors.accentPurple;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF121118),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Icon(Icons.event_seat_rounded, color: color, size: 20),
          ),
        ),
        title: Text(
          'Seat ${s.seatNumber}',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${s.floor} • ${isAvailable ? 'Available' : 'Occupied'}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textTertiary, size: 14),
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(RouteNames.seats);
        },
      ),
    );
  }

  Widget _buildComplaintTile(SearchComplaintItem c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF121118),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFEC4899).withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFEC4899).withValues(alpha: 0.3)),
          ),
          child: const Center(
            child: Icon(Icons.feedback_rounded, color: Color(0xFFEC4899), size: 20),
          ),
        ),
        title: Text(
          '${c.complaintId} • ${c.category}',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${c.memberName}: ${c.description}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textTertiary, size: 14),
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(RouteNames.complaints);
        },
      ),
    );
  }

  Widget _buildRegistrationTile(SearchRegistrationItem r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF121118),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF97316).withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.3)),
          ),
          child: const Center(
            child: Icon(Icons.app_registration_rounded, color: Color(0xFFF97316), size: 20),
          ),
        ),
        title: Text(
          '${r.name} (${r.applicationId})',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          r.phone,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textTertiary, size: 14),
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(RouteNames.registrations);
        },
      ),
    );
  }

  Widget _buildNotificationTile(SearchNotificationItem n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF121118),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
          ),
          child: const Center(
            child: Icon(Icons.notifications_active_rounded, color: Color(0xFFD4AF37), size: 20),
          ),
        ),
        title: Text(
          n.title,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          n.body,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textTertiary, size: 14),
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(RouteNames.notifications);
        },
      ),
    );
  }
}
