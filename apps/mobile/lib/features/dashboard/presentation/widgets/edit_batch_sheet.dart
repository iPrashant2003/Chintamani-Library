import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/batch_timing_service.dart';
import '../../../../theme/app_colors.dart';

class EditBatchSheet extends ConsumerStatefulWidget {
  const EditBatchSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const EditBatchSheet(),
    );
  }

  @override
  ConsumerState<EditBatchSheet> createState() => _EditBatchSheetState();
}

class _EditBatchSheetState extends ConsumerState<EditBatchSheet> {
  void _editBatchDialog(BuildContext context, BatchConfig batch) {
    final nameCtrl = TextEditingController(text: batch.name);
    final timingCtrl = TextEditingController(text: batch.timing);
    final seatsCtrl = TextEditingController(text: batch.totalSeats.toString());
    final priceCtrl = TextEditingController(text: batch.price.toInt().toString());
    bool is24h = batch.is24Hours;

    showDialog(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xF20F1713),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x6600CDB0), width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3300CDB0),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: batch.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Edit Batch Timing',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(nameCtrl, 'Batch Name', 'e.g. 6 Hour Morning'),
                        const SizedBox(height: 10),
                        _buildInputField(timingCtrl, 'Timing Display', 'e.g. 7am – 1pm'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                seatsCtrl,
                                'Seats',
                                '10',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildInputField(
                                priceCtrl,
                                'Fee (₹)',
                                '500',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(
                              value: is24h,
                              activeColor: const Color(0xFF00CDB0),
                              checkColor: Colors.black,
                              onChanged: (val) {
                                setDlgState(() => is24h = val ?? false);
                              },
                            ),
                            const Text(
                              '24 Hours Round-the-Clock',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(dlgCtx),
                              child: const Text('Cancel',
                                  style: TextStyle(color: AppColors.textTertiary)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00CDB0),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                final updated = batch.copyWith(
                                  name: nameCtrl.text.trim().isEmpty
                                      ? batch.name
                                      : nameCtrl.text.trim(),
                                  timing: timingCtrl.text.trim().isEmpty
                                      ? batch.timing
                                      : timingCtrl.text.trim(),
                                  totalSeats: int.tryParse(seatsCtrl.text) ??
                                      batch.totalSeats,
                                  price: double.tryParse(priceCtrl.text) ??
                                      batch.price,
                                  is24Hours: is24h,
                                );
                                ref
                                    .read(batchListProvider.notifier)
                                    .updateBatch(updated);
                                Navigator.pop(dlgCtx);
                                HapticFeedback.mediumImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Updated ${updated.name}!'),
                                    backgroundColor: const Color(0xFF00CDB0),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: const Text('Save Changes',
                                  style: TextStyle(fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _addNewBatchDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final timingCtrl = TextEditingController();
    final seatsCtrl = TextEditingController(text: '10');
    final priceCtrl = TextEditingController(text: '500');
    bool is24h = false;

    showDialog(
      context: context,
      builder: (dlgCtx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xF20F1713),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x6600CDB0), width: 1.2),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add New Batch Timing',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(nameCtrl, 'Batch Name', 'e.g. 8 Hour Special'),
                        const SizedBox(height: 10),
                        _buildInputField(timingCtrl, 'Timing Display', 'e.g. 2pm – 10pm'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                seatsCtrl,
                                'Seats',
                                '10',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildInputField(
                                priceCtrl,
                                'Fee (₹)',
                                '600',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(
                              value: is24h,
                              activeColor: const Color(0xFF00CDB0),
                              checkColor: Colors.black,
                              onChanged: (val) {
                                setDlgState(() => is24h = val ?? false);
                              },
                            ),
                            const Text(
                              '24 Hours Round-the-Clock',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(dlgCtx),
                              child: const Text('Cancel',
                                  style: TextStyle(color: AppColors.textTertiary)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00CDB0),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                if (nameCtrl.text.trim().isEmpty ||
                                    timingCtrl.text.trim().isEmpty) {
                                  return;
                                }
                                final newBatch = BatchConfig(
                                  id: 'b_${DateTime.now().millisecondsSinceEpoch}',
                                  name: nameCtrl.text.trim(),
                                  timing: timingCtrl.text.trim(),
                                  startMinutes: 420,
                                  endMinutes: 780,
                                  totalSeats:
                                      int.tryParse(seatsCtrl.text) ?? 10,
                                  price: double.tryParse(priceCtrl.text) ?? 500,
                                  color: const Color(0xFFF59E0B),
                                  is24Hours: is24h,
                                );
                                ref
                                    .read(batchListProvider.notifier)
                                    .addBatch(newBatch);
                                Navigator.pop(dlgCtx);
                                HapticFeedback.mediumImpact();
                              },
                              child: const Text('Add Batch',
                                  style: TextStyle(fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController ctrl,
    String label,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF93C5FD),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 13,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final batches = ref.watch(batchListProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: Color(0xF50D1117),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(
          top: BorderSide(color: Color(0x6600CDB0), width: 1.5),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),

            // Sheet Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0x2200CDB0),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x4400CDB0)),
                    ),
                    child: const Icon(Icons.tune_rounded,
                        color: Color(0xFF00CDB0), size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Batch Timings & Capacity',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Configure shifts, timing, and seat capacity',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        color: Color(0xFF00CDB0)),
                    tooltip: 'Add Batch',
                    onPressed: () => _addNewBatchDialog(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.restart_alt_rounded,
                        color: AppColors.textTertiary),
                    tooltip: 'Reset to Defaults',
                    onPressed: () async {
                      await ref
                          .read(batchListProvider.notifier)
                          .resetToDefaults();
                      HapticFeedback.lightImpact();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(color: Colors.white10, height: 1),

            // Batches List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: batches.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final b = batches[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: b.color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 38,
                          decoration: BoxDecoration(
                            color: b.color,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: b.color.withValues(alpha: 0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    b.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (b.is24Hours) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0x3310B981),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: const Color(0x8810B981)),
                                      ),
                                      child: const Text(
                                        '24H',
                                        style: TextStyle(
                                          color: Color(0xFF10B981),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${b.timing} • ${b.totalSeats} Seats • ₹${b.price.toInt()}/mo',
                                style: const TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: Color(0xFF00CDB0), size: 20),
                          tooltip: 'Edit Batch',
                          onPressed: () => _editBatchDialog(context, b),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
