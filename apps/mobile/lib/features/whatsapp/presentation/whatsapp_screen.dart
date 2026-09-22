import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/ambient_background.dart';
import '../../../widgets/chintamani_logo.dart';
import '../../../widgets/whatsapp_logo.dart';
import '../../members/data/member_repository.dart';
import '../../members/domain/member_model.dart';
import '../data/whatsapp_service.dart';
import '../data/whatsapp_ai_service.dart';

// ── Audience filter ─────────────────────────────────────────────────────────────
enum _Audience {
  all,
  botDue,
  stage1_1st,
  stage2_3rd,
  stage3_5th,
  stage4_12h,
  active,
  expiring,
  expired,
  individual,
}

class _FilterChipItem {
  final _Audience audience;
  final String title;
  final String category;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color bg;

  const _FilterChipItem({
    required this.audience,
    required this.title,
    required this.category,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bg,
  });

  String get label => title;
}

const _filterChips = [
  // ── Category 1: 📅 Due Dates & Sequence ─────────────────────────────────────
  _FilterChipItem(
    audience: _Audience.stage1_1st,
    category: 'MONTH-END DUE SEQUENCE',
    title: '1st of Month (Day 1)',
    subtitle: '1st polite payment reminder sent to students with dues',
    icon: Icons.calendar_today_rounded,
    color: Color(0xFF3B82F6), // Royal Blue
    bg: Color(0xFF0C192E),
  ),
  _FilterChipItem(
    audience: _Audience.stage2_3rd,
    category: 'MONTH-END DUE SEQUENCE',
    title: '3rd of Month (Day 3)',
    subtitle: 'Seat hold notice & 2nd administrative alert',
    icon: Icons.event_available_rounded,
    color: Color(0xFFA855F7), // Royal Purple
    bg: Color(0xFF1F0B36),
  ),
  _FilterChipItem(
    audience: _Audience.stage3_5th,
    category: 'MONTH-END DUE SEQUENCE',
    title: '5th of Month (Final Grace)',
    subtitle: 'Final warning — 12-hour grace period starts',
    icon: Icons.warning_amber_rounded,
    color: Color(0xFFEF4444), // Crimson Red
    bg: Color(0xFF2B0A0A),
  ),
  _FilterChipItem(
    audience: _Audience.stage4_12h,
    category: 'MONTH-END DUE SEQUENCE',
    title: '+12h Seat Release Notice',
    subtitle: 'Final grace expired — seat deallocated notification',
    icon: Icons.cancel_outlined,
    color: Color(0xFFEC4899), // Velvet Berry Pink
    bg: Color(0xFF2C0B1B),
  ),

  // ── Category 2: 👥 Student Membership Status ───────────────────────────────
  _FilterChipItem(
    audience: _Audience.all,
    category: 'MEMBERSHIP STATUS',
    title: 'All Registered Students',
    subtitle: 'Every registered student across all branches',
    icon: Icons.groups_rounded,
    color: Color(0xFFD4AF37), // Imperial Gold
    bg: Color(0xFF1C1408),
  ),
  _FilterChipItem(
    audience: _Audience.active,
    category: 'MEMBERSHIP STATUS',
    title: 'Active Students',
    subtitle: 'Currently enrolled students with valid memberships',
    icon: Icons.check_circle_outline_rounded,
    color: Color(0xFF10B981), // Emerald Green
    bg: Color(0xFF062B1D),
  ),
  _FilterChipItem(
    audience: _Audience.expiring,
    category: 'MEMBERSHIP STATUS',
    title: 'Expiring Soon (≤ 15 Days)',
    subtitle: 'Students whose plan ends within the next 15 days',
    icon: Icons.hourglass_top_rounded,
    color: Color(0xFFF59E0B), // Warm Amber
    bg: Color(0xFF241604),
  ),
  _FilterChipItem(
    audience: _Audience.expired,
    category: 'MEMBERSHIP STATUS',
    title: 'Expired / Overdue Students',
    subtitle: 'Students with overdue or expired memberships',
    icon: Icons.person_off_rounded,
    color: Color(0xFFDC2626), // Ruby Red
    bg: Color(0xFF260808),
  ),

  // ── Category 3: 🤖 Automated & Direct ──────────────────────────────────────
  _FilterChipItem(
    audience: _Audience.botDue,
    category: 'AUTOMATED & DIRECT',
    title: 'Automated Bot Due Queue',
    subtitle: 'Students identified automatically by the due cycle bot',
    icon: Icons.smart_toy_rounded,
    color: Color(0xFF14B8A6), // Sea Green / Teal
    bg: Color(0xFF072421),
  ),
  _FilterChipItem(
    audience: _Audience.individual,
    category: 'AUTOMATED & DIRECT',
    title: 'Pick Specific Student',
    subtitle: 'Select an individual student from the directory',
    icon: Icons.person_search_rounded,
    color: Color(0xFF0EA5E9), // Sky Blue
    bg: Color(0xFF082535),
  ),
];

// ── WhatsApp Hub Screen ─────────────────────────────────────────────────────────
class WhatsAppScreen extends ConsumerStatefulWidget {
  const WhatsAppScreen({super.key});

  @override
  ConsumerState<WhatsAppScreen> createState() => _WhatsAppScreenState();
}

