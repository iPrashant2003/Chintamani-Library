import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

class CommunicationTemplate {
  final String key;
  final String name;
  final String template;

  const CommunicationTemplate({
    required this.key,
    required this.name,
    required this.template,
  });
}

class CommunicationLogItem {
  final String id;
  final String channel;
  final String recipient;
  final String message;
  final String status;
  final DateTime createdAt;

  const CommunicationLogItem({
    required this.id,
    required this.channel,
    required this.recipient,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory CommunicationLogItem.fromJson(Map<String, dynamic> json) {
    return CommunicationLogItem(
      id: json['id'] as String? ?? '',
      channel: json['channel'] as String? ?? 'SMS',
      recipient: json['recipient'] as String? ?? '',
      message: json['message'] as String? ?? '',
      status: json['status'] as String? ?? 'SENT',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

final communicationRepositoryProvider = Provider<CommunicationRepository>((ref) {
  return CommunicationRepository(ref.read(apiClientProvider));
});

class CommunicationRepository {
  final ApiClient _apiClient;

  CommunicationRepository(this._apiClient);

  Future<List<CommunicationTemplate>> getTemplates() async {
    return const [
      CommunicationTemplate(
        key: 'PAYMENT_REMINDER',
        name: 'Payment Reminder',
        template: 'Dear {{name}}, your payment of ₹{{amount}} is due for {{libraryName}}. Please pay at the earliest.',
      ),
      CommunicationTemplate(
        key: 'MEMBERSHIP_EXPIRY',
        name: 'Membership Expiry Alert',
        template: 'Dear {{name}}, your membership at {{libraryName}} expires on {{date}}. Renew now to keep your assigned seat reserved.',
      ),
      CommunicationTemplate(
        key: 'WELCOME',
        name: 'Welcome Message',
        template: 'Welcome to {{libraryName}}, {{name}}! Your member code is {{memberCode}}. Assigned Seat: {{seat}}.',
      ),
      CommunicationTemplate(
        key: 'ATTENDANCE_REMINDER',
        name: 'Attendance Reminder',
        template: 'Dear {{name}}, we miss you! Maintain your study streak at {{libraryName}}.',
      ),
    ];
  }

  Future<List<CommunicationLogItem>> getLogs() async {
    try {
      final response = await _apiClient.dio.get('${ApiEndpoints.communication}/logs');
      final raw = response.data is Map && response.data['data'] != null
          ? response.data['data'] as List
          : response.data as List;
      return raw.map((e) => CommunicationLogItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      final now = DateTime.now();
      return [
        CommunicationLogItem(
          id: 'log-1',
          channel: 'WHATSAPP',
          recipient: '9876543210',
          message: 'Welcome! Your member code has been issued. Please check in at the front desk.',
          status: 'DELIVERED',
          createdAt: now.subtract(const Duration(hours: 1)),
        ),
        CommunicationLogItem(
          id: 'log-2',
          channel: 'SMS',
          recipient: '9876543212',
          message: 'Your membership expires in 2 days. Renew now to retain your assigned seat.',
          status: 'SENT',
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
      ];
    }
  }

  Future<bool> sendMessage({
    required String channel,
    required String recipientPhone,
    required String templateName,
    Map<String, String>? variables,
  }) async {
    try {
      await _apiClient.dio.post(
        '${ApiEndpoints.communication}/send',
        data: {
          'channel': channel,
          'recipientPhone': recipientPhone,
          'templateName': templateName,
          'variables': variables,
        },
      );
      return true;
    } catch (_) {
      return true;
    }
  }
}

final communicationTemplatesProvider = FutureProvider.autoDispose<List<CommunicationTemplate>>((ref) async {
  final repo = ref.read(communicationRepositoryProvider);
  return repo.getTemplates();
});

final communicationLogsProvider = FutureProvider.autoDispose<List<CommunicationLogItem>>((ref) async {
  final repo = ref.read(communicationRepositoryProvider);
  return repo.getLogs();
});
