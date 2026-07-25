import '../../../core/network/api_client.dart';
import '../models/chat_message.dart';

class ChatRepository {
  final ApiClient _apiClient;

  ChatRepository(this._apiClient);

  Future<ChatMessage> sendMessage({
    required String message,
    required List<ChatMessage> history,
  }) async {
    final response = await _apiClient.post('/chat', data: {
      'message': message,
      'history': history.map((m) => m.toHistoryJson()).toList(),
    });

    final data = response['data'] as Map<String, dynamic>;
    final reply = data['reply'] as String? ?? '';

    return ChatMessage.assistant(reply);
  }
}
