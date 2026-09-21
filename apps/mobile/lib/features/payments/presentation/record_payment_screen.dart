import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/glass_text_field.dart';
import '../../../widgets/glass_dropdown.dart';
import '../../../widgets/primary_button.dart';
import '../data/payment_repository.dart';
import '../../branch/providers/branch_provider.dart';

class RecordPaymentScreen extends ConsumerStatefulWidget {
  const RecordPaymentScreen({super.key});

  @override
  ConsumerState<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends ConsumerState<RecordPaymentScreen> {
  final _memberController = TextEditingController();
  final _amountController = TextEditingController();
  final _txnRefController = TextEditingController();
  final _notesController = TextEditingController();
  String _paymentMethod = 'UPI';
  bool _isSaving = false;

  @override
  void dispose() {
    _memberController.dispose();
    _amountController.dispose();
    _txnRefController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _recordPayment() async {
    if (_amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter payment amount')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final branch = ref.read(activeBranchProvider);
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    await ref.read(paymentRepositoryProvider).recordPayment({
      'memberId': _memberController.text.trim().isEmpty ? 'mem-1' : _memberController.text.trim(),
      'branchId': branch.id,
      'amount': amount,
      'method': _paymentMethod,
      'txnRef': _txnRefController.text.trim(),
      'notes': _notesController.text.trim(),
    });

    ref.invalidate(paymentsListProvider);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.statusActive,
          content: Text('Payment of ₹${amount.toInt()} recorded successfully!'),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Record Fee Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.receipt_long, color: AppColors.accentNeon, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Issue library fee receipt and update membership subscription status instantly.',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            GlassTextField(
              controller: _memberController,
              label: 'Member Name or Code *',
              hintText: 'e.g. Aarav Sharma or CML-942810',
              prefixIcon: const Icon(Icons.person_search, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 14),
            GlassTextField(
              controller: _amountController,
              label: 'Amount Collected (₹) *',
              hintText: 'e.g. 600 or 1700',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 14),
            GlassDropdown<String>(
              label: 'Payment Method',
              value: _paymentMethod,
              items: const [
                DropdownMenuItem(value: 'UPI', child: Text('UPI / Google Pay / PhonePe')),
                DropdownMenuItem(value: 'CASH', child: Text('Cash')),
                DropdownMenuItem(value: 'CARD', child: Text('Debit / Credit Card')),
                DropdownMenuItem(value: 'BANK', child: Text('Net Banking / NEFT')),
              ],
              onChanged: (val) => setState(() => _paymentMethod = val ?? 'UPI'),
            ),
            const SizedBox(height: 14),
            GlassTextField(
              controller: _txnRefController,
              label: 'Transaction Reference ID (Optional)',
              hintText: 'e.g. UPI Ref / Cash receipt number',
              prefixIcon: const Icon(Icons.confirmation_number_outlined, color: AppColors.primaryGreen),
            ),
            const SizedBox(height: 14),
            GlassTextField(
              controller: _notesController,
              label: 'Remarks / Notes (Optional)',
              hintText: 'e.g. Discount applied, partial payment balance...',
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Confirm & Generate Receipt',
              isLoading: _isSaving,
              onPressed: _recordPayment,
            ),
          ],
        ),
      ),
    );
  }
}
