import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../core/api/api_endpoints.dart';
import '../data/complaint_repository.dart';
import '../domain/complaint_model.dart';

class ComplaintDetailScreen extends ConsumerStatefulWidget {
  final String complaintId;

  const ComplaintDetailScreen({super.key, required this.complaintId});

  @override
  ConsumerState<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends ConsumerState<ComplaintDetailScreen> {
  bool _isLoading = true;
  bool _isProcessing = false;
  ComplaintModel? _complaint;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final data = await ref.read(complaintRepositoryProvider).getComplaintDetail(widget.complaintId);
    if (mounted) {
      setState(() {
        _complaint = data;
        _isLoading = false;
      });
    }
  }

  String _formatUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return '${ApiEndpoints.baseUrl}$url';
  }

  void _showAssignDialog() {
    final assignController = TextEditingController(text: _complaint?.assignedTo ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD97706), width: 1),
        ),
        title: const Text('Assign Staff Member', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: assignController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            labelText: 'Staff Name / Technician',
            labelStyle: const TextStyle(color: AppColors.textTertiary),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final name = assignController.text.trim();
              if (name.isNotEmpty) {
                setState(() => _isProcessing = true);
                await ref.read(complaintRepositoryProvider).updateStatus(
                  widget.complaintId,
                  'IN_PROGRESS',
                  assignedTo: name,
                );
                setState(() => _isProcessing = false);
                _load();
              }
            },
            child: const Text('Assign & Set In-Progress', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showUpdateComplaintDialog() {
    if (_complaint == null) return;
    final c = _complaint!;

    String selectedStatus = c.status;
    final resolutionController = TextEditingController(text: c.resolution ?? '');
    final internalNotesController = TextEditingController(text: c.internalNotes ?? '');
    final assignController = TextEditingController(text: c.assignedTo ?? '');

    final availableStatuses = [
      {'code': 'SUBMITTED', 'label': 'Submitted', 'color': const Color(0xFF6B7280)},
      {'code': 'UNDER_REVIEW', 'label': 'Under Review', 'color': const Color(0xFF3B82F6)},
      {'code': 'IN_PROGRESS', 'label': 'In Progress', 'color': const Color(0xFFD97706)},
      {'code': 'RESOLVED', 'label': 'Resolved', 'color': const Color(0xFF059669)},
      {'code': 'REJECTED', 'label': 'Rejected', 'color': const Color(0xFFDC2626)},
      {'code': 'REOPENED', 'label': 'Reopened', 'color': const Color(0xFFEC4899)},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final isResolved = selectedStatus == 'RESOLVED';

          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF141A24),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: Color(0x33FFFFFF), width: 1)),
            ),
            child: SingleChildScrollView(
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
                              color: AppColors.purpleDeep.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.edit_note_rounded, color: AppColors.purpleLight, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Update Complaint', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              Text('ID: ${c.complaintId} • ${c.category}', style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
                        onPressed: () => Navigator.pop(modalCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text('Select New Status:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableStatuses.map((st) {
                      final isSel = selectedStatus == st['code'];
                      final color = st['color'] as Color;

                      return GestureDetector(
                        onTap: () => setModalState(() => selectedStatus = st['code'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSel ? color.withOpacity(0.2) : Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSel ? color : const Color(0x22FFFFFF),
                              width: isSel ? 1.4 : 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSel) ...[
                                Icon(Icons.check_circle_rounded, size: 14, color: color),
                                const SizedBox(width: 5),
                              ],
                              Text(
                                st['label'] as String,
                                style: TextStyle(
                                  color: isSel ? color : AppColors.textSecondary,
                                  fontSize: 11.5,
                                  fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  if (isResolved)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF059669).withOpacity(0.35)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.mark_chat_read_rounded, color: Color(0xFF34D399), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'WhatsApp notification will be sent automatically to +91 ${c.memberPhone} upon resolution.',
                              style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Text('Resolution Message (Visible to Member):', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: resolutionController,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                    decoration: InputDecoration(
                      hintText: 'e.g. Issue resolved. Technician cleaned AC filters at 3 PM.',
                      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.35),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0x22FFFFFF))),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('Internal Admin Note (Admin only):', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: internalNotesController,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                    decoration: InputDecoration(
                      hintText: 'Optional internal staff notes or vendor details...',
                      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.35),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0x22FFFFFF))),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text('Assigned Staff / Technician:', style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: assignController,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                    decoration: InputDecoration(
                      hintText: 'Staff Name',
                      hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.35),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0x22FFFFFF))),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        Navigator.pop(modalCtx);
                        setState(() => _isProcessing = true);
                        try {
                          final success = await ref.read(complaintRepositoryProvider).updateStatus(
                            widget.complaintId,
                            selectedStatus,
                            resolution: resolutionController.text.trim().isNotEmpty ? resolutionController.text.trim() : null,
                            internalNotes: internalNotesController.text.trim().isNotEmpty ? internalNotesController.text.trim() : null,
                            assignedTo: assignController.text.trim().isNotEmpty ? assignController.text.trim() : null,
                          );

                          if (mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '✓ Complaint updated to $selectedStatus${selectedStatus == 'RESOLVED' ? ' • WhatsApp message dispatched' : ''}',
                                  ),
                                ),
                              );
                              ref.invalidate(complaintsListProvider);
                              ref.invalidate(openComplaintsCountProvider);
                              _load();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to update complaint status')),
                              );
                            }
                          }
                        } finally {
                          if (mounted) setState(() => _isProcessing = false);
                        }
                      },
                      child: const Text('Save & Update Complaint', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Center(child: CircularProgressIndicator(color: AppColors.purpleLight)),
      );
    }

    if (_complaint == null) {
      return Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(backgroundColor: AppColors.bgDark, elevation: 0),
        body: const Center(child: Text('Complaint not found', style: TextStyle(color: AppColors.textSecondary))),
      );
    }

    final c = _complaint!;
    Color statusColor = const Color(0xFFDC2626);
    if (c.status == 'IN_PROGRESS') statusColor = const Color(0xFFD97706);
    if (c.status == 'UNDER_REVIEW') statusColor = const Color(0xFF3B82F6);
    if (c.status == 'RESOLVED' || c.status == 'CLOSED') statusColor = const Color(0xFF059669);
    if (c.status == 'REJECTED') statusColor = const Color(0xFFDC2626);
    if (c.status == 'REOPENED') statusColor = const Color(0xFFEC4899);

    final fullAttachment = _formatUrl(c.attachmentUrls);

    // Parse status history
    List<Map<String, dynamic>> history = [];
    try {
      if (c.statusHistory != null && c.statusHistory!.isNotEmpty) {
        final decoded = (c.statusHistory as dynamic);
        if (decoded is String) {
          // Parse JSON string
          final list = RegExp(r'\{[^{}]*\}').allMatches(c.statusHistory!).map((m) => m.group(0)!).toList();
          // Or simple display
        }
      }
    } catch (_) {}

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        title: Text(
          c.complaintId,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'monospace'),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: statusColor.withOpacity(0.5)),
            ),
            child: Text(
              c.status,
              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 95),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xF2141A24),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x22FFFFFF), width: 0.8),
                  ),
                  child: Column(
                    children: [
                      _buildRow('Category', c.category),
                      _buildRow('Member Name', c.memberName),
                      _buildRow('Member Phone', '+91 ${c.memberPhone}'),
                      if (c.assignedTo != null && c.assignedTo!.isNotEmpty)
                        _buildRow('Assigned Staff', c.assignedTo!),
                      _buildRow('Reported On', DateFormat('dd MMM yyyy, hh:mm a').format(c.createdAt)),
                      if (c.resolvedAt != null)
                        _buildRow('Resolved On', DateFormat('dd MMM yyyy, hh:mm a').format(c.resolvedAt!)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // WhatsApp Confirmation Banner if sent
                if (c.whatsappSentAt != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF059669).withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mark_chat_read_rounded, color: Color(0xFF34D399), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('WhatsApp Resolution Alert Dispatched', style: TextStyle(color: Color(0xFF34D399), fontSize: 12, fontWeight: FontWeight.bold)),
                              Text(
                                'Sent to +91 ${c.memberPhone} on ${DateFormat('dd MMM yyyy, hh:mm a').format(c.whatsappSentAt!)}',
                                style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Issue Description
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xF2141A24),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x22FFFFFF), width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Problem Description',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        c.description,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Photo Attachment if available
                if (fullAttachment.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xF2141A24),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x22FFFFFF), width: 0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Attached Photo',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            fullAttachment,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Text('Failed to load attachment', style: TextStyle(color: AppColors.textTertiary)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Resolution Box
                if (c.resolution != null && c.resolution!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF059669).withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981), size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Resolution Message',
                              style: TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c.resolution!,
                          style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Internal Notes Box (if any)
                if (c.internalNotes != null && c.internalNotes!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lock_outline_rounded, color: Color(0xFF60A5FA), size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Internal Admin Notes',
                              style: TextStyle(color: Color(0xFF60A5FA), fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c.internalNotes!,
                          style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),

          // Bottom Action Bar: Always visible "Update Complaint"
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: const BoxDecoration(
                color: Color(0xF20A0E14),
                border: Border(top: BorderSide(color: Color(0x22FFFFFF))),
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                icon: const Icon(Icons.published_with_changes_rounded, color: Colors.black, size: 18),
                label: const Text(
                  'Update Complaint',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14),
                ),
                onPressed: _showUpdateComplaintDialog,
              ),
            ),
          ),

          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator(color: AppColors.purpleLight)),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
