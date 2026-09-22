import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/member_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/member_avatar.dart';
import '../../../../widgets/whatsapp_logo.dart';

class MemberCard extends StatefulWidget {
  final Member member;
  final VoidCallback onTap;

  const MemberCard({
    super.key,
    required this.member,
    required this.onTap,
  });

  @override
  State<MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<MemberCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  int _actionPage = 0; // 0 = first action row, 1 = second action row

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? dt, {String defaultVal = '08 Sep, 2026'}) {
    if (dt == null) return defaultVal;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]}, ${dt.year}';
  }

  String _getMemberNumber(Member member) {
    if (member.currentSeatNumber != null && member.currentSeatNumber!.isNotEmpty) {
      return member.currentSeatNumber!;
    }
    final digits = member.memberCode.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isNotEmpty) return digits.length > 3 ? digits.substring(digits.length - 3) : digits;
    return '327';
  }

  @override
  Widget build(BuildContext context) {
    final member = widget.member;
    final seatNum = _getMemberNumber(member);
    final planName = member.currentPlanName.isNotEmpty && member.currentPlanName != 'No Plan'
        ? member.currentPlanName
        : '6 hrs batch';
    final batchType = member.batch != null && member.batch!.isNotEmpty
        ? member.batch!
        : 'morning~afternoon~even...';
    final sub = member.activeSubscription;
    final joinDate = sub != null ? _formatDate(sub.startDate, defaultVal: '08 Sep, 2026') : '08 Sep, 2026';
    final expiryDate = sub != null ? _formatDate(sub.endDate, defaultVal: '07 Oct, 2026') : '07 Oct, 2026';
    final amt = sub?.plan?.price.toInt() ?? 500;
    const paid = 500;
    final due = amt > paid ? amt - paid : 0;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _animController.forward();
      },
      onTapUp: (_) {
        _animController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _animController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF181510), // Warm luxury dark container
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Row: Avatar + Name/Location/Phone + Seat Badge + Chair Indicator ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Illustrated circular Avatar
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFDE68A), // Warm yellow from screenshot
                          border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            member.name.isNotEmpty ? member.name.substring(0, 1).toUpperCase() : 'S',
                            style: const TextStyle(
                              color: Color(0xFF92400E),
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Name, Location, Phone
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFFA1A1AA)),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    member.address != null && member.address!.isNotEmpty
                                        ? member.address!
                                        : 'moti chauraha khalilabad',
                                    style: const TextStyle(
                                      color: Color(0xFFA1A1AA),
                                      fontSize: 11.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.phone_rounded, size: 13, color: Color(0xFF10B981)),
                                const SizedBox(width: 4),
                                Text(
                                  member.phone != null && member.phone!.isNotEmpty
                                      ? member.phone!
                                      : '+91 9682960623',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDC2626).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.sim_card_outlined, size: 12, color: Color(0xFFDC2626)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Seat Pill Badge (Red #DC2626) & Chair Status Indicator
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626), // Screenshot red badge
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFDC2626).withValues(alpha: 0.45),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.assignment_ind_rounded, color: Colors.white, size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  seatNum,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Chair icon with dotted line (matching screenshot)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.chair_alt_rounded, color: Color(0xFFDC2626), size: 13),
                              const SizedBox(width: 2),
                              Text(
                                '.......',
                                style: TextStyle(
                                  color: const Color(0xFFDC2626).withValues(alpha: 0.8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Middle Inset Details Box (Plan, Type, Join, Expiry, Amt, Paid, Due) ──
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Column(
                      children: [
                        // Row 1: Plan & Type
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Plan', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 10.5)),
                                  const SizedBox(height: 2),
                                  Text(
                                    planName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Type', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 10.5)),
                                  const SizedBox(height: 2),
                                  Text(
                                    batchType,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Row 2: Join & Expiry
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Join', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 10.5)),
                                  const SizedBox(height: 2),
                                  Text(
                                    joinDate,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Expiry', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 10.5)),
                                  const SizedBox(height: 2),
                                  Text(
                                    expiryDate,
                                    style: TextStyle(
                                      color: member.isActive ? Colors.white : const Color(0xFFDC2626),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Row 3: Amt, Paid, Due
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Amt', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 10.5)),
                                  const SizedBox(height: 2),
                                  Text(
                                    amt.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Paid', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 10.5)),
                                  const SizedBox(height: 2),
                                  Text(
                                    paid.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Due', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 10.5)),
                                  const SizedBox(height: 2),
                                  Text(
                                    due.toString(),
                                    style: TextStyle(
                                      color: due > 0 ? const Color(0xFFDC2626) : const Color(0xFF10B981),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Bottom Swipeable Action Row matching Screenshots ──
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildActionBtn(context, Icons.chat_rounded, 'WhatsApp', const Color(0xFF25D366), isWhatsApp: true),
                        _buildActionBtn(context, Icons.badge_outlined, 'ID-Card', const Color(0xFFDC2626), onTap: () => _showIdCardDialog(context)),
                        _buildActionBtn(context, Icons.edit_note_rounded, 'Edit', const Color(0xFFDC2626), onTap: () => _showEditDialog(context)),
                        _buildActionBtn(context, Icons.history_rounded, 'View Logs', const Color(0xFFDC2626), onTap: () => _showLogsDialog(context)),
                        _buildActionBtn(context, Icons.card_giftcard_rounded, 'Gift Days', const Color(0xFFDC2626), onTap: () => _showGiftDaysDialog(context)),
                        _buildActionBtn(context, Icons.print_rounded, 'Print', const Color(0xFFDC2626), onTap: () => _showPrintReceipt(context)),
                        _buildActionBtn(context, Icons.pause_circle_outline_rounded, 'Freeze', const Color(0xFFDC2626), onTap: () => _showFreezeDialog(context)),
                        _buildActionBtn(context, Icons.person_outline_rounded, 'Profile', const Color(0xFFDC2626), onTap: widget.onTap),
                        _buildActionBtn(context, Icons.fingerprint_rounded, 'Bio Enroll', const Color(0xFFDC2626), onTap: () => _showBioEnrollDialog(context)),
                        _buildActionBtn(context, Icons.payments_outlined, 'Add Pay', const Color(0xFFDC2626), onTap: () => _showAddPayDialog(context)),
                        _buildActionBtn(context, Icons.refresh_rounded, 'Renew', const Color(0xFFDC2626), onTap: () => _showRenewDialog(context)),
                        _buildActionBtn(context, Icons.receipt_long_rounded, 'Add Bill', const Color(0xFFDC2626), onTap: () => _showAddBillDialog(context)),
                        _buildActionBtn(context, Icons.sms_outlined, 'SMS', const Color(0xFFDC2626), onTap: () => _sendSms(context)),
                        _buildActionBtn(context, Icons.lock_outline_rounded, 'Locker', const Color(0xFFDC2626), onTap: () => _showLockerDialog(context)),
                        _buildActionBtn(context, Icons.delete_outline_rounded, 'Delete', const Color(0xFFDC2626), onTap: () => _showDeleteDialog(context)),
                        _buildActionBtn(context, Icons.block_rounded, 'Block', const Color(0xFFDC2626), onTap: () => _showBlockDialog(context)),
                        _buildActionBtn(context, Icons.exit_to_app_rounded, 'Mark Left', const Color(0xFFDC2626), onTap: () => _showMarkLeftDialog(context)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(
    BuildContext context,
    IconData icon,
    String label,
    Color color, {
    bool isWhatsApp = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (isWhatsApp) {
          _openWhatsApp(context);
        } else if (onTap != null) {
          onTap();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label action triggered for ${widget.member.name}'),
              duration: const Duration(milliseconds: 1200),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isWhatsApp
                    ? const WhatsAppLogo(size: 16, color: Color(0xFF25D366))
                    : Icon(icon, color: color, size: 17),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isWhatsApp ? const Color(0xFF25D366) : const Color(0xFFDC2626),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openWhatsApp(BuildContext context) async {
    final member = widget.member;
    final hasPhone = member.phone != null && member.phone!.isNotEmpty;
    if (!hasPhone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number for this member'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    final digits = member.phone!.replaceAll(RegExp(r'[^\d]'), '');
    final fullNum = digits.length == 10 ? '91$digits' : digits;
    final msg = Uri.encodeComponent(
      '🏛️ *CHINTA MANI LIBRARY*\n━━━━━━━━━━━━━━━━━━━━━━\n\n'
      '👤 Dear *${member.name}*,\n\n'
      'Greetings from Chinta Mani Library! Your study seat and membership are active.\n'
      'Please reach out to the admin desk for any study environment assistance.\n\n'
      '📍 *Khalilabad* | *Mehdawal*\n'
      '📞 *Helpline*: +91 9415919277\n\n'
      '_Chinta Mani Library — Infinity under a roof_ 🎯',
    );
    final url = Uri.parse('https://wa.me/$fullNum?text=$msg');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _sendSms(BuildContext context) async {
    final member = widget.member;
    final digits = member.phone?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
    if (digits.isEmpty) return;
    final url = Uri.parse('sms:$digits?body=${Uri.encodeComponent('Dear ${member.name}, this is Chinta Mani Library.')}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _showIdCardDialog(BuildContext context) {
    final member = widget.member;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        title: const Text('Digital Student ID Card', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF261D0C), Color(0xFF100C05)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37), width: 1),
              ),
              child: Column(
                children: [
                  const Text('CHINTA MANI LIBRARY', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w900, fontSize: 15)),
                  const Text('Official Scholar Pass', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 12),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFD4AF37).withOpacity(0.2),
                    child: Text(member.name.substring(0, 1).toUpperCase(), style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  Text(member.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Seat: ${_getMemberNumber(member)} • Plan: ${member.currentPlanName}', style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 12)),
                  Text('Mobile: ${member.phone ?? "N/A"}', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                  const SizedBox(height: 10),
                  const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 60),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close', style: TextStyle(color: Color(0xFFD4AF37)))),
        ],
      ),
    );
  }

  void _showGiftDaysDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        title: Text('Gift Days to ${widget.member.name}', style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add complimentary bonus days to this membership subscription:', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('+1 Day'),
                  backgroundColor: const Color(0x33D4AF37),
                  labelStyle: const TextStyle(color: Color(0xFFFDE68A)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎁 +1 Day added to membership!')));
                  },
                ),
                ActionChip(
                  label: const Text('+3 Days'),
                  backgroundColor: const Color(0x33D4AF37),
                  labelStyle: const TextStyle(color: Color(0xFFFDE68A)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎁 +3 Days added to membership!')));
                  },
                ),
                ActionChip(
                  label: const Text('+7 Days'),
                  backgroundColor: const Color(0x33D4AF37),
                  labelStyle: const TextStyle(color: Color(0xFFFDE68A)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎁 +7 Days added to membership!')));
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Color(0xFFA1A1AA)))),
        ],
      ),
    );
  }

  void _showPrintReceipt(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        title: const Text('Fee Receipt', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student: ${widget.member.name}', style: const TextStyle(color: Colors.white)),
            Text('Plan: ${widget.member.currentPlanName}', style: const TextStyle(color: Colors.white70)),
            const Text('Amount Paid: ₹500', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
            const Text('Payment Mode: Cash / UPI', style: TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🖨️ Receipt sent to printer!')));
            },
            child: const Text('Print Receipt'),
          ),
        ],
      ),
    );
  }

  void _showFreezeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        title: const Text('Freeze Membership', style: TextStyle(color: Colors.white)),
        content: Text('Pause subscription for ${widget.member.name} during exam prep or vacation? Seat will be held reserved.', style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❄️ Membership frozen successfully')));
            },
            child: const Text('Freeze', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBioEnrollDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        title: const Row(
          children: [
            Icon(Icons.fingerprint_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Biometric Enrollment', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Place ${widget.member.name}\'s thumb on the biometric scanner.', style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13)),
            const SizedBox(height: 16),
            const Icon(Icons.fingerprint_rounded, color: Color(0xFFDC2626), size: 64),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done', style: TextStyle(color: Color(0xFFD4AF37)))),
        ],
      ),
    );
  }

  void _showAddPayDialog(BuildContext context) {
    final amtController = TextEditingController(text: '500');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        title: const Text('Add Payment', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amtController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Amount (₹)', labelStyle: TextStyle(color: Color(0xFFA1A1AA))),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Payment recorded!')));
            },
            child: const Text('Save Payment', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRenewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        title: const Text('Renew Membership', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('6 hrs batch', style: TextStyle(color: Colors.white)),
              trailing: const Text('₹500', style: TextStyle(color: Color(0xFFFDE68A), fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Renewed for 6 hrs batch (₹500)!')));
              },
            ),
            ListTile(
              title: const Text('12 hrs batch', style: TextStyle(color: Colors.white)),
              trailing: const Text('₹800', style: TextStyle(color: Color(0xFFFDE68A), fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Renewed for 12 hrs batch (₹800)!')));
              },
            ),
            ListTile(
              title: const Text('24 hrs batch', style: TextStyle(color: Colors.white)),
              trailing: const Text('₹1,000', style: TextStyle(color: Color(0xFFFDE68A), fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Renewed for 24 hrs batch (₹1,000)!')));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBillDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        title: const Text('Add Bill / Invoice', style: TextStyle(color: Colors.white)),
        content: Text('Generate GST / commercial fee invoice for ${widget.member.name}?', style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🧾 Invoice generated!')));
            },
            child: const Text('Create Bill'),
          ),
        ],
      ),
    );
  }

  void _showLockerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        title: const Text('Assign 9 Lockers Vault', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select locker (L01 - L09) • ₹200/month:', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(9, (index) {
                final lockerNum = 'L0${index + 1}';
                return ActionChip(
                  label: Text(lockerNum),
                  backgroundColor: const Color(0x338B5CF6),
                  labelStyle: const TextStyle(color: Color(0xFFC084FC), fontWeight: FontWeight.bold),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🔐 $lockerNum assigned to ${widget.member.name} (₹200/mo)')));
                  },
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        title: const Text('Delete Member', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to remove ${widget.member.name} from the library database?', style: const TextStyle(color: Color(0xFFA1A1AA))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑️ Member removed')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        title: const Text('Block Member', style: TextStyle(color: Colors.white)),
        content: Text('Temporarily block library card & biometric access for ${widget.member.name}?', style: const TextStyle(color: Color(0xFFA1A1AA))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🚫 Member card blocked')));
            },
            child: const Text('Block', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showMarkLeftDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        title: const Text('Mark Student Left', style: TextStyle(color: Colors.white)),
        content: Text('Mark ${widget.member.name} as completed/left? Seat and locker will be freed immediately.', style: const TextStyle(color: Color(0xFFA1A1AA))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🚪 Marked as left. Seat freed.')));
            },
            child: const Text('Mark Left'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: widget.member.name);
    final phoneCtrl = TextEditingController(text: widget.member.phone ?? '');
    final addrCtrl = TextEditingController(text: widget.member.address ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        title: const Text('Edit Member', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Color(0xFFA1A1AA)))),
              const SizedBox(height: 8),
              TextField(controller: phoneCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Phone', labelStyle: TextStyle(color: Color(0xFFA1A1AA)))),
              const SizedBox(height: 8),
              TextField(controller: addrCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Address', labelStyle: TextStyle(color: Color(0xFFA1A1AA)))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Member updated!')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLogsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        title: Text('Activity Logs - ${widget.member.name}', style: const TextStyle(color: Colors.white, fontSize: 15)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Check-in: Today at 08:15 AM (Biometric)', style: TextStyle(color: Color(0xFF10B981), fontSize: 12)),
            SizedBox(height: 6),
            Text('• Check-out: Yesterday at 02:30 PM (QR Scan)', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)),
            SizedBox(height: 6),
            Text('• Payment: ₹500 recorded for 6 hrs batch', style: TextStyle(color: Color(0xFFFDE68A), fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close', style: TextStyle(color: Color(0xFFD4AF37)))),
        ],
      ),
    );
  }
}
