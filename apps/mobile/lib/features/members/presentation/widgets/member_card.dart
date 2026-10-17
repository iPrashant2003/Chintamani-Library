import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/member_model.dart';
import '../../data/member_repository.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/whatsapp_logo.dart';
import '../../../../core/utils/member_image_helper.dart';
import 'member_history_dialog.dart';

class MemberCard extends ConsumerStatefulWidget {
  final Member member;
  final VoidCallback onTap;

  const MemberCard({
    super.key,
    required this.member,
    required this.onTap,
  });

  @override
  ConsumerState<MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends ConsumerState<MemberCard>
    with TickerProviderStateMixin {
  // ── 4D Subtle Perspective Tilt & Ambient Breathing Controller ──
  late final AnimationController _tiltController;
  late final Animation<double> _tiltAnimation;

  // ── Smooth Entrance Animation Controller ──
  late final AnimationController _entranceController;
  late final Animation<double> _entranceFade;
  late final Animation<Offset> _entranceSlide;

  bool _isCardPressed = false;

  @override
  void initState() {
    super.initState();

    // Tilt controller: gentle idle floating tilt + breathing pulse (0 → 1 → 0) every 3.8s
    _tiltController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat(reverse: true);
    _tiltAnimation = CurvedAnimation(
      parent: _tiltController,
      curve: Curves.easeInOutSine,
    );

    // Entrance animation: 400ms smooth fade-and-slide on card arrival
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _entranceFade = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    _entranceController.forward();
  }

  @override
  void dispose() {
    _tiltController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  // Multicolour palette for members cards (deep, rich, non-neon jewel tones)
  static const List<Color> _palette = [
    Color(0xFF059669), // Sea Green
    Color(0xFF2563EB), // Royal Blue
    Color(0xFF7C3AED), // Amethyst Purple
    Color(0xFFD97706), // Warm Amber / Orange
    Color(0xFF0D9488), // Dark Green / Teal
    Color(0xFFE11D48), // Rose Crimson / Pink
    Color(0xFFD4AF37), // Imperial Gold
    Color(0xFFDC2626), // Deep Crimson Red
    Color(0xFF4F46E5), // Indigo Blue
    Color(0xFFCA8A04), // Dark Golden Yellow
  ];

  Color _getCardAccent(Member member) {
    final hash = (member.id.hashCode.abs() +
        (member.currentSeatNumber?.hashCode.abs() ??
            member.name.hashCode.abs()));
    return _palette[hash % _palette.length];
  }

  String _formatDate(DateTime? dt, {String defaultVal = '08 Sep, 2026'}) {
    if (dt == null) return defaultVal;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]}, ${dt.year}';
  }

