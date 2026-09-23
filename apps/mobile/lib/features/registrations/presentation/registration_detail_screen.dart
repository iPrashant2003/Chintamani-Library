import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../core/api/api_endpoints.dart';
import '../data/registration_repository.dart';

class RegistrationDetailScreen extends ConsumerStatefulWidget {
  final String registrationId;

  const RegistrationDetailScreen({super.key, required this.registrationId});

  @override
  ConsumerState<RegistrationDetailScreen> createState() => _RegistrationDetailScreenState();
}

class _RegistrationDetailScreenState extends ConsumerState<RegistrationDetailScreen> {
  bool _isLoading = true;
  bool _isProcessing = false;
  Map<String, dynamic>? _detail;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repo = ref.read(registrationRepositoryProvider);
    final data = await repo.getRegistrationDetail(widget.registrationId);

    if (mounted) {
      setState(() {
        _detail = data;
        _isLoading = false;
        if (data == null) _error = 'Failed to load application details';
      });
    }
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
                      child: Text('Failed to load image', style: TextStyle(color: Colors.white70)),
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

  void _showSeatAllocationSheet() {
    final availableSeats = (_detail?['availableSeats'] as List? ?? []);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Available Seat',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (availableSeats.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Text('No seats currently available in this branch', style: TextStyle(color: AppColors.textTertiary)),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: availableSeats.length,
                  itemBuilder: (context, idx) {
                    final s = availableSeats[idx];
                    final seatId = s['id'] as String;
                    final seatNum = s['seatNumber'] as String;

                    return InkWell(
                      onTap: () async {
                        Navigator.pop(ctx);
                        setState(() => _isProcessing = true);
                        final success = await ref
                            .read(registrationRepositoryProvider)
                            .assignSeat(widget.registrationId, seatId);
                        setState(() => _isProcessing = false);

                        if (mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Seat $seatNum assigned successfully')),
                            );
                            _loadDetail();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to allocate seat. Please retry.')),
                            );
                          }
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF059669), width: 1),
                        ),
                        child: Center(
                          child: Text(
                            seatNum,
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
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

  void _showApproveDialog() {
    final reservedSeat = _detail?['reservedSeat'];
    final reservedSeatNumber = reservedSeat?['seatNumber'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF059669), width: 1),
        ),
        title: const Text('Approve Registration', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Approve registration for ${_detail?['name']}?\n\n'
              '${reservedSeatNumber != null ? '• Seat $reservedSeatNumber will be marked OCCUPIED\n' : ''}'
              '• Active member account and subscription will be created immediately.',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
              backgroundColor: const Color(0xFF059669),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isProcessing = true);
              final success = await ref
                  .read(registrationRepositoryProvider)
                  .approveRegistration(widget.registrationId);
              setState(() => _isProcessing = false);

              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Registration approved! Member account activated.')),
                  );
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to approve registration')),
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

  void _showRejectDialog() {
    final reasonController = TextEditingController(text: 'Application requirements not met');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFDC2626), width: 1),
        ),
        title: const Text('Reject Application', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Any reserved seat will be immediately released back to AVAILABLE.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 2,
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
              setState(() => _isProcessing = true);
              final success = await ref
                  .read(registrationRepositoryProvider)
                  .rejectRegistration(widget.registrationId, reason: reasonController.text.trim());
              setState(() => _isProcessing = false);

              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Registration rejected and seat released.')),
                  );
                  Navigator.pop(context, true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to reject registration')),
                  );
                }
              }
            },
            child: const Text('Confirm Rejection', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Center(child: CircularProgressIndicator(color: AppColors.goldPrimary)),
      );
    }

    if (_error != null || _detail == null) {
      return Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(backgroundColor: AppColors.bgDark, elevation: 0),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.redPrimary, size: 36),
              const SizedBox(height: 8),
              Text(_error ?? 'Error', style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadDetail,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary),
                child: const Text('Retry', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      );
    }

    final d = _detail!;
    final status = d['status'] as String? ?? 'PENDING';
    final plan = d['plan'] as Map<String, dynamic>?;
    final reservedSeat = d['reservedSeat'] as Map<String, dynamic>?;
    final submittedAt = DateTime.tryParse(d['submittedAt'] as String? ?? '') ?? DateTime.now();

    Color statusColor = const Color(0xFFD97706);
    if (status == 'APPROVED') statusColor = const Color(0xFF059669);
    if (status == 'REJECTED') statusColor = const Color(0xFFDC2626);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        title: Text(
          d['applicationId'] as String? ?? 'Application',
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
              status,
              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Applicant Personal Card
                _buildSectionCard(
                  title: 'Applicant Personal Details',
                  icon: Icons.person_outline_rounded,
                  children: [
                    _buildRow('Full Name', d['name'] ?? '-'),
                    _buildRow('Mobile Number', '+91 ${d['phone'] ?? '-'}'),
                    _buildRow('Email', d['email'] ?? 'Not provided'),
                    _buildRow('Date of Birth', d['dob'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(d['dob'])) : 'Not provided'),
                    _buildRow('Address', d['address'] ?? 'Not provided'),
                    _buildRow('Aadhaar Number', d['aadhaarNumber'] ?? 'Not provided'),
                    _buildRow('Emergency Contact', d['emergencyContact'] ?? 'Not provided'),
                    _buildRow('Submitted On', DateFormat('dd MMM yyyy, hh:mm a').format(submittedAt)),
                  ],
                ),
                const SizedBox(height: 14),

                // Plan & Seat Details Card
                _buildSectionCard(
                  title: 'Plan & Seat Allocation',
                  icon: Icons.chair_outlined,
                  children: [
                    _buildRow('Selected Plan', plan?['name'] ?? 'None'),
                    _buildRow('Plan Fee', '₹${plan?['price'] ?? 0}'),
                    _buildRow('Plan Duration', '${plan?['durationDays'] ?? 0} Days'),
                    _buildRow('Seat Allocation Type', plan?['seatAllocation'] == 'AUTO' ? '24h Auto-Reserved' : 'Admin Assigned'),
                    const Divider(color: Color(0x22FFFFFF), height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Assigned / Reserved Seat', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        if (reservedSeat != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF059669).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF059669)),
                            ),
                            child: Text(
                              'Seat ${reservedSeat['seatNumber']}',
                              style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          )
                        else
                          const Text('Not Allocated', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                      ],
                    ),
                    if (status == 'PENDING') ...[
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.goldPrimary,
                          side: const BorderSide(color: AppColors.goldPrimary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _showSeatAllocationSheet,
                        icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                        label: Text(reservedSeat == null ? 'Allocate Seat Now' : 'Change Allocated Seat'),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),

                // Uploaded Documents
                _buildSectionCard(
                  title: 'Uploaded Documents',
                  icon: Icons.file_present_rounded,
                  children: [
                    Row(
                      children: [
                        // Selfie thumbnail
                        _buildDocThumbnail('Live Selfie', d['photoUrl']),
                        const SizedBox(width: 12),
                        // Aadhaar Front
                        _buildDocThumbnail('Aadhaar Front', d['aadhaarFrontUrl']),
                        const SizedBox(width: 12),
                        // Aadhaar Back
                        _buildDocThumbnail('Aadhaar Back', d['aadhaarBackUrl']),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (d['rejectionReason'] != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDC2626).withOpacity(0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Color(0xFFDC2626), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Rejection Reason', style: TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(d['rejectionReason'], style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Bottom Action Bar (if PENDING)
          if (status == 'PENDING')
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
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFDC2626)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _showRejectDialog,
                        child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _showApproveDialog,
                        child: const Text('Approve & Activate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator(color: AppColors.goldPrimary)),
            ),
        ],
      ),
    );
  }

  Widget _buildDocThumbnail(String label, String? url) {
    final fullUrl = _formatUrl(url);

    return Expanded(
      child: Column(
        children: [
          GestureDetector(
            onTap: fullUrl.isNotEmpty ? () => _showImageDialog(label, fullUrl) : null,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x22FFFFFF)),
              ),
              child: fullUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        fullUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image_rounded, size: 24, color: AppColors.textTertiary),
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.image_not_supported_rounded, size: 24, color: AppColors.textTertiary),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.goldPrimary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
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
