import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/database_backup_service.dart';
import '../../members/domain/member_model.dart';

// ── Template keys ──────────────────────────────────────────────────────────────
enum WaTemplate {
  feeReminder,
  membershipExpiring,
  welcome,
  holidayClosed,
  announcement,
  custom,
}

class WaTemplateInfo {
  final WaTemplate key;
  final String label;
  final String emoji;
  final String description;

  const WaTemplateInfo({
    required this.key,
    required this.label,
    required this.emoji,
    required this.description,
  });
}

const waTemplates = [
  WaTemplateInfo(
    key: WaTemplate.feeReminder,
    label: 'Fee Due Reminder',
    emoji: '💰',
    description: 'Remind student about pending fee payment',
  ),
  WaTemplateInfo(
    key: WaTemplate.membershipExpiring,
    label: 'Membership Expiring',
    emoji: '⏰',
    description: 'Alert about membership expiry soon',
  ),
  WaTemplateInfo(
    key: WaTemplate.welcome,
    label: 'Welcome New Member',
    emoji: '🎉',
    description: 'Greet new student with member code & seat',
  ),
  WaTemplateInfo(
    key: WaTemplate.holidayClosed,
    label: 'Holiday / Closure',
    emoji: '🏖️',
    description: 'Notify about library closed / holiday',
  ),
  WaTemplateInfo(
    key: WaTemplate.announcement,
    label: 'General Announcement',
    emoji: '📢',
    description: 'Broadcast any important notice',
  ),
  WaTemplateInfo(
    key: WaTemplate.custom,
    label: 'Custom Message',
    emoji: '✍️',
    description: 'Write your own free-form message',
  ),
];

// ── Automated Due Bot Stages ─────────────────────────────────────────────────
enum BotDueStage {
  stage1Day1, // 1st of month (Day 1 after 30/31st expiry)
  stage2Day3, // 3rd of month (Day 3 after 30/31st expiry)
  stage3Day5, // 5th of month (Day 5 after 30/31st expiry)
  stage4Day5Plus12h, // 12 hrs after 5th (Day 5.5 / 6th: Seat deallocated)
}

class BotTargetStudent {
  final Member member;
  final BotDueStage stage;
  final String stageTitle;
  final String stageBadge;
  final String message;
  final int daysOverdue;

  const BotTargetStudent({
    required this.member,
    required this.stage,
    required this.stageTitle,
    required this.stageBadge,
    required this.message,
    required this.daysOverdue,
  });
}

// ── Message History Entry ───────────────────────────────────────────────────────
class WaHistoryEntry {
  final String id;
  final String recipientName;
  final String recipientPhone;
  final String templateLabel;
  final String message;
  final DateTime sentAt;

  const WaHistoryEntry({
    required this.id,
    required this.recipientName,
    required this.recipientPhone,
    required this.templateLabel,
    required this.message,
    required this.sentAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipientName': recipientName,
        'recipientPhone': recipientPhone,
        'templateLabel': templateLabel,
        'message': message,
        'sentAt': sentAt.toIso8601String(),
      };

  factory WaHistoryEntry.fromJson(Map<String, dynamic> j) => WaHistoryEntry(
        id: j['id'] as String? ?? '',
        recipientName: j['recipientName'] as String? ?? '',
        recipientPhone: j['recipientPhone'] as String? ?? '',
        templateLabel: j['templateLabel'] as String? ?? '',
        message: j['message'] as String? ?? '',
        sentAt: DateTime.tryParse(j['sentAt'].toString()) ?? DateTime.now(),
      );
}

// ── WhatsApp Service ────────────────────────────────────────────────────────────
class WhatsAppService {
  static const _adminNumberKey = 'whatsapp_admin_number';
  static const _historyKey = 'whatsapp_history';
  static const _botActiveKey = 'whatsapp_bot_active';
  static const _defaultAdminNumber = '7388389944';
  static const _libraryHeader = '🏛️ *CHINTA MANI LIBRARY*\n━━━━━━━━━━━━━━━━━━━━━━';
  static const _libraryFooter =
      '📍 *Khalilabad* | *Mehdawal*\n\n_Chinta Mani Library — Your Study, Our Priority_ 🎯';

  // ── Admin number storage ────────────────────────────────────────────────────
  Future<String> getAdminNumber() async {
    try {
      final db = DatabaseBackupService.instance;
      final data = await db.readDatabase();
      final settings = data['settings'] as Map<String, dynamic>? ?? {};
      return settings[_adminNumberKey] as String? ?? _defaultAdminNumber;
    } catch (_) {
      return _defaultAdminNumber;
    }
  }

