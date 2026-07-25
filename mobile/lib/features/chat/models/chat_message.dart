import 'package:flutter/foundation.dart';

enum ChatRole { user, assistant }

@immutable
class ChatMessage {
  final ChatRole role;
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessage.user(String content) => ChatMessage(
        role: ChatRole.user,
        content: content,
        timestamp: DateTime.now(),
      );

  factory ChatMessage.assistant(String content) => ChatMessage(
        role: ChatRole.assistant,
        content: content,
        timestamp: DateTime.now(),
      );

  Map<String, dynamic> toHistoryJson() => {
        'role': role.name,
        'content': content,
      };

  static ChatRole _roleFromJson(String role) =>
      role == 'assistant' ? ChatRole.assistant : ChatRole.user;

  factory ChatMessage.fromHistoryJson(Map<String, dynamic> json) => ChatMessage(
        role: _roleFromJson(json['role'] as String? ?? 'user'),
        content: json['content'] as String? ?? '',
        timestamp: DateTime.now(),
      );
}
