import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_colors.dart';
import '../../../attendance/data/attendance_repository.dart';
import '../../../branch/providers/branch_provider.dart';

class MemberSelfAttendanceCard extends ConsumerStatefulWidget {
  const MemberSelfAttendanceCard({super.key});

  @override
  ConsumerState<MemberSelfAttendanceCard> createState() => _MemberSelfAttendanceCardState();
}

class _MemberSelfAttendanceCardState extends ConsumerState<MemberSelfAttendanceCard> {
  final _identifierController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _lastResult;
  String? _errorMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _submitAttendance() async {
    final raw = _identifierController.text.trim();
    if (raw.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your Mobile Number or Member ID';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _lastResult = null;
    });

    HapticFeedback.mediumImpact();

    try {
      final activeBranch = ref.read(activeBranchProvider);
      final repo = ref.read(attendanceRepositoryProvider);

      final result = await repo.markSelfAttendance(
        identifier: raw,
        branchId: activeBranch.id,
      );

      // Invalidate attendance providers so admin dashboard & live checker update immediately
      ref.invalidate(todayAttendanceProvider);

      setState(() {
        _isLoading = false;
        _lastResult = result;
      });

      if (mounted) {
        final memberName = result['member']?['name'] ?? 'Member';
        final action = result['action'] == 'CHECK_OUT' ? 'Checked Out' : 'Checked In';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '✅ $action: $memberName marked present today!',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not record attendance. Please check your ID/Phone.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xF20D111A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.how_to_reg_rounded,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Member Attendance Check-In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Direct check-in for members & scholars',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.5),
                    width: 0.8,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: Color(0xFF34D399)),
                    SizedBox(width: 5),
                    Text(
                      'LIVE SYNC',
                      style: TextStyle(
                        color: Color(0xFF34D399),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Input field
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _errorMessage != null
                    ? const Color(0xFFEF4444)
                    : Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: TextField(
              controller: _identifierController,
              keyboardType: TextInputType.text,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'Enter Mobile (e.g. 9415919277) or ID (CML-942810)',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 12,
                ),
                prefixIcon: const Icon(
                  Icons.badge_rounded,
                  color: Color(0xFF10B981),
                  size: 18,
                ),
                suffixIcon: _identifierController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16, color: Colors.white38),
                        onPressed: () {
                          _identifierController.clear();
                          setState(() {
                            _lastResult = null;
                            _errorMessage = null;
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _submitAttendance(),
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 6),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
            ),
          ],

          const SizedBox(height: 12),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.touch_app_rounded, size: 18, color: Colors.black),
                        SizedBox(width: 8),
                        Text(
                          'Submit Attendance Check-In',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // Result confirmation pill / card
          if (_lastResult != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _lastResult!['message'] ?? 'Attendance Recorded',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_lastResult!['member']?['name'] ?? 'Member'} • Seat ${_lastResult!['member']?['seatNumber'] ?? 'Assigned'} • ${DateFormat('hh:mm a').format(DateTime.now())}',
                          style: const TextStyle(
                            color: Color(0xFF34D399),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