  Future<void> saveAdminNumber(String number) async {
    try {
      final db = DatabaseBackupService.instance;
      final data = await db.readDatabase();
      final settings = (data['settings'] as Map<String, dynamic>?) ?? {};
      settings[_adminNumberKey] = number;
      data['settings'] = settings;
      await db.writeDatabase(data);
    } catch (_) {}
  }

  // ── Bot active toggle storage ───────────────────────────────────────────────
  Future<bool> isBotActive() async {
    try {
      final db = DatabaseBackupService.instance;
      final data = await db.readDatabase();
      final settings = data['settings'] as Map<String, dynamic>? ?? {};
      return settings[_botActiveKey] as bool? ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> setBotActive(bool active) async {
    try {
      final db = DatabaseBackupService.instance;
      final data = await db.readDatabase();
      final settings = (data['settings'] as Map<String, dynamic>?) ?? {};
      settings[_botActiveKey] = active;
      data['settings'] = settings;
      await db.writeDatabase(data);
    } catch (_) {}
  }

  // ── Message history ─────────────────────────────────────────────────────────
  Future<List<WaHistoryEntry>> getHistory() async {
    try {
      final db = DatabaseBackupService.instance;
      final data = await db.readDatabase();
      final raw = data[_historyKey] as List<dynamic>? ?? [];
      final entries = raw
          .map((e) => WaHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      entries.sort((a, b) => b.sentAt.compareTo(a.sentAt));
      return entries;
    } catch (_) {
      return [];
    }
  }

  Future<void> _addToHistory(WaHistoryEntry entry) async {
    try {
      final db = DatabaseBackupService.instance;
      final data = await db.readDatabase();
      final raw = data[_historyKey] as List<dynamic>? ?? [];
      raw.insert(0, entry.toJson());
      if (raw.length > 200) raw.removeRange(200, raw.length);
      data[_historyKey] = raw;
      await db.writeDatabase(data);
    } catch (_) {}
  }

  // ── Bot Message Builder ─────────────────────────────────────────────────────
  String buildBotMessage({
    required Member member,
    required BotDueStage stage,
    required String adminNumber,
  }) {
    final name = member.name;
    final seat = member.currentSeatNumber ?? 'Assigned Seat';
    final amt = member.activeSubscription?.plan?.price.toInt().toString() ?? '600';
    final contact = '📞 *$adminNumber*';

    switch (stage) {
      case BotDueStage.stage1Day1:
        return '$_libraryHeader\n\n'
            '👤 Dear *$name*,\n\n'
            '💰 *Monthly Fee Due Reminder — Cycle 1*\n\n'
            'Your library membership expired yesterday on month end (30/31st).\n'
            'Monthly Due: *₹$amt*\n'
            'Assigned Seat: *$seat*\n\n'
            'Kindly clear your dues today (*1st of the month*) to ensure your seat remains reserved without disruption.\n\n'
            '$contact\n'
            '$_libraryFooter';

      case BotDueStage.stage2Day3:
        return '$_libraryHeader\n\n'
            '👤 Dear *$name*,\n\n'
            '⚠️ *2nd Payment Alert — Pending Dues*\n\n'
            'Your membership fee of *₹$amt* is still pending as of *3rd of the month*.\n'
            'Seat: *$seat* (Status: *Temporary Hold*)\n\n'
            'Please complete payment today to prevent cancellation of your seat.\n\n'
            '$contact\n'
            '$_libraryFooter';

      case BotDueStage.stage3Day5:
        return '$_libraryHeader\n\n'
            '👤 Dear *$name*,\n\n'
            '🚨 *FINAL NOTICE — Immediate Action Required*\n\n'
            'This is your 3rd and *FINAL fee reminder* for *₹$amt* on *5th of the month*.\n'
            'Seat: *$seat*\n\n'
            '⚠️ If payment is not confirmed within *12 hours*, your seat will be deallocated and reassigned.\n\n'
            '$contact\n'
            '$_libraryFooter';

      case BotDueStage.stage4Day5Plus12h:
        return '$_libraryHeader\n\n'
            '👤 Dear *$name*,\n\n'
            '🔒 *Seat Deallocation Notice*\n\n'
            'Due to non-payment of fee (*₹$amt*) following multiple reminders on 1st, 3rd, and 5th, your seat *$seat* has been *unreserved and released*.\n\n'
            'To restore your admission or re-book a seat, contact the front desk immediately.\n\n'
            '$contact\n'
            '$_libraryFooter';
    }
  }

  // ── Bot Queue Identification ────────────────────────────────────────────────
  List<BotTargetStudent> getBotDueQueue(List<Member> members, String adminNumber) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayOfMonth = now.day;
    final hour = now.hour;

    final queue = <BotTargetStudent>[];

    for (final m in members) {
      if (m.phone == null || m.phone!.isEmpty) continue;

      final sub = m.activeSubscription;
      bool isTarget = false;
      int daysOverdue = 0;

      // Case 1: Member explicitly inactive
      if (!m.isActive) {
        isTarget = true;
        if (sub != null) {
          daysOverdue = today.difference(DateTime(sub.endDate.year, sub.endDate.month, sub.endDate.day)).inDays;
        }
      }

      // Case 2: Has active sub but it has expired
      if (!isTarget && sub != null) {
        final endDay = DateTime(sub.endDate.year, sub.endDate.month, sub.endDate.day);
        if (endDay.isBefore(today) || endDay.isAtSameMomentAs(today)) {
          isTarget = true;
          daysOverdue = today.difference(endDay).inDays;
        }
      }

      // Case 3: Membership expired at month-end (28/29/30/31)
      if (!isTarget && sub != null) {
        final expDay = sub.endDate.day;
        final endDay = DateTime(sub.endDate.year, sub.endDate.month, sub.endDate.day);
        if (expDay >= 28 && endDay.isBefore(today)) {
          isTarget = true;
          daysOverdue = today.difference(endDay).inDays;
        }
      }

      if (!isTarget) continue;
      if (daysOverdue < 0) daysOverdue = 0;

      BotDueStage stage;
      String stageTitle;
      String stageBadge;

      // Stage by current day of month (1st, 3rd, 5th, +12h)
      if (dayOfMonth == 1 || daysOverdue == 1) {
        stage = BotDueStage.stage1Day1;
        stageTitle = '1st of Month Reminder';
        stageBadge = '1ST DUE';
      } else if (dayOfMonth <= 3 || (daysOverdue >= 2 && daysOverdue <= 3)) {
        stage = BotDueStage.stage2Day3;
        stageTitle = '3rd of Month Reminder';
        stageBadge = '3RD DUE';
      } else if ((dayOfMonth <= 5 && hour < 18) || (daysOverdue >= 4 && daysOverdue <= 5)) {
        stage = BotDueStage.stage3Day5;
        stageTitle = '5th of Month — Final Warning';
        stageBadge = '5TH FINAL';
      } else {
        // 12h after 5th or day 6+
        stage = BotDueStage.stage4Day5Plus12h;
        stageTitle = 'Seat Deallocation (+12h)';
        stageBadge = '+12H RELEASE';
      }

      queue.add(BotTargetStudent(
        member: m,
        stage: stage,
        stageTitle: stageTitle,
        stageBadge: stageBadge,
        message: buildBotMessage(member: m, stage: stage, adminNumber: adminNumber),
        daysOverdue: daysOverdue > 0 ? daysOverdue : dayOfMonth,
      ));
    }

    return queue;
  }

  // ── General Message Builders ────────────────────────────────────────────────
  String buildMessage({
    required WaTemplate template,
    required String adminNumber,
    String name = 'Student',
    String memberCode = '',
    String seat = '',
    String amount = '',
    String expiryDate = '',
    int daysLeft = 0,
    String customBody = '',
    String holidayMessage = '',
    String announcementText = '',
  }) {
    final contact = '📞 *$adminNumber*';
    switch (template) {
      case WaTemplate.feeReminder:
        return '$_libraryHeader\n\n'
            '👤 Dear *$name*,\n\n'
            '💰 *Fee Payment Reminder*\n\n'
            'Your membership fee is currently *due*. '
            '${amount.isNotEmpty ? 'Amount: *₹$amount*\n' : ''}'
            'Please pay at the earliest to keep your seat reserved.\n\n'
            '⚠️ Non-payment may result in seat deallocation.\n\n'
            '$contact\n'
            '$_libraryFooter';

      case WaTemplate.membershipExpiring:
        return '$_libraryHeader\n\n'
            '👤 Dear *$name*,\n\n'
            '⏰ *Membership Expiry Alert*\n\n'
            'Your membership is expiring${expiryDate.isNotEmpty ? ' on *$expiryDate*' : ' soon'}.\n'
            '${daysLeft > 0 ? '📅 *$daysLeft days* remaining\n' : ''}'
            '\n'
            '🔄 Renew now to keep your assigned seat *$seat* reserved!\n\n'
            '$contact\n'
            '$_libraryFooter';

      case WaTemplate.welcome:
        return '$_libraryHeader\n\n'
            '👤 Dear *$name*,\n\n'
            '🎉 *Welcome to Chinta Mani Library!*\n\n'
            '✅ Your membership is now *ACTIVE*\n'
            '${memberCode.isNotEmpty ? '🆔 Member Code: *$memberCode*\n' : ''}'
            '${seat.isNotEmpty ? '🪑 Assigned Seat: *$seat*\n' : ''}'
            '\n'
            '📚 Study hard. Dream big. Achieve greatness!\n\n'
            '$contact\n'
            '$_libraryFooter';

      case WaTemplate.holidayClosed:
        final body = holidayMessage.isNotEmpty
            ? holidayMessage
            : 'The library will remain CLOSED today.';
        return '$_libraryHeader\n\n'
            '🏖️ *Holiday / Closure Notice*\n\n'
            '$body\n\n'
            'We apologize for any inconvenience. Normal operations resume as scheduled.\n\n'
            '$contact\n'
            '$_libraryFooter';

      case WaTemplate.announcement:
        final body = announcementText.isNotEmpty
            ? announcementText
            : 'Please check the notice board for important updates.';
        return '$_libraryHeader\n\n'
            '📢 *Important Announcement*\n\n'
            '$body\n\n'
            '$contact\n'
            '$_libraryFooter';

      case WaTemplate.custom:
        if (customBody.isEmpty) return '';
        return '$_libraryHeader\n\n'
            '${name.isNotEmpty ? '👤 Dear *$name*,\n\n' : ''}'
            '$customBody\n\n'
            '$contact\n'
            '$_libraryFooter';
    }
  }

  /// Build message from a real [Member] object
  String buildMessageForMember({
    required WaTemplate template,
    required Member member,
    required String adminNumber,
    String customBody = '',
    String holidayMessage = '',
    String announcementText = '',
  }) {
    final sub = member.activeSubscription;
    final expiryDate = sub != null ? _formatDate(sub.endDate) : '';
    final daysLeft = member.daysRemaining ?? 0;
    final amt = sub?.plan?.price.toInt().toString() ?? '';
    final seat = member.currentSeatNumber ?? '';
    return buildMessage(
      template: template,
      adminNumber: adminNumber,
      name: member.name,
      memberCode: member.memberCode,
      seat: seat,
      amount: amt,
      expiryDate: expiryDate,
      daysLeft: daysLeft,
      customBody: customBody,
      holidayMessage: holidayMessage,
      announcementText: announcementText,
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  // ── URL launcher ────────────────────────────────────────────────────────────
  Future<bool> openWhatsApp({
    required String phone,
    required String message,
    String recipientName = '',
    String templateLabel = '',
  }) async {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    final fullNumber = digits.length == 10 ? '91$digits' : digits;
    final encoded = Uri.encodeComponent(message);

    HapticFeedback.mediumImpact();

    bool launched = false;

    // 1. Try direct WhatsApp URI scheme (most reliable on Android)
    try {
      final directUri = Uri.parse('whatsapp://send?phone=$fullNumber&text=$encoded');
      if (await canLaunchUrl(directUri)) {
        await launchUrl(directUri, mode: LaunchMode.externalNonBrowserApplication);
        launched = true;
      }
    } catch (_) {}

    // 2. Fall back to wa.me HTTPS URL
    if (!launched) {
      try {
        final webUrl = Uri.parse('https://wa.me/$fullNumber?text=$encoded');
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        launched = true;
      } catch (_) {}
    }

    if (launched) {
      await _addToHistory(WaHistoryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        recipientName: recipientName.isEmpty ? phone : recipientName,
        recipientPhone: digits,
        templateLabel: templateLabel,
        message: message,
        sentAt: DateTime.now(),
      ));
    }

    return launched;
  }
}

// ── Providers ───────────────────────────────────────────────────────────────────
final whatsAppServiceProvider = Provider<WhatsAppService>((ref) {
  return WhatsAppService();
});

final adminWhatsAppNumberProvider = FutureProvider<String>((ref) async {
  return ref.read(whatsAppServiceProvider).getAdminNumber();
});

final waHistoryProvider = FutureProvider.autoDispose<List<WaHistoryEntry>>((ref) async {
  return ref.read(whatsAppServiceProvider).getHistory();
});

final isWhatsAppBotActiveProvider = FutureProvider<bool>((ref) async {
  return ref.read(whatsAppServiceProvider).isBotActive();
});
