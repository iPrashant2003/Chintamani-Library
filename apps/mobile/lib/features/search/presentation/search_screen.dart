import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/paginated_response.dart';
import '../../../core/services/database_backup_service.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/search_bar_widget.dart';
import '../../branch/providers/branch_provider.dart';
import '../../lockers/data/locker_repository.dart';
import '../../lockers/domain/locker_model.dart';
import '../../members/data/member_repository.dart';
import '../../members/domain/member_model.dart';
import '../../seats/data/seat_repository.dart';
import '../../seats/domain/seat_model.dart';

class _AppFeatureItem {
  final String title;
  final String subtitle;
  final String keywords;
  final String route;
  final IconData icon;
  final Color color;

  const _AppFeatureItem({
    required this.title,
    required this.subtitle,
    required this.keywords,
    required this.route,
    required this.icon,
    required this.color,
  });
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  static const List<_AppFeatureItem> _appFeatures = [
    _AppFeatureItem(
      title: 'Members Directory',
      subtitle: 'View all scholars, attendance, and member cards',
      keywords: 'members scholar scholars student students list profile directory active cards',
      route: RouteNames.members,
      icon: Icons.people_alt_rounded,
      color: Color(0xFF00E5BC),
    ),
    _AppFeatureItem(
      title: 'Add New Member',
      subtitle: 'Register scholar with seat, plan, and locker',
      keywords: 'add new member register registration student scholar admission',
      route: RouteNames.addMember,
      icon: Icons.person_add_alt_1_rounded,
      color: Color(0xFF10B981),
    ),
    _AppFeatureItem(
      title: 'Single Hall Seats',
      subtitle: '72 seats (Khalilabad) • 65 seats (Mehdawal)',
      keywords: 'seats seat hall layout chair allocation single k01 k72 m01 m65 desk table',
      route: RouteNames.seats,
      icon: Icons.event_seat_rounded,
      color: Color(0xFF6366F1),
    ),
    _AppFeatureItem(
      title: '9 Lockers Facility',
      subtitle: '9 personal secure storage units (L01–L09) • ₹200/mo',
      keywords: 'lockers locker storage l01 l09 9 lockers secure unit box cabinet',
      route: RouteNames.lockers,
      icon: Icons.lock_rounded,
      color: Color(0xFFF59E0B),
    ),
    _AppFeatureItem(
      title: 'Due Payments & Fees',
      subtitle: 'Track expiring plans, pending dues, and send WhatsApp reminder',
      keywords: 'due dues pending fees fee payment payments expire expiry unpaid collect overdue',
      route: RouteNames.duePayments,
      icon: Icons.receipt_long_rounded,
      color: Color(0xFFEF4444),
    ),
    _AppFeatureItem(
      title: 'Payments & Receipts',
      subtitle: 'All online and offline transaction history',
      keywords: 'payments receipts transactions paid billing money cash upi history fee',
      route: RouteNames.payments,
      icon: Icons.payments_rounded,
      color: Color(0xFF10B981),
    ),
    _AppFeatureItem(
      title: 'Record Offline / Cash Fee',
      subtitle: 'Instant cash receipt creation and member plan renewal',
      keywords: 'record fee cash payment entry receipt renew money offline manual',
      route: RouteNames.recordPayment,
      icon: Icons.add_card_rounded,
      color: Color(0xFF3B82F6),
    ),
    _AppFeatureItem(
      title: 'Universal 4D Member Portal QR',
      subtitle: 'Official scholar portal and self-attendance QR scanner',
      keywords: 'universal qr portal hub 4d self attendance member scan scanner website link',
      route: RouteNames.universalQr,
      icon: Icons.qr_code_scanner_rounded,
      color: Color(0xFFD4AF37),
    ),
    _AppFeatureItem(
      title: 'Attendance Scanner & Biometrics',
      subtitle: 'Fast QR check-in & biometric attendance management',
      keywords: 'attendance check in check out biometric entry exit punch time scan',
      route: RouteNames.attendance,
      icon: Icons.how_to_reg_rounded,
      color: Color(0xFF06B6D4),
    ),
    _AppFeatureItem(
      title: 'Daily Attendance Checker',
      subtitle: 'Daily scholar presence logs & audit reports',
      keywords: 'checker attendance daily logs present absent report verification',
      route: RouteNames.attendanceChecker,
      icon: Icons.fact_check_rounded,
      color: Color(0xFF8B5CF6),
    ),
    _AppFeatureItem(
      title: 'Database Backup & Cloud Export',
      subtitle: 'One-tap snapshot & WhatsApp share for Manglesh Mani Tripathi',
      keywords: 'database backup export snapshot restore json safe manglesh 9415919277',
      route: RouteNames.databaseBackup,
      icon: Icons.backup_rounded,
      color: Color(0xFF10B981),
    ),
    _AppFeatureItem(
      title: 'Online Registrations',
      subtitle: 'Review incoming admission applications from public portal',
      keywords: 'registrations registration online admission join apply requests leads',
      route: RouteNames.registrations,
      icon: Icons.app_registration_rounded,
      color: Color(0xFFF97316),
    ),
    _AppFeatureItem(
      title: 'Complaints & Member Feedback',
      subtitle: 'Resolve air conditioning, Wi-Fi, and desk issues',
      keywords: 'complaints complaint issue feedback ticket grievance support repair ac wifi',
      route: RouteNames.complaints,
      icon: Icons.feedback_rounded,
      color: Color(0xFFEC4899),
    ),
    _AppFeatureItem(
      title: 'Financial Reports & Analytics',
      subtitle: 'Monthly revenue, occupancy rates, and member growth',
      keywords: 'reports revenue finance financial analytics statistics charts growth profit',
      route: RouteNames.reports,
      icon: Icons.bar_chart_rounded,
      color: Color(0xFF6366F1),
    ),
    _AppFeatureItem(
      title: 'Branch Comparison',
      subtitle: 'Compare Khalilabad vs Mehdawal metrics and occupancy',
      keywords: 'branch comparison compare khalilabad mehdawal performance stats metrics',
      route: RouteNames.branchComparison,
      icon: Icons.compare_arrows_rounded,
      color: Color(0xFF00E5BC),
    ),
    _AppFeatureItem(
      title: 'Helpline & Director Hotline',
      subtitle: 'Contact Director Manglesh Mani Tripathi (+91 9415919277)',
      keywords: 'contact director helpline hotline manglesh 9415919277 phone call whatsapp support',
      route: RouteNames.contact,
      icon: Icons.phone_in_talk_rounded,
      color: Color(0xFFD4AF37),
    ),
    _AppFeatureItem(
      title: 'Change App Password',
      subtitle: 'Update admin password with authoritative cloud sync',
      keywords: 'password change pin lock security admin credentials update',
      route: RouteNames.changePassword,
      icon: Icons.password_rounded,
      color: Color(0xFFEF4444),
    ),
    _AppFeatureItem(
      title: 'Check App Updates',
      subtitle: 'In-app 1-tap APK updater for newest library release',
      keywords: 'update app updates release version apk download install latest patch',
      route: RouteNames.appUpdates,
      icon: Icons.system_update_rounded,
      color: Color(0xFF10B981),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    setState(() {
      _query = query.trim().toLowerCase();
    });
  }

  void _applyQuickSuggestion(String term) {
    HapticFeedback.lightImpact();
    _searchController.text = term;
    _onQueryChanged(term);
  }

  @override
  Widget build(BuildContext context) {
    final activeBranch = ref.watch(activeBranchProvider);
    final membersAsync = ref.watch(membersListProvider);
    final seatsAsync = ref.watch(seatsListProvider);
    final lockersAsync = ref.watch(lockersListProvider);

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
              hintText: 'Search members, seats, lockers, dues, or screens...',
              onChanged: _onQueryChanged,
              onClear: () => _onQueryChanged(''),
            ),
          ),