class _WhatsAppScreenState extends ConsumerState<WhatsAppScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // Broadcast & Bot State
  _Audience _audience = _Audience.all;
  WaTemplate _template = WaTemplate.feeReminder;
  final _customBodyCtrl = TextEditingController();
  final _holidayMsgCtrl = TextEditingController();
  final _announcementCtrl = TextEditingController();
  final _previewCtrl = TextEditingController();
  bool _previewManuallyEdited = false;
  Member? _pickedMember;
  bool _sending = false;

  // Settings tab state
  final _adminNumberCtrl = TextEditingController();
  bool _botActive = true;

  // Members tab search
  final _memberSearchCtrl = TextEditingController();
  String _memberSearch = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final num = await ref.read(whatsAppServiceProvider).getAdminNumber();
    final active = await ref.read(whatsAppServiceProvider).isBotActive();
    if (mounted) {
      setState(() {
        _adminNumberCtrl.text = num;
        _botActive = active;
        if (!_previewManuallyEdited) {
          _previewCtrl.text = _buildPreview(num);
        }
      });
    }
  }

  void _syncPreview(String adminNumber, {bool force = false}) {
    if (force || !_previewManuallyEdited) {
      _previewCtrl.text = _buildPreview(adminNumber);
      if (force) _previewManuallyEdited = false;
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _customBodyCtrl.dispose();
    _holidayMsgCtrl.dispose();
    _announcementCtrl.dispose();
    _previewCtrl.dispose();
    _adminNumberCtrl.dispose();
    _memberSearchCtrl.dispose();
    super.dispose();
  }

  // ── Audience Filter Helper ──────────────────────────────────────────────────
  List<Member> _filterMembers(List<Member> all, String adminNumber) {
    final svc = ref.read(whatsAppServiceProvider);
    final botQueue = svc.getBotDueQueue(all, adminNumber);

    switch (_audience) {
      case _Audience.all:
        return all;
      case _Audience.botDue:
        return botQueue.map((e) => e.member).toList();
      case _Audience.stage1_1st:
        return botQueue
            .where((e) => e.stage == BotDueStage.stage1Day1)
            .map((e) => e.member)
            .toList();
      case _Audience.stage2_3rd:
        return botQueue
            .where((e) => e.stage == BotDueStage.stage2Day3)
            .map((e) => e.member)
            .toList();
      case _Audience.stage3_5th:
        return botQueue
            .where((e) => e.stage == BotDueStage.stage3Day5)
            .map((e) => e.member)
            .toList();
      case _Audience.stage4_12h:
        return botQueue
            .where((e) => e.stage == BotDueStage.stage4Day5Plus12h)
            .map((e) => e.member)
            .toList();
      case _Audience.active:
        return all.where((m) => m.isActive).toList();
      case _Audience.expiring:
        return all.where((m) {
          final days = m.daysRemaining;
          return m.isActive && days != null && days <= 15;
        }).toList();
      case _Audience.expired:
        return all.where((m) => !m.isActive).toList();
      case _Audience.individual:
        return _pickedMember != null ? [_pickedMember!] : [];
    }
  }

  // ── Preview Generator ───────────────────────────────────────────────────────
  String _buildPreview(String adminNumber) {
    final svc = ref.read(whatsAppServiceProvider);

    // If bot audience is selected, preview bot message
    if (_audience == _Audience.stage1_1st) {
      return svc.buildBotMessage(
        member: _pickedMember ?? _dummyMember(),
        stage: BotDueStage.stage1Day1,
        adminNumber: adminNumber,
      );
    }
    if (_audience == _Audience.stage2_3rd) {
      return svc.buildBotMessage(
        member: _pickedMember ?? _dummyMember(),
        stage: BotDueStage.stage2Day3,
        adminNumber: adminNumber,
      );
    }
    if (_audience == _Audience.stage3_5th) {
      return svc.buildBotMessage(
        member: _pickedMember ?? _dummyMember(),
        stage: BotDueStage.stage3Day5,
        adminNumber: adminNumber,
      );
    }
    if (_audience == _Audience.stage4_12h) {
      return svc.buildBotMessage(
        member: _pickedMember ?? _dummyMember(),
        stage: BotDueStage.stage4Day5Plus12h,
        adminNumber: adminNumber,
      );
    }

    if (_template == WaTemplate.custom) {
      return svc.buildMessage(
        template: _template,
        adminNumber: adminNumber,
        name: _pickedMember?.name ?? 'Student',
        customBody: _customBodyCtrl.text.isEmpty
            ? 'Your preview message will appear here...'
            : _customBodyCtrl.text,
      );
    }
    if (_template == WaTemplate.holidayClosed) {
      return svc.buildMessage(
        template: _template,
        adminNumber: adminNumber,
        holidayMessage: _holidayMsgCtrl.text.isEmpty
            ? 'Library will remain CLOSED today for maintenance/holiday.'
            : _holidayMsgCtrl.text,
      );
    }
    if (_template == WaTemplate.announcement) {
      return svc.buildMessage(
        template: _template,
        adminNumber: adminNumber,
        announcementText: _announcementCtrl.text.isEmpty
            ? 'Important notice for all registered scholars.'
            : _announcementCtrl.text,
      );
    }

    return svc.buildMessage(
      template: _template,
      adminNumber: adminNumber,
      name: _pickedMember?.name ?? 'Arjun Sharma',
      memberCode: _pickedMember?.memberCode ?? 'CML-001',
      seat: _pickedMember?.currentSeatNumber ?? 'A12',
      amount: '600',
      expiryDate: '30 Sep 2026',
      daysLeft: 5,
    );
  }

  Member _dummyMember() {
    return const Member(
      id: 'demo',
      memberCode: 'CML-9428',
      name: 'Pooja Verma',
      phone: '7388389944',
      branchId: 'khalilabad',
      isActive: false,
    );
  }

  // ── Dispatch Handler ────────────────────────────────────────────────────────
  Future<void> _sendMessages(List<Member> members, String adminNumber, {bool isBotQueue = false}) async {
    final validMembers = members.where((m) => m.phone != null && m.phone!.isNotEmpty).toList();

    if (validMembers.isEmpty) {
      _showSnack('No members with valid phone numbers in this selection.', isError: true);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14120E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
        ),
        title: const Row(children: [
          Text('📱 ', style: TextStyle(fontSize: 22)),
          Expanded(
            child: Text(
              'Confirm WhatsApp Dispatch',
              style: TextStyle(color: Color(0xFFFDE68A), fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
        ]),
        content: Text(
          'Ready to dispatch messages to ${validMembers.length} student(s) from linked number $adminNumber.\n\n'
          'WhatsApp will open for each student with the formatted message.',
          style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF888888))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Start Sending', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _sending = true);
    final svc = ref.read(whatsAppServiceProvider);

    for (int i = 0; i < validMembers.length; i++) {
      final m = validMembers[i];
      String msg;

      if (_previewManuallyEdited && _previewCtrl.text.trim().isNotEmpty) {
        msg = _previewCtrl.text
            .replaceAll('{name}', m.name)
            .replaceAll('{student}', m.name)
            .replaceAll('{memberCode}', m.memberCode)
            .replaceAll('{code}', m.memberCode)
            .replaceAll('{seat}', m.currentSeatNumber ?? 'Hold')
            .replaceAll('{phone}', m.phone ?? '')
            .replaceAll('{contact}', adminNumber)
            .replaceAll('{admin}', adminNumber);
      } else if (isBotQueue || _audience == _Audience.botDue || _audience == _Audience.stage1_1st ||
          _audience == _Audience.stage2_3rd || _audience == _Audience.stage3_5th ||
          _audience == _Audience.stage4_12h) {
        BotDueStage stage = BotDueStage.stage1Day1;
        if (_audience == _Audience.stage2_3rd) stage = BotDueStage.stage2Day3;
        if (_audience == _Audience.stage3_5th) stage = BotDueStage.stage3Day5;
        if (_audience == _Audience.stage4_12h) stage = BotDueStage.stage4Day5Plus12h;
        msg = svc.buildBotMessage(member: m, stage: stage, adminNumber: adminNumber);
      } else {
        msg = svc.buildMessageForMember(
          template: _template,
          member: m,
          adminNumber: adminNumber,
          customBody: _customBodyCtrl.text,
          holidayMessage: _holidayMsgCtrl.text,
          announcementText: _announcementCtrl.text,
        );
      }

      await svc.openWhatsApp(
        phone: m.phone!,
        message: msg,
        recipientName: m.name,
        templateLabel: isBotQueue ? 'Bot Due Reminder' : waTemplates.firstWhere((t) => t.key == _template).label,
      );

      if (i < validMembers.length - 1 && mounted) {
        final next = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF14120E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
            ),
            title: Text(
              '${i + 1}/${validMembers.length} Completed',
              style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 16, fontWeight: FontWeight.w800),
            ),
            content: Text(
              'Next recipient: ${validMembers[i + 1].name} (${validMembers[i + 1].phone ?? ''})',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Stop', style: TextStyle(color: Color(0xFFEF4444))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Next Student →', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
        if (next != true) break;
      }
    }

    if (mounted) {
      setState(() => _sending = false);
      ref.invalidate(waHistoryProvider);
      _showSnack('✅ WhatsApp messages processed successfully!');
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFFD4AF37),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final adminNumberAsync = ref.watch(adminWhatsAppNumberProvider);
    final adminNumber = adminNumberAsync.value ?? '7388389944';
    final membersAsync = ref.watch(membersListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Top Header: Luxury Golden Branding ───────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Row(
                  children: [
                    // Chintamani Library Logo (replaces WhatsApp logo)
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2A1F0D), Color(0xFF140F05)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.30),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: ChintaManiLogo(size: 32, showGlow: false, showCircularBackground: false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CHINTAMANI WHATSAPP HUB',
                            style: TextStyle(
                              color: Color(0xFFFDE68A),
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'Bot ON',
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1C160B),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4), width: 0.8),
                                ),
                                child: Text(
                                  '+91 $adminNumber',
                                  style: const TextStyle(
                                    color: Color(0xFFB8975A),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
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

              // ── Tab Bar: Luxury Golden Obsidian ──────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xF20F1E17), Color(0xF80A140F)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  indicator: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF34D399), width: 1.2),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: const Color(0xFF34D399),
                  unselectedLabelColor: const Color(0xFFA1A1AA),
                  labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                  unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  padding: const EdgeInsets.all(3),
                  dividerColor: Colors.transparent,
                  isScrollable: false,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.smart_toy_rounded, size: 16),
                      iconMargin: EdgeInsets.only(bottom: 2),
                      text: 'Auto Bot',
                    ),
                    Tab(
                      icon: Icon(Icons.campaign_rounded, size: 16),
                      iconMargin: EdgeInsets.only(bottom: 2),
                      text: 'Broadcast',
                    ),
                    Tab(
                      icon: Icon(Icons.people_alt_rounded, size: 16),
                      iconMargin: EdgeInsets.only(bottom: 2),
                      text: 'Students',
                    ),
                  ],
                ),
              ),

              // ── Tab Views ────────────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    // Tab 1: Auto Bot
                    _BotEngineTab(
                      membersAsync: membersAsync,
                      adminNumber: adminNumber,
                      botActive: _botActive,
                      sending: _sending,
                      onToggleBot: (val) async {
                        setState(() => _botActive = val);
                        await ref.read(whatsAppServiceProvider).setBotActive(val);
                        _showSnack(_botActive ? '🤖 Bot Engine Activated' : '⏸️ Bot Engine Paused');
                      },
                      onRunCycle: (members) => _sendMessages(members, adminNumber, isBotQueue: true),
                      onSendSingle: (member, stage) {
                        final svc = ref.read(whatsAppServiceProvider);
                        final msg = svc.buildBotMessage(
                          member: member,
                          stage: stage,
                          adminNumber: adminNumber,
                        );
                        svc.openWhatsApp(
                          phone: member.phone!,
                          message: msg,
                          recipientName: member.name,
                          templateLabel: 'Auto Due Bot',
                        );
                      },
                    ),

                    // Tab 2: Broadcast Hub
                    _BroadcastTab(
                      audience: _audience,
                      template: _template,
                      customBodyCtrl: _customBodyCtrl,
                      holidayMsgCtrl: _holidayMsgCtrl,
                      announcementCtrl: _announcementCtrl,
                      previewCtrl: _previewCtrl,
                      isManuallyEdited: _previewManuallyEdited,
                      pickedMember: _pickedMember,
                      adminNumber: adminNumber,
                      sending: _sending,
                      membersAsync: membersAsync,
                      onPreviewEdited: () => setState(() => _previewManuallyEdited = true),
                      onResetPreview: () => setState(() => _syncPreview(adminNumber, force: true)),
                      onAudienceChanged: (a) => setState(() {
                        _audience = a;
                        _syncPreview(adminNumber);
                      }),
                      onTemplateChanged: (t) => setState(() {
                        _template = t;
                        _syncPreview(adminNumber);
                      }),
                      onPickMember: (m) => setState(() {
                        _pickedMember = m;
                        _syncPreview(adminNumber);
                      }),
                      onSendAll: (all) => _sendMessages(all, adminNumber),
                      onSendFiltered: (filtered) => _sendMessages(filtered, adminNumber),
                      filterMembers: (all) => _filterMembers(all, adminNumber),
                    ),

                    // Tab 3: Students Directory
                    _StudentsTab(
                      searchCtrl: _memberSearchCtrl,
                      search: _memberSearch,
                      onSearchChanged: (s) => setState(() => _memberSearch = s),
                      membersAsync: membersAsync,
                      adminNumber: adminNumber,
                      svc: ref.read(whatsAppServiceProvider),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tab 1: Auto Bot Engine ──────────────────────────────────────────────────────
class _BotEngineTab extends StatelessWidget {
  final AsyncValue membersAsync;
  final String adminNumber;
  final bool botActive;
  final bool sending;
  final ValueChanged<bool> onToggleBot;
  final Future<void> Function(List<Member>) onRunCycle;
  final void Function(Member, BotDueStage) onSendSingle;

  const _BotEngineTab({
    required this.membersAsync,
    required this.adminNumber,
    required this.botActive,
    required this.sending,
    required this.onToggleBot,
    required this.onRunCycle,
    required this.onSendSingle,
  });

  static String _todayLabel() {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return membersAsync.when(
      data: (data) {
        final allMembers = data.data as List<Member>;
        final svc = WhatsAppService();
        final queue = svc.getBotDueQueue(allMembers, adminNumber);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's Alert Banner — compact, sleek & decent
              if (queue.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E1035), Color(0xFF120920)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.6), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.22),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.bolt_rounded, color: Color(0xFFA78BFA), size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${queue.length} Student${queue.length > 1 ? 's' : ''} Due Today',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Text(
                              'Tap send to open WhatsApp directly',
                              style: TextStyle(
                                color: Color(0xFFC4B5FD),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: sending ? null : () => onRunCycle(queue.map((e) => e.member).toList()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: sending
                                ? const LinearGradient(colors: [Color(0xFF555555), Color(0xFF444444)])
                                : const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)]),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: sending
                                ? []
                                : [
                                    BoxShadow(
                                      color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                sending ? Icons.hourglass_top_rounded : Icons.send_rounded,
                                color: Colors.white,
                                size: 13,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                sending ? 'Sending...' : 'Send All',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],


              // 3. Queue List Header
              Text(
                queue.isEmpty ? 'BOT QUEUE' : 'PENDING QUEUE  •  ${queue.length} students',
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 10),

              if (queue.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1117),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E1A10)),
                  ),
                  child: Column(
                    children: [
                      const Text('✅', style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 10),
                      const Text(
                        'No Due Students Right Now',
                        style: TextStyle(color: Color(0xFFFDE68A), fontSize: 14, fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bot checks automatically on 1st, 3rd, 5th & +12h of each month.\nLinked to +91 $adminNumber',
                        style: const TextStyle(color: Color(0xFF777777), fontSize: 11.5, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C160B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'Today: ${_todayLabel()}',
                          style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: queue.length,
                  itemBuilder: (ctx, i) {
                    final item = queue[i];
                    Color stageColor;
                    Color stageBg;

                    switch (item.stage) {
                      case BotDueStage.stage1Day1:
                        stageColor = const Color(0xFF60A5FA);
                        stageBg = const Color(0x333B82F6);
                        break;
                      case BotDueStage.stage2Day3:
                        stageColor = const Color(0xFFC084FC);
                        stageBg = const Color(0x338B5CF6);
                        break;
                      case BotDueStage.stage3Day5:
                        stageColor = const Color(0xFFF87171);
                        stageBg = const Color(0x33EF4444);
                        break;
                      case BotDueStage.stage4Day5Plus12h:
                        stageColor = const Color(0xFFFCA5A5);
                        stageBg = const Color(0x33DC2626);
                        break;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14120E),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: stageColor.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: stageBg,
                            child: Text(
                              item.member.name.isNotEmpty ? item.member.name[0].toUpperCase() : 'S',
                              style: TextStyle(color: stageColor, fontWeight: FontWeight.w900),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.member.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: stageBg,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: stageColor.withValues(alpha: 0.6), width: 0.8),
                                      ),
                                      child: Text(
                                        item.stageBadge,
                                        style: TextStyle(color: stageColor, fontSize: 9.5, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Seat: ${item.member.currentSeatNumber ?? 'Hold'}',
                                      style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => onSendSingle(item.member, item.stage),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFD4AF37), width: 0.8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  WhatsAppLogo(size: 14, color: Color(0xFFFDE68A)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Send',
                                    style: TextStyle(color: Color(0xFFFDE68A), fontSize: 11, fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
    );
  }

}

// ── Tab 2: Broadcast Tab ────────────────────────────────────────────────────────
class _BroadcastTab extends StatelessWidget {
  final _Audience audience;
  final WaTemplate template;
  final TextEditingController customBodyCtrl;
  final TextEditingController holidayMsgCtrl;
  final TextEditingController announcementCtrl;
  final TextEditingController previewCtrl;
  final bool isManuallyEdited;
  final Member? pickedMember;
  final String adminNumber;
  final bool sending;
  final AsyncValue membersAsync;
  final VoidCallback onPreviewEdited;
  final VoidCallback onResetPreview;
  final ValueChanged<_Audience> onAudienceChanged;
  final ValueChanged<WaTemplate> onTemplateChanged;
  final ValueChanged<Member?> onPickMember;
  final Future<void> Function(List<Member>) onSendAll;
  final Future<void> Function(List<Member>) onSendFiltered;
  final List<Member> Function(List<Member>) filterMembers;

  const _BroadcastTab({
    required this.audience,
    required this.template,
    required this.customBodyCtrl,
    required this.holidayMsgCtrl,
    required this.announcementCtrl,
    required this.previewCtrl,
    required this.isManuallyEdited,
    required this.pickedMember,
    required this.adminNumber,
    required this.sending,
    required this.membersAsync,
    required this.onPreviewEdited,
    required this.onResetPreview,
    required this.onAudienceChanged,
    required this.onTemplateChanged,
    required this.onPickMember,
    required this.onSendAll,
    required this.onSendFiltered,
    required this.filterMembers,
  });

  void _showAiPromptDialog(BuildContext context) {
    final promptCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161022),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFA855F7), width: 1.2),
        ),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: Color(0xFFC084FC), size: 22),
            SizedBox(width: 8),
            Text(
              'AI Message Writer',
              style: TextStyle(color: Color(0xFFFDE68A), fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Type your notice in simple words (English/Hindi). AI will format it with emojis, bold text & official library style:',
              style: TextStyle(color: Color(0xFFC5B38B), fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: promptCtrl,
              maxLines: 4,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g., Library will remain closed tomorrow 2 PM for AC maintenance...',
                hintStyle: const TextStyle(color: Color(0xFF777777), fontSize: 12),
                filled: true,
                fillColor: const Color(0xFF0F0B18),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4C1D95)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4C1D95)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFA855F7), width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF888888))),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA855F7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final text = promptCtrl.text.trim();
              if (text.isNotEmpty) {
                final generated = WhatsAppAiService.instance.generateFromTopic(
                  text,
                  adminNumber: adminNumber,
                );
                previewCtrl.text = generated;
                onPreviewEdited();
                Navigator.pop(ctx);
              }
            },
            icon: const Icon(Icons.bolt_rounded, size: 16),
            label: const Text('Generate with AI', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _aiChip({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return membersAsync.when(
      data: (data) {
        final allMembers = data.data as List<Member>;
        final filtered = filterMembers(allMembers);
        final activeChip = _filterChips.firstWhere((c) => c.audience == audience);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Unified Action Cards: All Members vs Filtered Audience ────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card 1: All Students (1-Tap Broadcast)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2A1F0D), Color(0xFF140F05)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.groups_rounded, color: Color(0xFFFDE68A), size: 16),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'All Students',
                                  style: TextStyle(color: Color(0xFFFDE68A), fontSize: 12.5, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${allMembers.length} Registered',
                            style: const TextStyle(color: Color(0xFFB8975A), fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: sending ? null : () => onSendAll(allMembers),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFD4AF37), Color(0xFFF59E0B)],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.send_rounded, color: Colors.black, size: 13),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Send All (${allMembers.length})',
                                      style: const TextStyle(color: Colors.black, fontSize: 11.5, fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Card 2: Filtered Card (Work as Filter Selector & Filtered Dispatch)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [activeChip.bg, const Color(0xFF100D1A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: activeChip.color.withValues(alpha: 0.6), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: activeChip.color.withValues(alpha: 0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (ctx) => _AudienceFilterSheet(
                                  selected: audience,
                                  onSelected: (a) {
                                    onAudienceChanged(a);
                                    Navigator.pop(ctx);
                                  },
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: activeChip.color.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(activeChip.icon, color: activeChip.color, size: 16),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    activeChip.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: activeChip.color, fontSize: 12, fontWeight: FontWeight.w900),
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down_rounded, color: Colors.white70, size: 20),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${filtered.length} Students Selected',
                            style: TextStyle(color: activeChip.color.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              // Change Filter button
                              Expanded(
                                flex: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (ctx) => _AudienceFilterSheet(
                                        selected: audience,
                                        onSelected: (a) {
                                          onAudienceChanged(a);
                                          Navigator.pop(ctx);
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 9),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF14120E),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: activeChip.color.withValues(alpha: 0.5)),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.tune_rounded, color: activeChip.color, size: 12),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Filter',
                                            style: TextStyle(color: activeChip.color, fontSize: 11, fontWeight: FontWeight.w800),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Send Filtered button
                              Expanded(
                                flex: 5,
                                child: GestureDetector(
                                  onTap: sending || filtered.isEmpty ? null : () => onSendFiltered(filtered),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 9),
                                    decoration: BoxDecoration(
                                      gradient: filtered.isEmpty
                                          ? const LinearGradient(colors: [Color(0xFF333333), Color(0xFF222222)])
                                          : LinearGradient(
                                              colors: [activeChip.color, activeChip.color.withValues(alpha: 0.75)],
                                            ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Send (${filtered.length})',
                                        style: TextStyle(
                                          color: filtered.isEmpty ? Colors.grey : Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Individual Student Picker Card if individual audience selected
              if (audience == _Audience.individual) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDialog<Member>(
                      context: context,
                      builder: (ctx) => _MemberPickerDialog(members: allMembers),
                    );
                    onPickMember(picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF082535),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF0EA5E9), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_search_rounded, color: Color(0xFF38BDF8), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pickedMember?.name ?? 'Tap to select student from directory...',
                                style: TextStyle(
                                  color: pickedMember != null ? Colors.white : const Color(0xFF888888),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (pickedMember != null)
                                Text(
                                  'Phone: ${pickedMember!.phone ?? 'N/A'} • Seat: ${pickedMember!.currentSeatNumber ?? 'Hold'}',
                                  style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11),
                                ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Color(0xFF38BDF8), size: 18),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // ── 2. Message Templates (Multicolour Palette) ───────────────────
              const Text(
                'CHOOSE MESSAGE TEMPLATE',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              ...waTemplates.map((t) {
                final isSel = template == t.key;
                Color tColor;
                Color tBg;

                switch (t.key) {
                  case WaTemplate.feeReminder:
                    tColor = const Color(0xFFF59E0B); // Warm Gold / Amber
                    tBg = const Color(0xFF2A1C08);
                    break;
                  case WaTemplate.membershipExpiring:
                    tColor = const Color(0xFF3B82F6); // Royal Sapphire Blue
                    tBg = const Color(0xFF0C192E);
                    break;
                  case WaTemplate.welcome:
                    tColor = const Color(0xFF10B981); // Emerald Green
                    tBg = const Color(0xFF062B1D);
                    break;
                  case WaTemplate.holidayClosed:
                    tColor = const Color(0xFFEC4899); // Velvet Pink
                    tBg = const Color(0xFF2C0B1B);
                    break;
                  case WaTemplate.announcement:
                    tColor = const Color(0xFF14B8A6); // Sea Green / Deep Teal
                    tBg = const Color(0xFF072421);
                    break;
                  case WaTemplate.custom:
                    tColor = const Color(0xFFA855F7); // Royal Amethyst Purple
                    tBg = const Color(0xFF1F0B36);
                    break;
                }

                return GestureDetector(
                  onTap: () => onTemplateChanged(t.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSel ? tBg : const Color(0xFF14120E),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSel ? tColor : const Color(0xFF252018),
                        width: isSel ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(t.emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.label,
                                style: TextStyle(
                                  color: isSel ? tColor : Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                t.description,
                                style: const TextStyle(color: Color(0xFF777777), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        if (isSel)
                          Icon(Icons.check_circle_rounded, color: tColor, size: 18),
                      ],
                    ),
                  ),
                );
              }),

              // Custom Input Fields (if template needs body)
              if (template == WaTemplate.custom) ...[
                const SizedBox(height: 8),
                _textArea('Custom Message Body', customBodyCtrl, 'Write your announcement or notice here...', 4),
              ] else if (template == WaTemplate.holidayClosed) ...[
                const SizedBox(height: 8),
                _textArea('Holiday Notice Details', holidayMsgCtrl, 'e.g. Library will remain closed on 2nd Oct for Gandhi Jayanti.', 3),
              ] else if (template == WaTemplate.announcement) ...[
                const SizedBox(height: 8),
                _textArea('Announcement Content', announcementCtrl, 'e.g. Free Wi-Fi upgraded to 300 Mbps high speed!', 3),
              ],

              const SizedBox(height: 18),

              // ── 3. Live WhatsApp Preview (Editable with AI Writing Assistant) ──
              Row(
                children: [
                  const WhatsAppLogo(size: 16, color: Color(0xFFFDE68A)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'LIVE WHATSAPP PREVIEW (EDITABLE)',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  if (isManuallyEdited)
                    GestureDetector(
                      onTap: onResetPreview,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2215),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh_rounded, color: Color(0xFFD4AF37), size: 12),
                            SizedBox(width: 4),
                            Text('Reset', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // AI Writing Assistant Toolbar
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E1035), Color(0xFF100C1F)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.45)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, color: Color(0xFFC084FC), size: 15),
                          SizedBox(width: 5),
                          Text('AI Writer:', style: TextStyle(color: Color(0xFFDDD6FE), fontSize: 11, fontWeight: FontWeight.w800)),
                          SizedBox(width: 8),
                        ],
                      ),
                      _aiChip(
                        label: '✨ AI Polish',
                        color: const Color(0xFFA855F7), // Royal Purple
                        onTap: () {
                          final polished = WhatsAppAiService.instance.polishAndFormat(
                            previewCtrl.text,
                            adminNumber: adminNumber,
                          );
                          previewCtrl.text = polished;
                          onPreviewEdited();
                        },
                      ),
                      const SizedBox(width: 6),
                      _aiChip(
                        label: '🙏 Polite Tone',
                        color: const Color(0xFF10B981), // Emerald Green
                        onTap: () {
                          final polite = WhatsAppAiService.instance.makePolite(
                            previewCtrl.text,
                            adminNumber: adminNumber,
                          );
                          previewCtrl.text = polite;
                          onPreviewEdited();
                        },
                      ),
                      const SizedBox(width: 6),
                      _aiChip(
                        label: '⚡ Urgent',
                        color: const Color(0xFFEF4444), // Crimson Red
                        onTap: () {
                          final urgent = WhatsAppAiService.instance.makeUrgent(
                            previewCtrl.text,
                            adminNumber: adminNumber,
                          );
                          previewCtrl.text = urgent;
                          onPreviewEdited();
                        },
                      ),
                      const SizedBox(width: 6),
                      _aiChip(
                        label: '🇮🇳 Hindi + English',
                        color: const Color(0xFFF59E0B), // Warm Amber
                        onTap: () {
                          final hindi = WhatsAppAiService.instance.makeBilingualHindi(
                            previewCtrl.text,
                            adminNumber: adminNumber,
                          );
                          previewCtrl.text = hindi;
                          onPreviewEdited();
                        },
                      ),
                      const SizedBox(width: 6),
                      _aiChip(
                        label: '🪄 Custom AI Prompt',
                        color: const Color(0xFF38BDF8), // Cyan / Sky Blue
                        onTap: () => _showAiPromptDialog(context),
                      ),
                    ],
                  ),
                ),
              ),

              // Editable Message Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0D09),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isManuallyEdited
                        ? const Color(0xFF10B981).withValues(alpha: 0.6)
                        : const Color(0xFFD4AF37).withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: previewCtrl,
                      maxLines: 8,
                      minLines: 4,
                      onChanged: (_) => onPreviewEdited(),
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 12.5,
                        height: 1.45,
                        fontFamily: 'monospace',
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: 'Type or edit your WhatsApp message...',
                        hintStyle: TextStyle(color: Color(0xFF555555), fontSize: 12),
                      ),
                    ),
                    const Divider(color: Color(0x33D4AF37), height: 16),
                    Row(
                      children: [
                        const Text(
                          'Placeholders: {name}, {seat}, {phone}',
                          style: TextStyle(color: Color(0xFF777777), fontSize: 10),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: previewCtrl.text));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Message copied!'),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ));
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.copy_rounded, color: Color(0xFFFDE68A), size: 14),
                              SizedBox(width: 4),
                              Text('Copy', style: TextStyle(color: Color(0xFFFDE68A), fontSize: 11, fontWeight: FontWeight.w700)),
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
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
    );
  }

  Widget _textArea(String label, TextEditingController ctrl, String hint, int lines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: lines,
          style: const TextStyle(color: Colors.white, fontSize: 12.5),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF555555), fontSize: 12),
            filled: true,
            fillColor: const Color(0xFF14120E),
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF332815)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF332815)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tab 3: Students Directory ───────────────────────────────────────────────────
class _StudentsTab extends StatelessWidget {
  final TextEditingController searchCtrl;
  final String search;
  final ValueChanged<String> onSearchChanged;
  final AsyncValue membersAsync;
  final String adminNumber;
  final WhatsAppService svc;

