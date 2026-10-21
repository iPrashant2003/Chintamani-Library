import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/member_avatar.dart';
import '../../../widgets/status_chip.dart';
import '../../../widgets/info_row.dart';
import '../../../widgets/glass_button.dart';
import '../data/member_repository.dart';
import '../domain/member_model.dart';
import '../../payments/data/payment_repository.dart';

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

  void _showArchiveDialog(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141A24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Archive Member', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Move ${member.name} (${member.memberCode}) to Archive?\n\n• Any assigned seats and lockers will be released immediately.\n• Historical payments and logs are preserved.\n• The member can be restored at any time from the Archive section.',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.black),
            child: const Text('Archive', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await ref.read(memberRepositoryProvider).archiveMember(member.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'Member archived'), backgroundColor: const Color(0xFFF59E0B)),
                );
                ref.invalidate(memberDetailProvider(widget.memberId));
                ref.invalidate(membersListProvider);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141A24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Restore Member', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Restore ${member.name} (${member.memberCode}) back to the active member directory?',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            child: const Text('Restore', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await ref.read(memberRepositoryProvider).restoreMember(member.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'Member restored'), backgroundColor: const Color(0xFF10B981)),
                );
                ref.invalidate(memberDetailProvider(widget.memberId));
                ref.invalidate(membersListProvider);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showPermanentDeleteDialog(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1014),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFEF4444))),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Permanent Deletion', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'DANGER: Are you sure you want to PERMANENTLY delete ${member.name} (${member.memberCode})?\n\nThis action cannot be undone. All subscriptions, payments, and attendance records associated with this member will be permanently deleted from the database.',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            child: const Text('Delete Permanently', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await ref.read(memberRepositoryProvider).permanentDeleteMember(member.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res['message'] ?? 'Member permanently deleted'), backgroundColor: const Color(0xFFDC2626)),
                );
                ref.invalidate(membersListProvider);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showRecordCashPaymentDialog(BuildContext context, Member member) {
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF141A24),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: Color(0x33FFFFFF))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF065F46),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.payments_rounded, color: Color(0xFF6EE7B7), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Record Cash Payment', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('Member: ${member.name} (${member.memberCode})', style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text('Cash Amount (₹):', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'Enter amount (e.g. 1500)',
                    hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
                    prefixIcon: const Icon(Icons.currency_rupee_rounded, color: Color(0xFF10B981)),
                    filled: true,
                    fillColor: AppColors.bgCard,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),

                const Text('Payment Date:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (picked != null) {
                      setModalState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd MMMM yyyy').format(selectedDate),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.goldPrimary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                const Text('Notes / Remarks (Optional):', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: notesCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'e.g. Handed over at front desk',
                    hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                    filled: true,
                    fillColor: AppColors.bgCard,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final val = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                      if (val <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid cash amount')),
                        );
                        return;
                      }
                      Navigator.pop(ctx);
                      final res = await ref.read(paymentRepositoryProvider).recordCashPayment(
                        memberId: member.id,
                        amount: val,
                        paidAt: selectedDate.toIso8601String(),
                        notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res['message'] ?? 'Cash payment recorded'),
                            backgroundColor: res['success'] == true ? const Color(0xFF059669) : Colors.red,
                          ),
                        );
                        ref.invalidate(memberPaymentHistoryProvider(widget.memberId));
                        ref.invalidate(memberDetailProvider(widget.memberId));
                      }
                    },
                    child: const Text('Save Cash Payment (CASH)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showScreenshotModal(BuildContext context, String url, double amount, String dateStr) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF141A24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Screenshot • ₹${amount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: Image.network(
                  url.startsWith('http') ? url : 'http://localhost:3000$url',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('Unable to load screenshot', style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
          memberAsync.maybeWhen(
            data: (member) => member.isArchived
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.unarchive_rounded, color: Color(0xFF10B981)),
                        tooltip: 'Restore Member',
                        onPressed: () => _showRestoreDialog(context, member),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_forever_rounded, color: Color(0xFFEF4444)),
                        tooltip: 'Permanently Delete',
                        onPressed: () => _showPermanentDeleteDialog(context, member),
                      ),
                    ],
                  )
                : IconButton(
                    icon: const Icon(Icons.archive_outlined, color: Color(0xFFF59E0B)),
                    tooltip: 'Archive Member',
                    onPressed: () => _showArchiveDialog(context, member),
                  ),
            orElse: () => const SizedBox.shrink(),
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

                    // Tab 3: Payments (Real 6-Month Payment History & Cash Recording)
                    Consumer(
                      builder: (ctx, ref, _) {
                        final historyAsync = ref.watch(memberPaymentHistoryProvider(widget.memberId));

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Bar with Record Cash Payment Button
                              Container(
                                padding: const EdgeInsets.all(14),
                                margin: const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.bgCard,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('6-Month Payment History', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 4),
                                        historyAsync.maybeWhen(
                                          data: (d) {
                                            final list = (d['payments'] as List?) ?? [];
                                            final totalPaid = list.fold<double>(0.0, (acc, p) => acc + ((p['amount'] as num?)?.toDouble() ?? 0.0));
                                            return Text(
                                              '₹${totalPaid.toStringAsFixed(0)} Paid (${list.length} Records)',
                                              style: const TextStyle(color: AppColors.statusActive, fontSize: 16, fontWeight: FontWeight.bold),
                                            );
                                          },
                                          orElse: () => const Text('Loading...', style: TextStyle(color: AppColors.textTertiary, fontSize: 14)),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF059669),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      icon: const Icon(Icons.payments_rounded, size: 16, color: Color(0xFFFDE047)),
                                      label: const Text('Record Cash', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      onPressed: () => _showRecordCashPaymentDialog(context, member),
                                    ),
                                  ],
                                ),
                              ),

                              historyAsync.when(
                                loading: () => const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32),
                                    child: CircularProgressIndicator(color: AppColors.goldPrimary),
                                  ),
                                ),
                                error: (err, _) => Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Text('Error loading payments: $err', style: const TextStyle(color: Colors.white70)),
                                  ),
                                ),
                                data: (data) {
                                  final payments = (data['payments'] as List?) ?? [];
                                  if (payments.isEmpty) {
                                    return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(32),
                                      decoration: BoxDecoration(
                                        color: AppColors.bgCard,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                                      ),
                                      child: const Column(
                                        children: [
                                          Icon(Icons.receipt_long_outlined, size: 40, color: AppColors.textTertiary),
                                          SizedBox(height: 10),
                                          Text('No payment records found in the last 6 months', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                        ],
                                      ),
                                    );
                                  }

                                  return Column(
                                    children: payments.map((p) {
                                      final method = (p['method']?.toString() ?? 'UPI').toUpperCase();
                                      final isCash = method == 'CASH';
                                      final status = (p['status']?.toString() ?? 'PAID').toUpperCase();
                                      final amount = (p['amount'] as num?)?.toDouble() ?? 0.0;
                                      final rawDate = p['paidAt'] ?? p['createdAt'];
                                      final dateParsed = rawDate != null ? DateTime.tryParse(rawDate.toString()) : null;
                                      final dateStr = dateParsed != null
                                          ? DateFormat('dd MMM yyyy, hh:mm a').format(dateParsed)
                                          : 'Unknown Date';
                                      final txnRef = p['txnRef']?.toString();
                                      final notes = p['notes']?.toString();
                                      final screenshotUrl = p['screenshotUrl']?.toString();

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: AppColors.bgCard,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: isCash
                                                ? const Color(0xFF10B981).withOpacity(0.4)
                                                : Colors.white.withOpacity(0.08),
                                            width: isCash ? 1.5 : 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    // Explicit Payment Method Badge
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: isCash
                                                            ? const Color(0xFF065F46)
                                                            : const Color(0xFF1E3A8A),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            isCash ? Icons.money_rounded : Icons.qr_code_2_rounded,
                                                            size: 13,
                                                            color: isCash ? const Color(0xFF6EE7B7) : const Color(0xFF93C5FD),
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            isCash ? 'CASH' : method,
                                                            style: TextStyle(
                                                              color: isCash ? const Color(0xFF6EE7B7) : const Color(0xFF93C5FD),
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    // Status Badge
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: status == 'PAID'
                                                            ? const Color(0xFF059669).withOpacity(0.2)
                                                            : (status == 'REJECTED'
                                                                ? const Color(0xFFDC2626).withOpacity(0.2)
                                                                : const Color(0xFFD97706).withOpacity(0.2)),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        status,
                                                        style: TextStyle(
                                                          color: status == 'PAID'
                                                              ? const Color(0xFF10B981)
                                                              : (status == 'REJECTED' ? const Color(0xFFEF4444) : const Color(0xFFF59E0B)),
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  '₹${amount.toStringAsFixed(0)}',
                                                  style: const TextStyle(
                                                    color: AppColors.textPrimary,
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  dateStr,
                                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                                ),
                                                if (txnRef != null && txnRef.isNotEmpty)
                                                  Text(
                                                    'Ref: $txnRef',
                                                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                                                  ),
                                              ],
                                            ),
                                            if (notes != null && notes.isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              Text(
                                                'Note: $notes',
                                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontStyle: FontStyle.italic),
                                              ),
                                            ],
                                            if (screenshotUrl != null && screenshotUrl.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              OutlinedButton.icon(
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: AppColors.goldPrimary,
                                                  side: const BorderSide(color: Color(0x33D4AF37)),
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                ),
                                                icon: const Icon(Icons.image_outlined, size: 14),
                                                label: const Text('View Payment Screenshot', style: TextStyle(fontSize: 11)),
                                                onPressed: () => _showScreenshotModal(context, screenshotUrl, amount, dateStr),
                                              ),
                                            ],
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
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
