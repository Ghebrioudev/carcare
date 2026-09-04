import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  static final DateFormat _timeFormat = DateFormat.jm();

  bool get _isUser => message.role == ChatRole.user;

  @override
  Widget build(BuildContext context) {
    final alignment = _isUser ? Alignment.centerRight : Alignment.centerLeft;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: _isUser ? const Radius.circular(20) : const Radius.circular(6),
      bottomRight: _isUser ? const Radius.circular(6) : const Radius.circular(20),
    );

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.80,
        ),
        child: Column(
          crossAxisAlignment:
              _isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: _isUser ? AppTheme.primaryGradient : null,
                color: _isUser ? null : AppTheme.surface1,
                borderRadius: borderRadius,
                border: Border.all(
                  color: _isUser
                      ? AppTheme.primaryLight.withValues(alpha: 0.4)
                      : AppTheme.border,
                  width: 1.0,
                ),
                boxShadow: _isUser
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : AppTheme.subtleShadow,
              ),
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
                child: SelectableText(
                  message.content,
                  textWidthBasis: TextWidthBasis.parent,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _isUser ? 4 : 8),
              child: Text(
                _timeFormat.format(message.timestamp),
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
