import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final aiChatRepositoryProvider = Provider<AiChatRepository>((ref) {
  return AiChatRepository(ref.read(apiClientProvider));
});

class ChatMessage {
  final String role; // 'user' | 'model'
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.text,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'role': role,
        'text': text,
      };
}

class AiChatRepository {
  final ApiClient _apiClient;

  AiChatRepository(this._apiClient);

  Future<String> sendMessage({
    required String message,
    required List<ChatMessage> history,
    String? branchId,
  }) async {
    final payload = {
      'message': message,
      'history': history
          .where((m) => m.role == 'user' || m.role == 'model')
          .take(10)
          .map((e) => e.toJson())
          .toList(),
      if (branchId != null && branchId.isNotEmpty) 'branchId': branchId,
    };

    try {
      // 1. Try authenticated / primary endpoint first
      final response = await _apiClient.dio.post(
        ApiEndpoints.aiChat,
        data: payload,
      );
      return _extractReply(response.data);
    } catch (_) {
      // 2. If primary fails for ANY reason (auth expired, token error, network hiccup), try public endpoint
      try {
        final publicResponse = await _apiClient.dio.post(
          ApiEndpoints.aiChatPublic,
          data: payload,
        );
        return _extractReply(publicResponse.data);
      } catch (_) {
        // 3. Fallback graceful message so the user never sees a broken screen
        return '**ChintaMani AI (Offline Mode)**\n\n'
            'I am momentarily unable to reach the cloud server. Here are the core library details:\n\n'
            '• **Library Hours:** 06:00 AM – 11:00 PM (All 365 days)\n'
            '• **Director Helpline:** +91 9415919277 / +91 7388389944\n'
            '• **Campuses:** Khalilabad Campus & Mehdawal Campus\n'
            '• **Facilities:** 5G Wi-Fi, RO Water, 100% Power Backup, AC\n\n'
            'Please check your internet connection or try again in a few moments.';
      }
    }
  }

  String _extractReply(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      // Handle wrapped { data: { reply: ... } } or flat { reply: ... }
      final inner = responseData['data'];
      if (inner is Map<String, dynamic> && inner.containsKey('reply')) {
        return (inner['reply'] as String?) ?? _defaultMessage;
      }
      return (responseData['reply'] as String?) ?? _defaultMessage;
    }
    return _defaultMessage;
  }

  static const String _defaultMessage =
      'ChintaMani AI is online. How can I assist you today?';
}
