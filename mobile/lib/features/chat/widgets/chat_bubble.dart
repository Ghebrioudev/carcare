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
    final bubbleColor = _isUser ? AppTheme.primary : Colors.white;
    final textColor = _isUser ? Colors.white : AppTheme.textPrimary;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: _isUser ? const Radius.circular(20) : const Radius.circular(6),
      bottomRight: _isUser ? const Radius.circular(6) : const Radius.circular(20),
    );

    final shadowColor = Colors.black.withValues(alpha: 0.05);

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment:
              _isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: textColor,
                      height: 1.35,
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
