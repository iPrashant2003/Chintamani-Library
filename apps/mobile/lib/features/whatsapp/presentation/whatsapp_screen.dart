import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/ambient_background.dart';
import '../../../widgets/whatsapp_logo.dart';
import '../../members/data/member_repository.dart';
import '../../members/domain/member_model.dart';
import '../data/whatsapp_service.dart';

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
  final String label;
  final Color color;
  final Color bg;

  const _FilterChipItem({
    required this.audience,
    required this.label,
    required this.color,
    required this.bg,
  });
}

const _filterChips = [
  _FilterChipItem(
    audience: _Audience.all,
    label: '🌟 All Members',
    color: Color(0xFFFDE68A),
    bg: Color(0x33D4AF37),
  ),
  _FilterChipItem(
    audience: _Audience.botDue,
    label: '🤖 Bot Due Queue',
    color: Color(0xFFC084FC),
    bg: Color(0x33A855F7),
  ),
  _FilterChipItem(
    audience: _Audience.stage1_1st,
    label: '🔵 1st of Month (Day 1)',
    color: Color(0xFF60A5FA),
    bg: Color(0x333B82F6),
  ),
  _FilterChipItem(
    audience: _Audience.stage2_3rd,
    label: '🟣 3rd of Month (Day 3)',
    color: Color(0xFFC084FC),
    bg: Color(0x338B5CF6),
  ),
  _FilterChipItem(
    audience: _Audience.stage3_5th,
    label: '🔴 5th of Month (Final)',
    color: Color(0xFFF87171),
    bg: Color(0x33EF4444),
  ),
  _FilterChipItem(
    audience: _Audience.stage4_12h,
    label: '🚨 +12h Deallocation',
    color: Color(0xFFFCA5A5),
    bg: Color(0x33DC2626),
  ),
  _FilterChipItem(
    audience: _Audience.active,
    label: '🟢 Active Students',
    color: Color(0xFF34D399),
    bg: Color(0x3310B981),
  ),
  _FilterChipItem(
    audience: _Audience.expiring,
    label: '⏰ Expiring (≤15 Days)',
    color: Color(0xFFFBBF24),
    bg: Color(0x33F59E0B),
  ),
  _FilterChipItem(
    audience: _Audience.expired,
    label: '❌ Expired / Overdue',
    color: Color(0xFFF87171),
    bg: Color(0x33EF4444),
  ),
  _FilterChipItem(
    audience: _Audience.individual,
    label: '👤 Pick Student',
    color: Color(0xFF38BDF8),
    bg: Color(0x330EA5E9),
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
  Member? _pickedMember;
  bool _sending = false;

  // Settings tab state
  final _adminNumberCtrl = TextEditingController();
  bool _savingNumber = false;
  bool _botActive = true;

  // Members tab search
  final _memberSearchCtrl = TextEditingController();
  String _memberSearch = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final num = await ref.read(whatsAppServiceProvider).getAdminNumber();
    final active = await ref.read(whatsAppServiceProvider).isBotActive();
    if (mounted) {
      setState(() {
        _adminNumberCtrl.text = num;
        _botActive = active;
      });
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _customBodyCtrl.dispose();
    _holidayMsgCtrl.dispose();
    _announcementCtrl.dispose();
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

      if (isBotQueue || _audience == _Audience.botDue || _audience == _Audience.stage1_1st ||
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
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2A1F0D), Color(0xFF140F05)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: WhatsAppLogo(size: 22, color: Color(0xFFFDE68A)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CHINTA MANI WHATSAPP',
                          style: TextStyle(
                            color: Color(0xFFFDE68A),
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Bot Active: +91 $adminNumber',
                              style: const TextStyle(
                                color: Color(0xFFD4AF37),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Tab Bar: Luxury Golden Obsidian ──────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xF21C160B), Color(0xF8100C05)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.40),
                    width: 1,
                  ),
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  indicator: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: const Color(0xFFFDE68A),
                  unselectedLabelColor: const Color(0xFFD4AF37).withValues(alpha: 0.70),
                  labelStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                  unselectedLabelStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                  padding: const EdgeInsets.all(3),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: '🤖 Auto Bot'),
                    Tab(text: '📤 Broadcast'),
                    Tab(text: '👥 Students'),
                    Tab(text: '⚙️ Settings'),
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
                      pickedMember: _pickedMember,
                      adminNumber: adminNumber,
                      sending: _sending,
                      membersAsync: membersAsync,
                      preview: _buildPreview(adminNumber),
                      onAudienceChanged: (a) => setState(() => _audience = a),
                      onTemplateChanged: (t) => setState(() => _template = t),
                      onPickMember: (m) => setState(() => _pickedMember = m),
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

                    // Tab 4: Settings
                    _SettingsTab(
                      adminNumberCtrl: _adminNumberCtrl,
                      botActive: _botActive,
                      saving: _savingNumber,
                      onToggleBot: (v) async {
                        setState(() => _botActive = v);
                        await ref.read(whatsAppServiceProvider).setBotActive(v);
                      },
                      onSaveNumber: () async {
                        final num = _adminNumberCtrl.text.trim();
                        if (num.length != 10) {
                          _showSnack('Please enter a valid 10-digit mobile number', isError: true);
                          return;
                        }
                        setState(() => _savingNumber = true);
                        await ref.read(whatsAppServiceProvider).saveAdminNumber(num);
                        ref.invalidate(adminWhatsAppNumberProvider);
                        if (mounted) {
                          setState(() => _savingNumber = false);
                          _showSnack('✅ Linked WhatsApp number updated to $num');
                        }
                      },
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
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Royal Purple & Gold Bot Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E1065), Color(0xFF1E1B4B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFA855F7), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFC084FC), width: 1),
                          ),
                          child: const Text('🤖', style: TextStyle(fontSize: 22)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'AUTOMATED DUE BOT',
                                style: TextStyle(
                                  color: Color(0xFFFDE68A),
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                botActive ? 'Active Engine • Linked: $adminNumber' : 'Bot Engine Paused',
                                style: const TextStyle(color: Color(0xFFDDD6FE), fontSize: 11.5, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: botActive,
                          activeThumbColor: const Color(0xFFFDE68A),
                          activeTrackColor: const Color(0xFF7C3AED),
                          onChanged: onToggleBot,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, color: Color(0xFFFDE68A), size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Reminders trigger on 1st, 3rd, 5th, and +12h for month-end dues.',
                              style: TextStyle(color: Color(0xFFFDE68A), fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Today's Alert Banner — prominent when students are due
              if (queue.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF78350F), Color(0xFF451A03)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('⚡', style: TextStyle(fontSize: 26)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${queue.length} Student${queue.length > 1 ? 's' : ''} Due Today!',
                                  style: const TextStyle(
                                    color: Color(0xFFFDE68A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const Text(
                                  'WhatsApp will open with message ready — just tap Send',
                                  style: TextStyle(
                                    color: Color(0xFFD97706),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: sending ? null : () => onRunCycle(queue.map((e) => e.member).toList()),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: sending
                                ? const LinearGradient(colors: [Color(0xFF555555), Color(0xFF444444)])
                                : const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFF59E0B)]),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: sending
                                ? []
                                : [
                                    BoxShadow(
                                      color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send_rounded, color: Colors.black, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                sending
                                    ? 'Opening WhatsApp...'
                                    : '🚀  Send All ${queue.length} Reminders Now',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // 3. Queue List Header
              Text(
                queue.isEmpty ? 'BOT QUEUE' : 'PENDING QUEUE  •  ${queue.length} students',
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
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
  final Member? pickedMember;
  final String adminNumber;
  final bool sending;
  final AsyncValue membersAsync;
  final String preview;
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
    required this.pickedMember,
    required this.adminNumber,
    required this.sending,
    required this.membersAsync,
    required this.preview,
    required this.onAudienceChanged,
    required this.onTemplateChanged,
    required this.onPickMember,
    required this.onSendAll,
    required this.onSendFiltered,
    required this.filterMembers,
  });

  @override
  Widget build(BuildContext context) {
    return membersAsync.when(
      data: (data) {
        final allMembers = data.data as List<Member>;
        final filtered = filterMembers(allMembers);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Dual Send Actions (Send All in 1 button vs Send to Filtered)
              Row(
                children: [
                  // Button 1: Send to All Members (1-Tap)
                  Expanded(
                    child: GestureDetector(
                      onTap: sending ? null : () => onSendAll(allMembers),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFF59E0B)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.all_inclusive_rounded, color: Colors.black, size: 17),
                            const SizedBox(width: 6),
                            Text(
                              'Send All (${allMembers.length})',
                              style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Button 2: Send Based on Filter Applied
                  Expanded(
                    child: GestureDetector(
                      onTap: sending || filtered.isEmpty ? null : () => onSendFiltered(filtered),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: filtered.isEmpty
                                ? [const Color(0xFF222222), const Color(0xFF1A1A1A)]
                                : [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: filtered.isEmpty ? const Color(0xFF333333) : const Color(0xFFA855F7),
                            width: 1,
                          ),
                          boxShadow: filtered.isEmpty
                              ? []
                              : [
                                  BoxShadow(
                                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.filter_alt_rounded, color: filtered.isEmpty ? Colors.grey : Colors.white, size: 17),
                            const SizedBox(width: 6),
                            Text(
                              'Filtered (${filtered.length})',
                              style: TextStyle(
                                color: filtered.isEmpty ? Colors.grey : Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 2. Filter Selector Chips (Multi-Color)
              const Text(
                'APPLY AUDIENCE FILTER',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _filterChips.map((chip) {
                  final isSel = audience == chip.audience;
                  return GestureDetector(
                    onTap: () => onAudienceChanged(chip.audience),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSel ? chip.bg : const Color(0xFF14120E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSel ? chip.color : const Color(0xFF2A2215),
                          width: isSel ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        chip.label,
                        style: TextStyle(
                          color: isSel ? chip.color : const Color(0xFF999999),
                          fontSize: 11.5,
                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Individual picker if audience is individual
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
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14120E),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD4AF37)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_search_rounded, color: Color(0xFFFDE68A), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            pickedMember?.name ?? 'Tap to select student...',
                            style: TextStyle(
                              color: pickedMember != null ? Colors.white : const Color(0xFF777777),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (pickedMember != null)
                          Text(pickedMember!.phone ?? '', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11)),
                        const Icon(Icons.chevron_right_rounded, color: Color(0xFF555555), size: 18),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // 3. Multi-Color Template Cards
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
                    tColor = const Color(0xFFF59E0B);
                    tBg = const Color(0xFF2A1C08);
                    break;
                  case WaTemplate.membershipExpiring:
                    tColor = const Color(0xFF3B82F6);
                    tBg = const Color(0xFF0C2448);
                    break;
                  case WaTemplate.welcome:
                    tColor = const Color(0xFF10B981);
                    tBg = const Color(0xFF063327);
                    break;
                  case WaTemplate.holidayClosed:
                    tColor = const Color(0xFFA855F7);
                    tBg = const Color(0xFF2E1065);
                    break;
                  case WaTemplate.announcement:
                    tColor = const Color(0xFF0EA5E9);
                    tBg = const Color(0xFF082F49);
                    break;
                  case WaTemplate.custom:
                    tColor = const Color(0xFFEF4444);
                    tBg = const Color(0xFF3B0B0B);
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

              // Custom Input Fields
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

              // 4. Live WhatsApp Preview
              const Text(
                'LIVE WHATSAPP PREVIEW',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1C160B), Color(0xFF100C05)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const WhatsAppLogo(size: 16, color: Color(0xFFFDE68A)),
                        const SizedBox(width: 8),
                        const Text(
                          'Formatted WhatsApp Preview',
                          style: TextStyle(color: Color(0xFFFDE68A), fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: preview));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Message copied!'),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ));
                          },
                          child: const Icon(Icons.copy_rounded, color: Color(0xFFFDE68A), size: 16),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0x33D4AF37), height: 16),
                    Text(
                      preview,
                      style: const TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 12,
                        height: 1.5,
                        fontFamily: 'monospace',
                      ),
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

// ── Tab 4: Settings & Number Management ─────────────────────────────────────────
class _SettingsTab extends StatelessWidget {
  final TextEditingController adminNumberCtrl;
  final bool botActive;
  final bool saving;
  final ValueChanged<bool> onToggleBot;
  final VoidCallback onSaveNumber;

  const _SettingsTab({
    required this.adminNumberCtrl,
    required this.botActive,
    required this.saving,
    required this.onToggleBot,
    required this.onSaveNumber,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Linked Number Setting Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A1F0D), Color(0xFF140F05)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.20),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    WhatsAppLogo(size: 20, color: Color(0xFFFDE68A)),
                    SizedBox(width: 10),
                    Text(
                      'LINKED WHATSAPP NUMBER',
                      style: TextStyle(
                        color: Color(0xFFFDE68A),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Messages and automated bot reminders include this contact number for student replies.',
                  style: TextStyle(color: Color(0xFFC5B38B), fontSize: 11.5),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: adminNumberCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                  decoration: InputDecoration(
                    hintText: '7388389944',
                    hintStyle: const TextStyle(color: Color(0xFF666666)),
                    counterStyle: const TextStyle(color: Color(0xFF666666)),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      child: Text('+91 ', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w900, fontSize: 15)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF100C05),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3A2C12)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3A2C12)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: saving ? null : onSaveNumber,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFF59E0B)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.save_rounded, color: Colors.black, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Save Linked WhatsApp Number',
                                  style: TextStyle(color: Colors.black, fontSize: 13.5, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 2. How the Bot Works — simple user-friendly explanation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2215)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🤖', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text(
                      'HOW THE BOT WORKS',
                      style: TextStyle(
                        color: Color(0xFFFDE68A),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFF1E1A10), height: 1),
                const SizedBox(height: 12),
                _infoRow('📅 1st of Month', 'First payment reminder sent to overdue students'),
                _infoRow('📅 3rd of Month', 'Second alert — seat placed on hold notice'),
                _infoRow('📅 5th of Month', 'Final warning — 12 hour grace period begins'),
                _infoRow('⏰ +12 hrs after 5th', 'Seat released and student notified'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C160B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.25)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Color(0xFFD4AF37), size: 15),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'WhatsApp opens automatically with message ready. Tap Send in WhatsApp for each student.',
                          style: TextStyle(color: Color(0xFFD4AF37), fontSize: 10.5, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 11.5, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(color: Color(0xFF999999), fontSize: 11.5, height: 1.3),
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