          // Main body content
          Expanded(
            child: _query.isEmpty
                ? _buildEmptyState(activeBranch.shortName)
                : _buildSearchResults(
                    context,
                    membersAsync: membersAsync,
                    seatsAsync: seatsAsync,
                    lockersAsync: lockersAsync,
                    branchShortName: activeBranch.shortName,
                  ),
          ),
        ],
      ),
    );
  }

  /// Empty state: displays quick suggestions and popular tools
  Widget _buildEmptyState(String branchName) {
    final quickChips = [
      'Due Payments',
      'Lockers',
      'Seats',
      'Universal QR',
      'Database Backup',
      'Add Member',
      'Helpline: 9415919277',
      'Khalilabad',
      'Mehdawal',
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      physics: const BouncingScrollPhysics(),
      children: [
        // Header
        Row(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Color(0xFFD4AF37), size: 18),
            const SizedBox(width: 8),
            Text(
              'Quick Search in $branchName',
              style: const TextStyle(
                color: Color(0xFFE5E7EB),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Quick Search Chips
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

        const SizedBox(height: 24),

        // Popular Tools Section
        const Row(
          children: [
            Icon(Icons.apps_rounded, color: Color(0xFF00E5BC), size: 18),
            SizedBox(width: 8),
            Text(
              'Core Library Services',
              style: TextStyle(
                color: Color(0xFFE5E7EB),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ..._appFeatures.take(6).map((feat) => _buildFeatureTile(context, feat)),
      ],
    );
  }

  /// Search Results: categorized by App Features, Members, Seats, Lockers
  Widget _buildSearchResults(
    BuildContext context, {
    required AsyncValue<PaginatedResponse<Member>> membersAsync,
    required AsyncValue<List<Seat>> seatsAsync,
    required AsyncValue<List<Locker>> lockersAsync,
    required String branchShortName,
  }) {
    // 1. Matched App Features
    final matchedFeatures = _appFeatures.where((f) {
      return f.title.toLowerCase().contains(_query) ||
          f.subtitle.toLowerCase().contains(_query) ||
          f.keywords.toLowerCase().contains(_query);
    }).toList();

    // 2. Matched Members
    final allMembers = membersAsync.value?.data ?? [];
    final matchedMembers = allMembers.where((m) {
      final name = m.name.toLowerCase();
      final code = m.memberCode.toLowerCase();
      final phone = (m.phone ?? '').toLowerCase();
      final seat = (m.currentSeatNumber ?? '').toLowerCase();
      return name.contains(_query) ||
          code.contains(_query) ||
          phone.contains(_query) ||
          seat.contains(_query);
    }).toList();

    // 3. Matched Seats
    final allSeats = seatsAsync.value ?? [];
    final matchedSeats = allSeats.where((s) {
      final sNum = s.seatNumber.toLowerCase();
      final sFloor = (s.floor ?? '').toLowerCase();
      final sStatus = s.status.toLowerCase();
      return sNum.contains(_query) ||
          sFloor.contains(_query) ||
          sStatus.contains(_query) ||
          'seats'.contains(_query);
    }).toList();

    // 4. Matched Lockers (9 Lockers strictly)
    final allLockers = lockersAsync.value ?? [];
    final matchedLockers = allLockers.where((l) {
      final lNum = l.lockerNumber.toLowerCase();
      final lStatus = l.status.toLowerCase();
      return lNum.contains(_query) ||
          lStatus.contains(_query) ||
          'lockers'.contains(_query) ||
          'locker'.contains(_query);
    }).toList();

    final totalMatches = matchedFeatures.length +
        matchedMembers.length +
        matchedSeats.length +
        matchedLockers.length;

    if (totalMatches == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF16151D),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFFD4AF37)),
              ),
              const SizedBox(height: 16),
              Text(
                'No results found for "$_query"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFE5E7EB),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Try searching for "Member", "Due", "K01", "M01", "L01", or "QR"',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
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
        // ── Matched App Navigation & Services ──
        if (matchedFeatures.isNotEmpty) ...[
          _buildCategoryHeader('Services & Navigation', matchedFeatures.length, const Color(0xFF00E5BC)),
          const SizedBox(height: 8),
          ...matchedFeatures.map((feat) => _buildFeatureTile(context, feat)),
          const SizedBox(height: 18),
        ],

        // ── Matched Members ──
        if (matchedMembers.isNotEmpty) ...[
          _buildCategoryHeader('Members & Scholars', matchedMembers.length, const Color(0xFF10B981)),
          const SizedBox(height: 8),
          ...matchedMembers.map((member) => _buildMemberTile(context, member)),
          const SizedBox(height: 18),
        ],

        // ── Matched Seats ──
        if (matchedSeats.isNotEmpty) ...[
          _buildCategoryHeader('Single Hall Seats ($branchShortName)', matchedSeats.length, const Color(0xFF6366F1)),
          const SizedBox(height: 8),
          ...matchedSeats.take(15).map((seat) => _buildSeatTile(context, seat)),
          const SizedBox(height: 18),
        ],

        // ── Matched Lockers (9 Lockers strictly) ──
        if (matchedLockers.isNotEmpty) ...[
          _buildCategoryHeader('Lockers ($branchShortName)', matchedLockers.length, const Color(0xFFF59E0B)),
          const SizedBox(height: 8),
          ...matchedLockers.map((locker) => _buildLockerTile(context, locker)),
          const SizedBox(height: 18),
        ],
      ],
    );
  }

  Widget _buildCategoryHeader(String title, int count, Color accentColor) {
    return Row(
      children: [
        Container(
          width: 3.5,
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
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            '$count',
            style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureTile(BuildContext context, _AppFeatureItem feat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF121118),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: feat.color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: feat.color.withValues(alpha: 0.3)),
          ),
          child: Icon(feat.icon, color: feat.color, size: 20),
        ),
        title: Text(
          feat.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          feat.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.goldPrimary, size: 14),
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(feat.route);
        },
      ),
    );
  }

  Widget _buildMemberTile(BuildContext context, Member member) {
    final statusColor = member.isActive ? const Color(0xFF10B981) : const Color(0xFFDC2626);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF121118),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.16),
          child: Text(
            member.name.isNotEmpty ? member.name[0].toUpperCase() : 'M',
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                member.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                member.isActive ? 'ACTIVE' : 'EXPIRED',
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${member.memberCode}${member.phone != null && member.phone!.isNotEmpty ? " • ${member.phone}" : ""}${member.currentSeatNumber != null ? " • Seat ${member.currentSeatNumber}" : ""}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.goldPrimary, size: 18),
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(RouteNames.memberDetail.replaceFirst(':id', member.id));
        },
      ),
    );
  }

  Widget _buildSeatTile(BuildContext context, Seat seat) {
    final isOccupied = seat.isOccupied;
    final color = isOccupied ? const Color(0xFF8B5CF6) : const Color(0xFF10B981);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF121118),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(Icons.event_seat_rounded, color: color, size: 18),
        ),
        title: Text(
          'Seat ${seat.seatNumber}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          'Single Hall • ${seat.status}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.goldPrimary, size: 13),
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(RouteNames.seats);
        },
      ),
    );
  }

  Widget _buildLockerTile(BuildContext context, Locker locker) {
    final isOccupied = locker.isOccupied;
    final color = isOccupied ? const Color(0xFF8B5CF6) : const Color(0xFF10B981);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF121118),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(Icons.lock_rounded, color: color, size: 18),
        ),
        title: Text(
          'Locker ${locker.lockerNumber}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          'Personal Secure Unit • ₹200/mo • ${locker.status}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.goldPrimary, size: 13),
        onTap: () {
          HapticFeedback.lightImpact();
          context.push(RouteNames.lockers);
        },
      ),
    );
  }
}
