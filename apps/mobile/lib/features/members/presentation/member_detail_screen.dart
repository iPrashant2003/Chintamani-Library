import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/member_avatar.dart';
import '../../../widgets/status_chip.dart';
import '../../../widgets/info_row.dart';
import '../../../widgets/glass_button.dart';
import '../data/member_repository.dart';

class MemberDetailScreen extends ConsumerStatefulWidget {
  final String memberId;

  const MemberDetailScreen({super.key, required this.memberId});

  @override
  ConsumerState<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends ConsumerState<MemberDetailScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memberAsync = ref.watch(memberDetailProvider(widget.memberId));

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Member Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Member profile link copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: memberAsync.when(
        data: (member) {
          final sub = member.activeSubscription;
          final days = member.daysRemaining;

          return Column(
            children: [
              // Header Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryGreen.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    MemberAvatar.fromMember(
                      member: member,
                      radius: 32,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  member.name,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              StatusChip(status: member.isActive ? 'ACTIVE' : 'EXPIRED'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member.memberCode,
                            style: const TextStyle(
                              color: AppColors.accentNeon,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (member.phone != null)
                            Text(
                              member.phone!,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // TabBar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primaryGreen,
                  indicatorWeight: 3,
                  labelColor: AppColors.accentNeon,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: 'Profile'),
                    Tab(text: 'Plan'),
                    Tab(text: 'Payments'),
                    Tab(text: 'Attendance'),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Profile
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Column(
                          children: [
                            InfoRow(label: 'Full Name', value: member.name, icon: Icons.person_outline),
                            InfoRow(label: 'Father Name', value: member.fatherName ?? 'Not specified', icon: Icons.people_outline),
                            InfoRow(label: 'Gender', value: member.gender ?? 'Not specified', icon: Icons.transgender),
                            InfoRow(
                              label: 'Date of Birth',
                              value: member.dob != null ? DateFormat('dd MMM yyyy').format(member.dob!) : 'Not specified',
                              icon: Icons.cake_outlined,
                            ),
                            InfoRow(label: 'Phone', value: member.phone ?? '—', icon: Icons.phone_outlined),
                            InfoRow(label: 'Email', value: member.email ?? '—', icon: Icons.email_outlined),
                            InfoRow(label: 'Address', value: member.address ?? '—', icon: Icons.location_on_outlined),
                            InfoRow(label: 'Emergency Contact', value: member.emergencyContact ?? '—', icon: Icons.contact_phone_outlined),
                            InfoRow(label: 'Aadhaar / ID', value: member.aadhaar ?? '—', icon: Icons.badge_outlined),
                            InfoRow(label: 'Institute', value: member.institute ?? 'Self Study', icon: Icons.school_outlined),
                            InfoRow(label: 'Course / Target', value: member.course ?? 'General Studies', icon: Icons.menu_book_outlined),
                            InfoRow(label: 'Batch Year', value: member.batch ?? '2024', icon: Icons.calendar_today_outlined),
                          ],
                        ),
                      ),
                    ),

                    // Tab 2: Membership Plan
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.06)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InfoRow(label: 'Active Plan', value: member.currentPlanName, icon: Icons.card_membership),
                            if (sub != null) ...[
                              InfoRow(
                                label: 'Start Date',
                                value: DateFormat('dd MMM yyyy').format(sub.startDate),
                                icon: Icons.play_arrow_outlined,
                              ),
                              InfoRow(
                                label: 'Expiry Date',
                                value: DateFormat('dd MMM yyyy').format(sub.endDate),
                                icon: Icons.stop_outlined,
                                valueColor: days != null && days <= 3 ? AppColors.statusExpired : null,
                              ),
                              InfoRow(
                                label: 'Days Left',
                                value: days != null ? '$days days' : 'N/A',
                                icon: Icons.hourglass_bottom,
                                valueColor: AppColors.accentNeon,
                              ),
                            ],
                            InfoRow(
                              label: 'Assigned Seat',
                              value: member.currentSeatNumber != null ? 'Seat ${member.currentSeatNumber}' : 'Not assigned',
                              icon: Icons.chair_alt,
                            ),
                            InfoRow(
                              label: 'Assigned Locker',
                              value: member.currentLockerNumber != null ? 'Locker ${member.currentLockerNumber}' : 'None',
                              icon: Icons.lock_outline,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: GlassButton(
                                    label: 'Renew Subscription',
                                    icon: Icons.refresh,
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Renewal workflow triggered')),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tab 3: Payments
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total Fees Paid', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    SizedBox(height: 2),
                                    Text('₹1,700', style: TextStyle(color: AppColors.statusActive, fontSize: 18, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Pending Due', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    SizedBox(height: 2),
                                    Text('₹0', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _PaymentTile(amount: '₹1,700', method: 'UPI', date: '10 Aug 2026', txnRef: 'UPI-942810', status: 'PAID'),
                          _PaymentTile(amount: '₹600', method: 'CASH', date: '10 May 2026', txnRef: 'CASH-REC-012', status: 'PAID'),
                        ],
                      ),
                    ),

                    // Tab 4: Attendance
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text('Days Present', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    SizedBox(height: 4),
                                    Text('21', style: TextStyle(color: AppColors.statusActive, fontSize: 20, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('Days Absent', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    SizedBox(height: 4),
                                    Text('4', style: TextStyle(color: AppColors.statusExpired, fontSize: 20, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('Attendance %', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    SizedBox(height: 4),
                                    Text('84%', style: TextStyle(color: AppColors.accentNeon, fontSize: 20, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _AttendanceTile(date: 'Today, 09 Sep', inTime: '07:30 AM', outTime: 'Active Session', method: 'QR'),
                          _AttendanceTile(date: '08 Sep 2026', inTime: '07:45 AM', outTime: '04:15 PM', method: 'QR'),
                          _AttendanceTile(date: '07 Sep 2026', inTime: '08:00 AM', outTime: '02:30 PM', method: 'MANUAL'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
        error: (e, _) => Center(child: Text('Error loading member: $e', style: const TextStyle(color: AppColors.statusExpired))),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final String amount;
  final String method;
  final String date;
  final String txnRef;
  final String status;

  const _PaymentTile({
    required this.amount,
    required this.method,
    required this.date,
    required this.txnRef,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long, color: AppColors.accentNeon, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(amount, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                Text('$method • Txn: $txnRef', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(status, style: const TextStyle(color: AppColors.statusActive, fontSize: 11, fontWeight: FontWeight.bold)),
              Text(date, style: const TextStyle(color: AppColors.textDisabled, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  final String date;
  final String inTime;
  final String outTime;
  final String method;

  const _AttendanceTile({
    required this.date,
    required this.inTime,
    required this.outTime,
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryTeal.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.fingerprint, color: AppColors.accentNeon, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                Text('In: $inTime  •  Out: $outTime', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(method, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
