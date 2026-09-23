import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../core/api/api_endpoints.dart';
import '../../registrations/data/registration_repository.dart';
import '../../registrations/domain/payment_verification_model.dart';

final selectedVerificationStatusProvider = StateProvider<String>((ref) => 'PENDING');

class PaymentVerificationsScreen extends ConsumerStatefulWidget {
  const PaymentVerificationsScreen({super.key});

  @override
  ConsumerState<PaymentVerificationsScreen> createState() => _PaymentVerificationsScreenState();
}

class _PaymentVerificationsScreenState extends ConsumerState<PaymentVerificationsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return '${ApiEndpoints.baseUrl}$url';
  }

  void _showImageDialog(String title, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              backgroundColor: Colors.black,
              title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            Flexible(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('Failed to load screenshot', style: TextStyle(color: Colors.white70)),
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

  void _showApproveDialog(PaymentVerificationModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF059669), width: 1),
        ),
        title: const Text('Approve Payment', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Text(
          'Confirm verification of ₹${item.amount.toInt()} from ${item.memberName}?\n\n'
          'Payment status will be updated to PAID and member account will be activated/credited.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(registrationRepositoryProvider).approveVerification(item.id);
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment approved successfully')),
                  );
                  ref.invalidate(paymentVerificationsListProvider);
                  ref.invalidate(pendingVerificationsCountProvider);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to approve payment')),
                  );
                }
              }
            },
            child: const Text('Confirm Approval', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(PaymentVerificationModel item) {
    final reasonController = TextEditingController(text: 'Transaction could not be verified');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFDC2626), width: 1),
        ),
        title: const Text('Reject Payment Proof', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter reason for rejecting this payment proof:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Rejection Reason',
                labelStyle: const TextStyle(color: AppColors.textTertiary),
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref
                  .read(registrationRepositoryProvider)
                  .rejectVerification(item.id, reason: reasonController.text.trim());
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment marked as REJECTED')),
                  );
                  ref.invalidate(paymentVerificationsListProvider);
                  ref.invalidate(pendingVerificationsCountProvider);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to reject payment')),
                  );
                }
              }
            },
            child: const Text('Confirm Reject', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(selectedVerificationStatusProvider);
    final listAsync = ref.watch(paymentVerificationsListProvider(status));

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        title: const Text(
          'Payment Verifications',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.goldPrimary),
            onPressed: () {
              ref.invalidate(paymentVerificationsListProvider);
              ref.invalidate(pendingVerificationsCountProvider);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(95),
          child: Column(
            children: [
              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0x22FFFFFF)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'Search by member name, phone, or UTR...',
                      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.goldPrimary, size: 16),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ),

              // Filter Tabs
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                child: Row(
                  children: [
                    _buildTabButton('PENDING', 'Pending Verification', const Color(0xFFD97706)),
                    const SizedBox(width: 8),
                    _buildTabButton('APPROVED', 'Approved', const Color(0xFF059669)),
                    const SizedBox(width: 8),
                    _buildTabButton('REJECTED', 'Rejected', const Color(0xFFDC2626)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: listAsync.when(
        data: (list) {
          final filtered = list.where((v) {
            if (_searchQuery.isEmpty) return true;
            return v.memberName.toLowerCase().contains(_searchQuery) ||
                v.memberPhone.contains(_searchQuery) ||
                (v.txnRef?.toLowerCase().contains(_searchQuery) ?? false);
          }).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 54,
                    color: AppColors.textTertiary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    status == 'PENDING'
                        ? 'No payments awaiting verification'
                        : 'No $status payments found',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(paymentVerificationsListProvider);
            },
            color: AppColors.goldPrimary,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final item = filtered[idx];
                return _buildVerificationCard(item);
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.goldPrimary),
        ),
        error: (err, _) => Center(
          child: Text('Error: $err', style: const TextStyle(color: AppColors.textSecondary)),
        ),
      ),
    );
  }

  Widget _buildTabButton(String tabValue, String label, Color accentColor) {
    final currentStatus = ref.watch(selectedVerificationStatusProvider);
    final isSelected = currentStatus == tabValue;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(selectedVerificationStatusProvider.notifier).state = tabValue;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withOpacity(0.18) : AppColors.bgCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? accentColor : const Color(0x22FFFFFF),
              width: isSelected ? 1.2 : 0.8,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? accentColor : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationCard(PaymentVerificationModel item) {
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(item.submittedAt);
    final screenshot = _formatUrl(item.screenshotUrl);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xF2141A24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x22FFFFFF), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Amount + Type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${item.amount.toInt()}',
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.goldPrimary.withOpacity(0.3)),
                ),
                child: Text(
                  item.paymentType,
                  style: const TextStyle(color: AppColors.goldLight, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Member Info
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                item.memberName,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Text(
                item.memberCode,
                style: const TextStyle(color: AppColors.goldPrimary, fontSize: 11, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Phone & UTR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '+91 ${item.memberPhone}',
                style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
              ),
              if (item.txnRef != null)
                Text(
                  'UTR: ${item.txnRef}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontFamily: 'monospace'),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Screenshot row
          if (screenshot.isNotEmpty)
            GestureDetector(
              onTap: () => _showImageDialog('Payment Screenshot', screenshot),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0x22FFFFFF)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.image_rounded, size: 16, color: AppColors.goldPrimary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'View Uploaded Payment Screenshot',
                        style: TextStyle(color: AppColors.goldLight, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.goldPrimary),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),

          Text(
            'Submitted: $dateStr',
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
          ),

          // Actions if PENDING
          if (item.status == 'PENDING') ...[
            const Divider(color: Color(0x22FFFFFF), height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFDC2626)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () => _showRejectDialog(item),
                    child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () => _showApproveDialog(item),
                    child: const Text('Approve & Credit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
