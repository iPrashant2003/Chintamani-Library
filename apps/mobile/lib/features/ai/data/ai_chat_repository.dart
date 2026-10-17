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
    final response = await _apiClient.dio.post(
      ApiEndpoints.aiChat,
      data: {
        'message': message,
        'history': history.map((e) => e.toJson()).toList(),
        if (branchId != null) 'branchId': branchId,
      },
    );

    final Map<String, dynamic> data = response.data is Map<String, dynamic>
        ? (response.data['data'] is Map<String, dynamic>
            ? response.data['data'] as Map<String, dynamic>
            : response.data as Map<String, dynamic>)
        : <String, dynamic>{};

    return data['reply'] as String? ??
        'ChintaMani AI is online and operational. How can I assist you with library operations?';
  }
}
