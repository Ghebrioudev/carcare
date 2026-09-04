import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_states.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_empty_state.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const List<String> _suggestions = [
    'When is my next maintenance?',
    'What service items are overdue?',
    'How much have I spent on my vehicles?',
    'Why are my brakes squeaking?',
    'Show my service history summary.',
  ];

  late final ScrollController _scrollController;
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _textController = TextEditingController();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      max + 120,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _send(String text) async {
    final provider = context.read<ChatProvider>();
    _textController.clear();
    _focusNode.unfocus();
    await provider.sendMessage(text);
    if (mounted) _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: AppTheme.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context, provider),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (provider.hasError) {
                    return AppErrorView(
                      message: provider.errorMessage!,
                      onRetry: () {
                        setState(() {});
                      },
                    );
                  }
                  if (provider.isEmpty) {
                    return ChatEmptyState(
                      suggestions: _suggestions,
                      onSuggestion: _send,
                    );
                  }
                  return _buildMessageList(provider);
                },
              ),
            ),
            _buildInputBar(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ChatProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 12),
      decoration: const BoxDecoration(
        color: AppTheme.canvas,
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF222228), Color(0xFF101014)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.primaryLight.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.primaryLight,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Assistant',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      provider.isLoading
                          ? 'Analyzing telemetry...'
                          : 'Online • Synced with your garage',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (provider.messages.isNotEmpty)
            IconButton(
              tooltip: 'Clear conversation',
              onPressed: provider.clear,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.textMuted,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatProvider provider) {
    final messages = provider.messages;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 12, bottom: 20),
      itemCount: messages.length + (provider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return const TypingIndicator();
        }
        final msg = messages[index];
        return ChatBubble(message: msg);
      },
    );
  }

  Widget _buildInputBar(BuildContext context, ChatProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 92),
      decoration: const BoxDecoration(
        color: AppTheme.canvas,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 48, maxHeight: 150),
              decoration: BoxDecoration(
                color: AppTheme.surface1,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.border, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  enabled: !provider.isLoading,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Ask anything about your vehicle...',
                    hintStyle: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 13),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty && !provider.isLoading) {
                      _send(value);
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildSendButton(context, provider),
        ],
      ),
    );
  }

  Widget _buildSendButton(BuildContext context, ChatProvider provider) {
    return ListenableBuilder(
      listenable: _textController,
      builder: (context, _) {
        final isActive =
            !provider.isLoading && _textController.text.trim().isNotEmpty;
        return GestureDetector(
          onTap: isActive ? () => _send(_textController.text) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: isActive ? AppTheme.primaryGradient : null,
              color: isActive ? null : AppTheme.surface2,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? AppTheme.primaryLight.withValues(alpha: 0.5)
                    : AppTheme.border,
                width: 1,
              ),
              boxShadow: isActive ? AppTheme.primaryGlowShadow : null,
            ),
            child: provider.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Icon(
                    Icons.arrow_upward_rounded,
                    color: isActive ? Colors.white : AppTheme.textMuted,
                    size: 22,
                  ),
          ),
        );
      },
    );
  }
}
