import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/ambient_background.dart';
import '../../../widgets/branch_switcher.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/glass_card.dart';
import '../../branch/providers/branch_provider.dart';
import '../data/payment_repository.dart';
import '../domain/payment_model.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  Future<void> _sendWhatsAppReminder(BuildContext context, Payment payment, String branchName) async {
    HapticFeedback.mediumImpact();
    final phone = (payment.memberPhone ?? '9415919277').replaceAll(RegExp(r'[^\d]'), '');
    final cleanPhone = phone.startsWith('91') ? phone : '91$phone';
    final msg = payment.generateWhatsAppMessage(branchName: branchName);
    final url = 'https://wa.me/$cleanPhone?text=$msg';

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open WhatsApp. Please verify WhatsApp is installed.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching WhatsApp: $e')),
        );
      }
    }
  }

  void _updateStatus(BuildContext context, WidgetRef ref, Payment payment, String status) async {
    HapticFeedback.mediumImpact();
    await ref.read(paymentRepositoryProvider).updateVerificationStatus(payment.id, status);
    ref.invalidate(paymentsListProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: status == 'APPROVED' ? AppColors.emeraldPrimary : AppColors.redPrimary,
          content: Text(
            status == 'APPROVED'
                ? 'Payment for ${payment.memberName ?? "Scholar"} Approved & Verified'
                : 'Payment for ${payment.memberName ?? "Scholar"} Disapproved',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(paymentFilterProvider);
    final paymentsAsync = ref.watch(paymentsListProvider);
    final activeBranch = ref.watch(activeBranchProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientBackground(
          imagePath: 'assets/images/dashboard_bg.png',
          child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header with Branch Switcher & Refresh
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Financial & Payments Tracker',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Atul Residency Ledger Verification',
                          style: TextStyle(
                            color: AppColors.goldPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const BranchSwitcher(),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.add_circle_rounded, color: AppColors.goldPrimary, size: 24),
                      tooltip: 'Record Fee Payment',
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.push(RouteNames.recordPayment);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 22),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ref.invalidate(paymentsListProvider);
                      },
                    ),
                  ],
                ),
              ),

              // Overview Glass Banner (Approved, Pending, Due)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: paymentsAsync.maybeWhen(
                  data: (payments) {
                    final approvedSum = payments.where((p) => p.isApproved).fold<double>(0, (s, p) => s + p.amount);
                    final pendingSum = payments.where((p) => p.isPending).fold<double>(0, (s, p) => s + p.amount);
                    final approvedCount = payments.where((p) => p.isApproved).length;

                    return GlassCard(
                      padding: const EdgeInsets.all(14),
                      borderColor: AppColors.borderGold,
                      glowColor: AppColors.goldPrimary.withValues(alpha: 0.12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFinanceMetric('VERIFIED INFLOW', '₹${approvedSum.toInt()}', AppColors.emeraldPrimary),
                          Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.12)),
                          _buildFinanceMetric('APPROVED TXNS', '$approvedCount', AppColors.goldPrimary),
                          Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.12)),
                          _buildFinanceMetric('PENDING DUES', '₹${pendingSum.toInt()}', AppColors.amberPrimary),
                        ],
                      ),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
              ),

              const SizedBox(height: 10),

              // Filter Chips (All, Approved, Pending, Disapproved)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _FilterBtn(
                        label: 'All Payments',
                        isSelected: filter == 'ALL',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(paymentFilterProvider.notifier).state = 'ALL';
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterBtn(
                        label: 'Approved (Verified)',
                        isSelected: filter == 'APPROVED',
                        color: AppColors.emeraldPrimary,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(paymentFilterProvider.notifier).state = 'APPROVED';
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterBtn(
                        label: 'Pending Verification',
                        isSelected: filter == 'PENDING',
                        color: AppColors.amberPrimary,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(paymentFilterProvider.notifier).state = 'PENDING';
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterBtn(
                        label: 'Disapproved',
                        isSelected: filter == 'DISAPPROVED',
                        color: AppColors.redPrimary,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(paymentFilterProvider.notifier).state = 'DISAPPROVED';
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Payments & Due List
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.goldPrimary,
                  backgroundColor: AppColors.bgCard,
                  onRefresh: () async => ref.invalidate(paymentsListProvider),
                  child: paymentsAsync.when(
                    data: (payments) {
                      if (payments.isEmpty) {
                        return EmptyState(
                          icon: Icons.receipt_long_rounded,
                          title: 'No transactions found',
                          subtitle: 'Recorded payments and student due fees will appear here.',
                          actionLabel: '+ Record Fee Payment',
                          onAction: () => context.push(RouteNames.recordPayment),
                        );
                      }

                      return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 90, top: 4),
                        itemCount: payments.length,
                        itemBuilder: (context, index) {
                          final payment = payments[index];
                          final isApproved = payment.isApproved;
                          final isDisapproved = payment.isDisapproved;
                          final isPending = payment.isPending;

                          Color statusColor = AppColors.emeraldPrimary;
                          String statusText = 'Approved';
                          IconData statusIcon = Icons.check_circle_rounded;

                          if (isPending) {
                            statusColor = AppColors.amberPrimary;
                            statusText = 'Pending Verification';
                            statusIcon = Icons.hourglass_top_rounded;
                          } else if (isDisapproved) {
                            statusColor = AppColors.redPrimary;
                            statusText = 'Disapproved';
                            statusIcon = Icons.cancel_rounded;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: GlassCard(
                              padding: const EdgeInsets.all(14),
                              borderColor: statusColor.withValues(alpha: 0.35),
                              glowColor: statusColor.withValues(alpha: 0.1),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Row: Avatar, Member Info, Amount & Status
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                                        ),
                                        child: Icon(statusIcon, color: statusColor, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              payment.memberName ?? 'Scholar',
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${payment.planName ?? "Scholar Plan"} • ${payment.method}',
                                              style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                                            ),
                                            if (payment.memberCode != null) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                'ID: ${payment.memberCode}',
                                                style: const TextStyle(
                                                  color: AppColors.goldLight,
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '₹${payment.amount.toInt()}',
                                            style: TextStyle(
                                              color: isApproved ? AppColors.goldPrimary : AppColors.amberPrimary,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 17,
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: statusColor.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                                            ),
                                            child: Text(
                                              statusText,
                                              style: TextStyle(
                                                color: statusColor,
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // Divider
                                  Container(height: 1, color: Colors.white.withValues(alpha: 0.07)),

                                  const SizedBox(height: 10),

                                  // Bottom Row: Approve/Disapprove Action Buttons (Atul Residency Style)
                                  Row(
                                    children: [
                                      // Approve Button
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: isApproved
                                              ? null
                                              : () => _updateStatus(context, ref, payment, 'APPROVED'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.emeraldPrimary.withValues(alpha: 0.2),
                                            foregroundColor: const Color(0xFF34D399),
                                            disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                                            disabledForegroundColor: AppColors.textDisabled,
                                            side: BorderSide(
                                              color: isApproved
                                                  ? AppColors.emeraldPrimary
                                                  : AppColors.emeraldPrimary.withValues(alpha: 0.4),
                                            ),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            elevation: 0,
                                          ),
                                          icon: const Icon(Icons.check_rounded, size: 16),
                                          label: Text(
                                            isApproved ? 'Approved ✓' : 'Approve',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Disapprove Button
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: isDisapproved
                                              ? null
                                              : () => _updateStatus(context, ref, payment, 'DISAPPROVED'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.redPrimary.withValues(alpha: 0.2),
                                            foregroundColor: AppColors.redLight,
                                            disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                                            disabledForegroundColor: AppColors.textDisabled,
                                            side: BorderSide(
                                              color: isDisapproved
                                                  ? AppColors.redPrimary
                                                  : AppColors.redPrimary.withValues(alpha: 0.4),
                                            ),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            elevation: 0,
                                          ),
                                          icon: const Icon(Icons.close_rounded, size: 16),
                                          label: Text(
                                            isDisapproved ? 'Rejected ✗' : 'Disapprove',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // WhatsApp Due Notice Button
                                      GestureDetector(
                                        onTap: () => _sendWhatsAppReminder(context, payment, activeBranch.shortName),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF25D366).withValues(alpha: 0.18),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.6)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.chat_bubble_outline_rounded,
                                                  color: Color(0xFF25D366), size: 15),
                                              const SizedBox(width: 4),
                                              Text(
                                                payment.daysOverdue <= 1
                                                    ? 'Day 1'
                                                    : (payment.daysOverdue <= 3 ? 'Day 3!' : (payment.daysOverdue <= 5 ? 'Day 5!!' : '24h Due')),
                                                style: const TextStyle(
                                                  color: Color(0xFF25D366),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.goldPrimary)),
                    error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.accentRed))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textTertiary, fontSize: 9.5, fontWeight: FontWeight.w600, letterSpacing: 0.3),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _FilterBtn extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterBtn({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.goldPrimary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.18) : AppColors.bgGlass,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.borderSubtle,
            width: isSelected ? 1.4 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