  const _StudentsTab({
    required this.searchCtrl,
    required this.search,
    required this.onSearchChanged,
    required this.membersAsync,
    required this.adminNumber,
    required this.svc,
  });

  @override
  Widget build(BuildContext context) {
    return membersAsync.when(
      data: (data) {
        final all = data.data as List<Member>;
        final filtered = search.isEmpty
            ? all
            : all.where((m) =>
                m.name.toLowerCase().contains(search.toLowerCase()) ||
                (m.phone ?? '').contains(search)).toList();

        return Column(
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
              child: TextField(
                controller: searchCtrl,
                onChanged: onSearchChanged,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search student name or phone number...',
                  hintStyle: const TextStyle(color: Color(0xFF666666), fontSize: 12.5),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFD4AF37), size: 20),
                  filled: true,
                  fillColor: const Color(0xFF14120E),
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF332815)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF332815)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
                  ),
                ),
              ),
            ),

            if (filtered.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No students found.',
                    style: TextStyle(color: Color(0xFF666666), fontSize: 13),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 90),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final m = filtered[i];
                    final hasPhone = m.phone != null && m.phone!.isNotEmpty;
                    final isAct = m.isActive;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14120E),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isAct ? const Color(0x3310B981) : const Color(0x33EF4444),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: isAct ? const Color(0x2210B981) : const Color(0x22EF4444),
                            child: Text(
                              m.name.isNotEmpty ? m.name[0].toUpperCase() : 'S',
                              style: TextStyle(
                                color: isAct ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      hasPhone ? m.phone! : 'No Phone',
                                      style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: isAct ? const Color(0x2210B981) : const Color(0x22EF4444),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isAct ? 'ACTIVE' : 'EXPIRED',
                                        style: TextStyle(
                                          color: isAct ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (hasPhone)
                            GestureDetector(
                              onTap: () {
                                final msg = svc.buildMessageForMember(
                                  template: WaTemplate.feeReminder,
                                  member: m,
                                  adminNumber: adminNumber,
                                );
                                svc.openWhatsApp(
                                  phone: m.phone!,
                                  message: msg,
                                  recipientName: m.name,
                                  templateLabel: 'Direct Student Chat',
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFD4AF37), width: 0.8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    WhatsAppLogo(size: 14, color: Color(0xFFFDE68A)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Chat',
                                      style: TextStyle(color: Color(0xFFFDE68A), fontSize: 11, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            const Icon(Icons.phone_disabled_rounded, color: Color(0xFF555555), size: 18),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
    );
  }
}


// ── Audience Filter Bottom Sheet ─────────────────────────────────────────────────
class _AudienceFilterSheet extends StatelessWidget {
  final _Audience selected;
  final ValueChanged<_Audience> onSelected;

  const _AudienceFilterSheet({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final categories = <String, List<_FilterChipItem>>{};
    for (final chip in _filterChips) {
      categories.putIfAbsent(chip.category, () => []).add(chip);
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E170C), Color(0xFF100C05)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5), width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 44, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.filter_list_rounded, color: Color(0xFFFDE68A), size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AUDIENCE FILTER SELECTOR',
                        style: TextStyle(
                          color: Color(0xFFFDE68A),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.7,
                        ),
                      ),
                      Text(
                        'Select due dates, enrollment status, or individual student',
                        style: TextStyle(color: Color(0xFF999999), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF221A0E),
                    ),
                    child: const Icon(Icons.close_rounded, color: Color(0xFFD4AF37), size: 16),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF2A2215), height: 1),
          // Structured Categorized List
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
              children: [
                for (final entry in categories.entries) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 12, bottom: 6),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  for (final item in entry.value) ...[
                    GestureDetector(
                      onTap: () => onSelected(item.audience),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected == item.audience ? item.bg : const Color(0xFF14120E),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected == item.audience ? item.color : const Color(0xFF2A2215),
                            width: selected == item.audience ? 1.5 : 1,
                          ),
                          boxShadow: selected == item.audience
                              ? [BoxShadow(color: item.color.withValues(alpha: 0.18), blurRadius: 8)]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: item.color.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: item.color.withValues(alpha: 0.4)),
                              ),
                              child: Center(
                                child: Icon(item.icon, color: item.color, size: 18),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      color: selected == item.audience ? item.color : Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.subtitle,
                                    style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            if (selected == item.audience)
                              Icon(Icons.check_circle_rounded, color: item.color, size: 20)
                            else
                              const Icon(Icons.chevron_right_rounded, color: Color(0xFF444444), size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Member Picker Dialog ─────────────────────────────────────────────────────────
class _MemberPickerDialog extends StatefulWidget {
  final List<Member> members;
  const _MemberPickerDialog({required this.members});

  @override
  State<_MemberPickerDialog> createState() => _MemberPickerDialogState();
}

class _MemberPickerDialogState extends State<_MemberPickerDialog> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _search.isEmpty
        ? widget.members
        : widget.members.where((m) =>
            m.name.toLowerCase().contains(_search.toLowerCase()) ||
            (m.phone ?? '').contains(_search)).toList();

    return Dialog(
      backgroundColor: const Color(0xFF14120E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.55,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Select Student',
                style: TextStyle(color: Color(0xFFFDE68A), fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                autofocus: true,
                onChanged: (s) => setState(() => _search = s),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search student name or phone...',
                  hintStyle: const TextStyle(color: Color(0xFF666666)),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFD4AF37), size: 18),
                  filled: true,
                  fillColor: const Color(0xFF100C05),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF332815)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF332815)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final m = filtered[i];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                      child: Text(
                        m.name.isNotEmpty ? m.name[0].toUpperCase() : 'S',
                        style: const TextStyle(color: Color(0xFFFDE68A), fontWeight: FontWeight.w800),
                      ),
                    ),
                    title: Text(m.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                    subtitle: Text(m.phone ?? 'No Phone', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11)),
                    onTap: () => Navigator.pop(ctx, m),
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