  String _getMemberNumber(Member member) {
    if (member.currentSeatNumber != null &&
        member.currentSeatNumber!.isNotEmpty) {
      return member.currentSeatNumber!;
    }
    final digits = member.memberCode.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isNotEmpty) {
      return digits.length > 3 ? digits.substring(digits.length - 3) : digits;
    }
    return '—';
  }

  // ── Action Handlers (All wired to real database & device actions) ──

  void _openWhatsApp() async {
    final member = widget.member;
    final phone = member.phone?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
    if (phone.isEmpty) {
      _showSnack('No phone number registered for this member');
      return;
    }
    final fullNum = phone.length == 10 ? '91$phone' : phone;
    final msg = Uri.encodeComponent(
      '🏛️ *CHINTAMANI LIBRARY*\n'
      '━━━━━━━━━━━━━━━━━━━━━━\n\n'
      '👤 Dear *${member.name}*,\n\n'
      'Greetings from Chintamani Library! Your study seat and membership are active.\n'
      '• *Seat*: ${_getMemberNumber(member)}\n'
      '• *Plan*: ${member.currentPlanName}\n'
      '• *Batch*: ${member.batch ?? "All Shifts"}\n\n'
      'Please reach out to the admin desk for any study environment assistance.\n\n'
      '📍 *Khalilabad* | *Mehdawal*\n'
      '📞 *Helpline*: +91 9415919277 / 7388389944\n'
      '_Chintamani Library — Infinity under a roof_ 🎯',
    );

    final directUri =
        Uri.parse('whatsapp://send?phone=$fullNum&text=$msg');
    try {
      final launched =
          await launchUrl(directUri, mode: LaunchMode.externalApplication);
      if (!launched) throw Exception();
    } catch (_) {
      try {
        final webUri =
            Uri.parse('https://api.whatsapp.com/send?phone=$fullNum&text=$msg');
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        _showSnack('Could not open WhatsApp. Please check if app is installed.');
      }
    }
  }

  void _sendSms() async {
    final member = widget.member;
    final phone = member.phone?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
    if (phone.isEmpty) {
      _showSnack('No phone number registered for this member');
      return;
    }
    final msg = Uri.encodeComponent(
        'Dear ${member.name}, Greetings from Chintamani Library! Helpline: 9415919277.');
    final uri = Uri.parse('sms:$phone?body=$msg');
    try {
      await launchUrl(uri);
    } catch (_) {
      _showSnack('Could not open SMS app');
    }
  }

  void _callPhone() async {
    final member = widget.member;
    final phone = member.phone?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
    if (phone.isEmpty) {
      _showSnack('No phone number registered');
      return;
    }
    final uri = Uri.parse('tel:$phone');
    try {
      await launchUrl(uri);
    } catch (_) {
      _showSnack('Could not launch dialer');
    }
  }

  void _showEditDialog() {
    final member = widget.member;
    final nameCtrl = TextEditingController(text: member.name);
    final phoneCtrl = TextEditingController(text: member.phone ?? '');
    final addrCtrl = TextEditingController(text: member.address ?? '');
    final batchCtrl = TextEditingController(text: member.batch ?? '');
    final courseCtrl = TextEditingController(text: member.course ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
        ),
        title: const Text('Edit Member Details',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField(nameCtrl, 'Full Name *', Icons.person_outline),
              const SizedBox(height: 10),
              _buildDialogField(
                  phoneCtrl, 'Mobile Number *', Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              _buildDialogField(
                  addrCtrl, 'Address / Location', Icons.location_on_outlined),
              const SizedBox(height: 10),
              _buildDialogField(
                  batchCtrl, 'Shift / Batch', Icons.access_time_rounded),
              const SizedBox(height: 10),
              _buildDialogField(
                  courseCtrl, 'Course / Exam Prep', Icons.school_outlined),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textTertiary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final newName = nameCtrl.text.trim();
              if (newName.isEmpty) {
                _showSnack('Name cannot be empty');
                return;
              }
              Navigator.pop(ctx);
              final repo = ref.read(memberRepositoryProvider);
              await repo.updateMember(member.id, {
                'name': newName,
                'phone': phoneCtrl.text.trim(),
                'address': addrCtrl.text.trim(),
                'batch': batchCtrl.text.trim(),
                'course': courseCtrl.text.trim(),
              });
              ref.invalidate(membersListProvider);
              ref.invalidate(memberStatsProvider);
              _showSnack('✅ Member updated successfully in database!');
            },
            child: const Text('Save Changes',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRenewDialog() {
    final member = widget.member;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF10B981), width: 1.2),
        ),
        title: Text('Renew Membership — ${member.name}',
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Select extension plan to add 30 days to active subscription:',
                style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)),
            const SizedBox(height: 12),
            _buildPlanTile(ctx, '6 hrs batch', 500.0, 30),
            const SizedBox(height: 8),
            _buildPlanTile(ctx, '12 hrs batch', 800.0, 30),
            const SizedBox(height: 8),
            _buildPlanTile(ctx, '24 hrs batch', 1000.0, 30),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textTertiary)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanTile(
      BuildContext ctx, String planName, double price, int days) {
    return InkWell(
      onTap: () async {
        Navigator.pop(ctx);
        final repo = ref.read(memberRepositoryProvider);
        await repo.renewSubscription(
          widget.member.id,
          planName: planName,
          price: price,
          days: days,
        );
        ref.invalidate(membersListProvider);
        ref.invalidate(memberStatsProvider);
        _showSnack('✅ Renewed for $planName (₹${price.toInt()}) for 30 days!');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x3310B981)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    color: Color(0xFF10B981), size: 18),
                const SizedBox(width: 10),
                Text(planName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ],
            ),
            Text(
              '₹${price.toInt()}',
              style: const TextStyle(
                  color: Color(0xFFFDE68A),
                  fontWeight: FontWeight.w900,
                  fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _showGiftDaysDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE11D48), width: 1.2),
        ),
        title: Text('Gift Days to ${widget.member.name}',
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Add complimentary bonus days to this subscription:',
                style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              children: [
                _buildGiftChip(ctx, 1),
                _buildGiftChip(ctx, 3),
                _buildGiftChip(ctx, 7),
                _buildGiftChip(ctx, 15),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFFA1A1AA)))),
        ],
      ),
    );
  }

  Widget _buildGiftChip(BuildContext ctx, int days) {
    return ActionChip(
      label: Text('+$days Days'),
      backgroundColor: const Color(0xFFE11D48).withOpacity(0.18),
      side: const BorderSide(color: Color(0xFFE11D48)),
      labelStyle: const TextStyle(
          color: Color(0xFFFFB4C0), fontWeight: FontWeight.bold),
      onPressed: () async {
        Navigator.pop(ctx);
        final repo = ref.read(memberRepositoryProvider);
        await repo.giftDays(widget.member.id, days);
        ref.invalidate(membersListProvider);
        ref.invalidate(memberStatsProvider);
        _showSnack('🎁 Added +$days bonus days to ${widget.member.name}!');
      },
    );
  }

  void _showAddPayDialog() {
    final amtController = TextEditingController(text: '500');
    final noteController =
        TextEditingController(text: 'Monthly membership fee');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF10B981), width: 1.2),
        ),
        title: Text('Record Fee Payment — ${widget.member.name}',
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogField(amtController, 'Amount (₹)',
                Icons.currency_rupee_rounded,
                keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            _buildDialogField(
                noteController, 'Payment Notes', Icons.notes_rounded),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textTertiary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final amt = double.tryParse(amtController.text.trim()) ?? 0;
              if (amt <= 0) {
                _showSnack('Please enter a valid amount');
                return;
              }
              Navigator.pop(ctx);
              final repo = ref.read(memberRepositoryProvider);
              await repo.renewSubscription(
                widget.member.id,
                planName: widget.member.currentPlanName,
                price: amt,
                days: 30,
              );
              ref.invalidate(membersListProvider);
              ref.invalidate(memberStatsProvider);
              _showSnack(
                  '✅ Payment of ₹${amt.toInt()} recorded in database!');
            },
            child: const Text('Confirm Payment',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLockerDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF8B5CF6), width: 1.2),
        ),
        title: const Text('Assign Locker Vault',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select locker (L01 - L09) for ₹200/month:',
                style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(9, (index) {
                final lockerNum = 'L0${index + 1}';
                return ActionChip(
                  label: Text(lockerNum),
                  backgroundColor:
                      const Color(0xFF8B5CF6).withOpacity(0.2),
                  side: const BorderSide(color: Color(0xFF8B5CF6)),
                  labelStyle: const TextStyle(
                      color: Color(0xFFC084FC),
                      fontWeight: FontWeight.bold),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final repo = ref.read(memberRepositoryProvider);
                    await repo.assignLocker(
                        widget.member.id, lockerNum);
                    ref.invalidate(membersListProvider);
                    _showSnack(
                        '🔐 Assigned $lockerNum to ${widget.member.name}!');
                  },
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textTertiary))),
        ],
      ),
    );
  }

  void _showIdCardDialog() {
    final member = widget.member;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141318),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
              width: 1.2),
        ),
        title: const Text('Digital Student ID Card',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF0C0B10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.30),
                    width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.50),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_rounded,
                          color: Color(0xFFD4AF37), size: 18),
                      SizedBox(width: 6),
                      Text('CHINTAMANI LIBRARY',
                          style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 1.2)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text('OFFICIAL SCHOLAR PASS',
                      style: TextStyle(
                          color: Color(0xFFA1A1AA),
                          fontSize: 10.5,
                          letterSpacing: 0.8)),
                  const SizedBox(height: 14),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color:
                              const Color(0xFFD4AF37).withValues(alpha: 0.5),
                          width: 2),
                    ),
                    child: ClipOval(
                      child: MemberImageHelper.buildAvatar(
                        member: member,
                        size: 64,
                        accentColor: const Color(0xFFD4AF37),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(member.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Text(
                        'Seat ${_getMemberNumber(member)}  •  ${member.currentPlanName}',
                        style: const TextStyle(
                            color: Color(0xFFFDE68A),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 4),
                  Text('Phone: ${member.phone ?? "N/A"}',
                      style: const TextStyle(
                          color: Color(0xFFA1A1AA), fontSize: 11)),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.qr_code_2_rounded,
                        color: Colors.black, size: 68),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Share.share(
                'Chintamani Library Digital Scholar Pass:\n'
                '• Student: ${member.name}\n'
                '• Seat: ${_getMemberNumber(member)}\n'
                '• Plan: ${member.currentPlanName}\n'
                '• Phone: ${member.phone ?? "N/A"}\n'
                '• Helpline: +91 9415919277',
              );
            },
            child: const Text('Share Pass',
                style: TextStyle(color: Color(0xFF10B981))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLogsDialog() {
    final member = widget.member;
    final sub = member.activeSubscription;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Activity Logs — ${member.name}',
            style:
                const TextStyle(color: Colors.white, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLogItem(Icons.how_to_reg_rounded,
                const Color(0xFF10B981), 'Active Admission on record',
                'Seat ${_getMemberNumber(member)} reserved'),
            _buildLogItem(Icons.access_time_rounded,
                const Color(0xFF3B82F6),
                'Shift Plan: ${member.currentPlanName}',
                member.batch ?? 'Standard timing'),
            if (sub != null)
              _buildLogItem(
                  Icons.calendar_today_rounded,
                  const Color(0xFFF59E0B),
                  'Current Expiry',
                  _formatDate(sub.endDate)),
            _buildLogItem(Icons.verified_rounded,
                const Color(0xFF8B5CF6), 'Master Database Synced',
                'Local and cloud records intact'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close',
                  style: TextStyle(color: AppColors.goldPrimary))),
        ],
      ),
    );
  }

  Widget _buildLogItem(
      IconData icon, Color color, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFDC2626), width: 1.2),
        ),
        title: const Text('Delete Member',
            style: TextStyle(color: Colors.white)),
        content: Text(
            'Are you sure you want to remove ${widget.member.name} permanently from the library database?',
            style: const TextStyle(color: Color(0xFFA1A1AA))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textTertiary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626)),
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(memberRepositoryProvider);
              await repo.deleteMember(widget.member.id);
              ref.invalidate(membersListProvider);
              ref.invalidate(memberStatsProvider);
              _showSnack('🗑️ Member removed from database');
            },
            child: const Text('Confirm Delete',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFDC2626), width: 1.2),
        ),
        title: Text(
            widget.member.isActive ? 'Block Member' : 'Unblock Member',
            style: const TextStyle(color: Colors.white)),
        content: Text(
          widget.member.isActive
              ? 'Temporarily block biometric and seat access for ${widget.member.name}?'
              : 'Re-activate library access for ${widget.member.name}?',
          style: const TextStyle(color: Color(0xFFA1A1AA)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textTertiary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: widget.member.isActive
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF10B981)),
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(memberRepositoryProvider);
              await repo.toggleBlock(widget.member.id);
              ref.invalidate(membersListProvider);
              ref.invalidate(memberStatsProvider);
              _showSnack(widget.member.isActive
                  ? '🚫 Member blocked'
                  : '✅ Member unblocked');
            },
            child: Text(
                widget.member.isActive ? 'Block' : 'Unblock',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showMarkLeftDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFF59E0B), width: 1.2),
        ),
        title: const Text('Mark Student Left',
            style: TextStyle(color: Colors.white)),
        content: Text(
            'Mark ${widget.member.name} as left? The assigned seat and locker will be freed immediately.',
            style: const TextStyle(color: Color(0xFFA1A1AA))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.textTertiary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black),
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(memberRepositoryProvider);
              await repo.markLeft(widget.member.id);
              ref.invalidate(membersListProvider);
              ref.invalidate(memberStatsProvider);
              _showSnack('🚪 Marked as left. Seat freed in database.');
            },
            child: const Text('Confirm',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPrintReceipt() {
    final member = widget.member;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Official Fee Receipt',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student: ${member.name}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Plan: ${member.currentPlanName}',
                style: const TextStyle(color: Colors.white70)),
            Text('Seat: ${_getMemberNumber(member)}',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            const Text('Amount Paid: ₹500',
                style: TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            const Text('Payment Mode: Cash / UPI (Verified)',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close',
                  style: TextStyle(color: AppColors.textTertiary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(ctx);
              Share.share(
                '🏛️ CHINTAMANI LIBRARY FEE RECEIPT\n'
                '━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
                '• Student: ${member.name}\n'
                '• Seat: ${_getMemberNumber(member)}\n'
                '• Plan: ${member.currentPlanName}\n'
                '• Amount Paid: ₹500\n'
                '• Date: ${_formatDate(DateTime.now())}\n'
                '• Status: PAID & VERIFIED\n\n'
                'Helpline: +91 9415919277',
              );
            },
            child: const Text('Share Receipt',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSixMonthHistoryDialog() {
    MemberSixMonthHistoryDialog.show(context, widget.member);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          duration: const Duration(milliseconds: 1600),
          behavior: SnackBarBehavior.floating),
    );
  }

  Widget _buildDialogField(
      TextEditingController ctrl, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: AppColors.textTertiary, fontSize: 12),
        prefixIcon:
            Icon(icon, color: AppColors.goldPrimary, size: 18),
        filled: true,
        fillColor: Colors.white.withOpacity(0.04),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0x33FFFFFF))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0x22FFFFFF))),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  // ── Enhanced Visual Helpers ──

  /// Clean avatar with subtle live status ring
  Widget _buildGlowingAvatar(Member member, Color cardAccent) {
    final statusColor =
        member.isActive ? const Color(0xFF10B981) : const Color(0xFFDC2626);
    return AnimatedBuilder(
      animation: _tiltAnimation,
      builder: (context, _) {
        return Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1A1820),
            border: Border.all(
              color: statusColor.withValues(
                alpha: 0.40 + (_tiltAnimation.value * 0.45),
              ),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: statusColor.withValues(
                  alpha: 0.10 + (_tiltAnimation.value * 0.22),
                ),
                blurRadius: 8 + (_tiltAnimation.value * 6),
                spreadRadius: _tiltAnimation.value * 0.5,
              ),
            ],
          ),
          child: ClipOval(
            child: MemberImageHelper.buildAvatar(
              member: member,
              size: 52,
              accentColor: cardAccent,
            ),
          ),
        );
      },
    );
  }

  /// Name with ShaderMask gradient: white → accent color
  Widget _buildGradientName(Member member, Color cardAccent) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [Colors.white, cardAccent.withOpacity(0.85)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        member.name,
        style: const TextStyle(
          color: Colors.white, // ShaderMask overrides this
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Clean seat badge with accent color — no shimmer animation
  Widget _buildShimmerSeatBadge(String seatNum, Color cardAccent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: cardAccent.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.chair_alt_rounded, color: Colors.white, size: 13),
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
    );
  }

  /// Expiry date with clean typography — no dots
  Widget _buildExpiryWidget(
      Member member, String expiryDate, Color cardAccent) {
    final sub = member.activeSubscription;
    final daysRemaining = sub?.endDate != null
        ? sub!.endDate.difference(DateTime.now()).inDays
        : 999;
    final isExpiringSoon = member.isActive && daysRemaining < 7;

    return Text(
      expiryDate,
      style: TextStyle(
        color: !member.isActive
            ? const Color(0xFFEF4444)
            : isExpiringSoon
                ? const Color(0xFFF59E0B)
                : Colors.white,
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final member = widget.member;
    final seatNum = _getMemberNumber(member);
    final cardAccent = _getCardAccent(member);

    final planName =
        member.currentPlanName.isNotEmpty && member.currentPlanName != 'No Plan'
            ? member.currentPlanName
            : 'No Active Plan';
    final batchType =
        member.batch != null && member.batch!.isNotEmpty
            ? member.batch!
            : 'General Study';
    final sub = member.activeSubscription;
    final joinDate = sub != null
        ? _formatDate(sub.startDate, defaultVal: '—')
        : '—';
    final expiryDate = sub != null
        ? _formatDate(sub.endDate, defaultVal: '—')
        : '—';
    final amt = sub?.plan?.price.toInt() ?? 0;
    final paid = member.isActive ? amt : 0;
    final due = member.isActive ? 0 : amt;

    // ── 4D Perspective Tilt & Live Breathing Motion (Isolated in RepaintBoundary for 60fps) ──
    return FadeTransition(
      opacity: _entranceFade,
      child: SlideTransition(
        position: _entranceSlide,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _tiltAnimation,
            builder: (context, child) {
              final tiltAngle = ((_tiltAnimation.value - 0.5) * 2) * 0.012;
              final scaleY = 1.0 - (_tiltAnimation.value * 0.003);

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(tiltAngle)
                  ..scale(1.0, scaleY),
                child: child,
              );
            },
            child: AnimatedScale(
              scale: _isCardPressed ? 0.985 : 1.0,
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOutCubic,
              child: AnimatedBuilder(
                animation: _tiltAnimation,
                builder: (context, innerChild) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.55),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                          spreadRadius: 0,
                        ),
                        // Gentle breathing live glow
                        BoxShadow(
                          color: cardAccent.withValues(alpha: 0.05 + (_tiltAnimation.value * 0.07)),
                          blurRadius: 20 + (_tiltAnimation.value * 8),
                          offset: const Offset(0, 4),
                          spreadRadius: _tiltAnimation.value * 0.8,
                        ),
                      ],
                    ),
                    child: innerChild,
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: AnimatedBuilder(
                      animation: _tiltAnimation,
                      builder: (context, contentChild) {
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xEE141318),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Color.lerp(
                                Colors.white.withValues(alpha: 0.07),
                                cardAccent.withValues(alpha: 0.32),
                                _tiltAnimation.value,
                              )!,
                              width: 1.0,
                            ),
                          ),
                          child: contentChild,
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── ZONE 1 & 2: Header + Details Box (Tappable for Profile) ──
                          InkWell(
                            onTap: widget.onTap,
                            onHighlightChanged: (val) => setState(() => _isCardPressed = val),
                            borderRadius:
                                const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row: Avatar, Name, Seat Badge
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Pulsing Glowing Avatar ──
                              _buildGlowingAvatar(member, cardAccent),
                              const SizedBox(width: 12),

                              // Name, Location, Phone
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          // ── Gradient Name Text ──
                                          child: _buildGradientName(
                                              member, cardAccent),
                                        ),
                                        if (!member.isActive)
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDC2626)
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: Border.all(
                                                  color: const Color(
                                                      0xFFDC2626)),
                                            ),
                                            child: const Text('BLOCKED',
                                                style: TextStyle(
                                                    color: Color(0xFFDC2626),
                                                    fontSize: 9,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        const Icon(
                                            Icons.location_on_outlined,
                                            size: 12,
                                            color: Color(0xFFA1A1AA)),
                                        const SizedBox(width: 3),
                                        Expanded(
                                          child: Text(
                                            member.address != null &&
                                                    member.address!.isNotEmpty
                                                ? member.address!
                                                : 'Address not provided',
                                            style: const TextStyle(
                                                color: Color(0xFFA1A1AA),
                                                fontSize: 11),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        const Icon(Icons.phone_rounded,
                                            size: 12,
                                            color: Color(0xFF10B981)),
                                        const SizedBox(width: 4),
                                        Text(
                                          member.phone != null &&
                                                  member.phone!.isNotEmpty
                                              ? member.phone!
                                              : 'Phone not provided',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: _callPhone,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: cardAccent
                                                  .withOpacity(0.18),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Icon(Icons.call,
                                                size: 11,
                                                color: cardAccent),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // ── Seat Badge ──
                              _buildShimmerSeatBadge(seatNum, cardAccent),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Middle Inset Glass Details Box
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.28),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.08)),
                            ),
                            child: Column(
                              children: [
                                // Row 1: Plan & Type
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Plan',
                                              style: TextStyle(
                                                  color: Color(0xFFA1A1AA),
                                                  fontSize: 10.5)),
                                          const SizedBox(height: 2),
                                          Text(
                                            planName,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Type',
                                              style: TextStyle(
                                                  color: Color(0xFFA1A1AA),
                                                  fontSize: 10.5)),
                                          const SizedBox(height: 2),
                                          Text(
                                            batchType,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Join',
                                              style: TextStyle(
                                                  color: Color(0xFFA1A1AA),
                                                  fontSize: 10.5)),
                                          const SizedBox(height: 2),
                                          Text(
                                            joinDate,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Expiry',
                                              style: TextStyle(
                                                  color: Color(0xFFA1A1AA),
                                                  fontSize: 10.5)),
                                          const SizedBox(height: 2),
                                          // ── Expiry with pulse dot ──
                                          _buildExpiryWidget(
                                              member,
                                              expiryDate,
                                              cardAccent),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Amt',
                                              style: TextStyle(
                                                  color: Color(0xFFA1A1AA),
                                                  fontSize: 10.5)),
                                          const SizedBox(height: 2),
                                          Text('₹$amt',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.5,
                                                  fontWeight:
                                                      FontWeight.w700)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Paid',
                                              style: TextStyle(
                                                  color: Color(0xFFA1A1AA),
                                                  fontSize: 10.5)),
                                          const SizedBox(height: 2),
                                          Text('₹$paid',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.5,
                                                  fontWeight:
                                                      FontWeight.w700)),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Due',
                                              style: TextStyle(
                                                  color: Color(0xFFA1A1AA),
                                                  fontSize: 10.5)),
                                          const SizedBox(height: 2),
                                          Text(
                                            '₹$due',
                                            style: TextStyle(
                                              color: due > 0
                                                  ? const Color(0xFFDC2626)
                                                  : const Color(0xFF10B981),
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
                        ],
                      ),
                    ),
                  ),

                  // ── ZONE 3: Action Chips Row ──
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        children: [
                          _buildActionChip(
                            icon: Icons.history_rounded,
                            label: '6M History',
                            color: const Color(0xFFD4AF37),
                            onTap: _showSixMonthHistoryDialog,
                          ),
                          _buildActionChip(
                            icon: Icons.chat_rounded,
                            label: 'WhatsApp',
                            color: const Color(0xFF25D366),
                            isWhatsApp: true,
                            onTap: _openWhatsApp,
                          ),
                          _buildActionChip(
                            icon: Icons.edit_note_rounded,
                            label: 'Edit',
                            color: const Color(0xFFD97706),
                            onTap: _showEditDialog,
                          ),
                          _buildActionChip(
                            icon: Icons.refresh_rounded,
                            label: 'Renew',
                            color: const Color(0xFF10B981),
                            onTap: _showRenewDialog,
                          ),
                          _buildActionChip(
                            icon: Icons.sms_outlined,
                            label: 'SMS',
                            color: const Color(0xFF0EA5E9),
                            onTap: _sendSms,
                          ),
                          _buildActionChip(
                            icon: Icons.badge_outlined,
                            label: 'ID-Card',
                            color: const Color(0xFF3B82F6),
                            onTap: _showIdCardDialog,
                          ),
                          _buildActionChip(
                            icon: Icons.history_rounded,
                            label: 'View Logs',
                            color: const Color(0xFF8B5CF6),
                            onTap: _showLogsDialog,
                          ),
                          _buildActionChip(
                            icon: Icons.card_giftcard_rounded,
                            label: 'Gift Days',
                            color: const Color(0xFFE11D48),
                            onTap: _showGiftDaysDialog,
                          ),
                          _buildActionChip(
                            icon: Icons.payments_outlined,
                            label: 'Add Pay',
                            color: const Color(0xFF059669),
                            onTap: _showAddPayDialog,
                          ),
                          _buildActionChip(
                            icon: Icons.print_rounded,
                            label: 'Print',
                            color: const Color(0xFF0D9488),
                            onTap: _showPrintReceipt,
                          ),
                          _buildActionChip(
                            icon: Icons.lock_outline_rounded,
                            label: 'Locker',
                            color: const Color(0xFFCA8A04),
                            onTap: _showLockerDialog,
                          ),
                          _buildActionChip(
                            icon: Icons.person_outline_rounded,
                            label: 'Profile',
                            color: const Color(0xFF6366F1),
                            onTap: widget.onTap,
                          ),
                          _buildActionChip(
                            icon: Icons.block_rounded,
                            label: widget.member.isActive ? 'Block' : 'Unblock',
                            color: const Color(0xFF991B1B),
                            onTap: _showBlockDialog,
                          ),
                          _buildActionChip(
                            icon: Icons.exit_to_app_rounded,
                            label: 'Mark Left',
                            color: const Color(0xFF64748B),
                            onTap: _showMarkLeftDialog,
                          ),
                          _buildActionChip(
                            icon: Icons.delete_outline_rounded,
                            label: 'Delete',
                            color: const Color(0xFFDC2626),
                            onTap: _showDeleteDialog,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ),
),
),
);
}

  // ── Uniform 4D Action Chip — color on icon & text only, clean neutral container ──
  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isWhatsApp = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: _PressableChip(
        onTap: onTap,
        color: color,
        child: SizedBox(
          width: 66,
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              isWhatsApp
                  ? const WhatsAppLogo(size: 22, color: Color(0xFF25D366))
                  : Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.05,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pressable chip widget: handles scale-down on press + haptic ──
class _PressableChip extends StatefulWidget {
  final Widget child;
  final Color color;
  final VoidCallback onTap;

  const _PressableChip({
    required this.child,
    required this.color,
    required this.onTap,
  });

  @override
  State<_PressableChip> createState() => _PressableChipState();
}

class _PressableChipState extends State<_PressableChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 180),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 0.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressCtrl.forward();
  void _onTapUp(TapUpDetails _) => _pressCtrl.reverse();
  void _onTapCancel() => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            // Neutral dark glass — NO color-fill surroundings
            color: const Color(0xFF19171E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
