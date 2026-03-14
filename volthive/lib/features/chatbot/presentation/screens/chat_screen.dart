import 'package:flutter/material.dart';
import 'package:volthive/core/theme/app_colors.dart';
import 'package:volthive/features/chatbot/models/chat_message.dart';
import 'package:volthive/features/chatbot/services/gemini_chat_service.dart';

/// Full-screen native AI chat interface for the VoltHive AI assistant.
class ChatScreen extends StatefulWidget {
  final VoidCallback? onNavigateToDashboard;
  final VoidCallback? onNavigateToPlans;
  final VoidCallback? onNavigateToBilling;
  final VoidCallback? onNavigateToSupport;
  final VoidCallback? onNavigateToHome;

  const ChatScreen({
    super.key,
    this.onNavigateToDashboard,
    this.onNavigateToPlans,
    this.onNavigateToBilling,
    this.onNavigateToSupport,
    this.onNavigateToHome,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiChatService _geminiService = GeminiChatService();
  final List<ChatMessage> _messages = [];
  bool _isSending = false;

  // Quick suggestion chips
  final List<String> _suggestions = [
    '🔌 Which plan suits me?',
    '💡 How do I read my bill?',
    '🔋 What is battery backup?',
    '📊 Go to Dashboard',
    '💳 Go to Billing',
    '📋 Go to Plans',
  ];

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(ChatMessage(
      text: "Hello! I'm **Volt**, your VoltHive AI assistant ⚡\n\nI can help you:\n• Choose the right energy plan\n• Understand your bills\n• Navigate the app\n• Answer solar energy questions\n\nHow can I help you today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isSending) return;

    final userMsg = text.trim();
    _inputController.clear();

    // Check for navigation intents
    _handleNavigation(userMsg);

    setState(() {
      _messages.add(ChatMessage(text: userMsg, isUser: true, timestamp: DateTime.now()));
      _messages.add(ChatMessage(text: '', isUser: false, timestamp: DateTime.now(), isLoading: true));
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final response = await _geminiService.sendMessage(userMsg);
      setState(() {
        _messages.removeLast(); // remove loading bubble
        _messages.add(ChatMessage(text: response, isUser: false, timestamp: DateTime.now()));
        _isSending = false;
      });
      _scrollToBottom();
    } catch (_) {
      setState(() {
        _messages.removeLast();
        _messages.add(ChatMessage(
          text: 'Something went wrong. Please try again.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isSending = false;
      });
    }
  }

  /// Handles smart navigation triggers from user messages.
  void _handleNavigation(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('dashboard') || lower.contains('energy usage') || lower.contains('monitoring')) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onNavigateToDashboard?.call());
    } else if (lower.contains('plan') && (lower.contains('go to') || lower.contains('see') || lower.contains('view'))) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onNavigateToPlans?.call());
    } else if (lower.contains('bill') && (lower.contains('go to') || lower.contains('see') || lower.contains('view'))) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onNavigateToBilling?.call());
    } else if (lower.contains('support') || lower.contains('ticket') || lower.contains('help desk')) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onNavigateToSupport?.call());
    }
  }

  void _resetChat() {
    _geminiService.resetChat();
    setState(() {
      _messages.clear();
      _messages.add(ChatMessage(
        text: "Chat reset! I'm Volt, your VoltHive assistant ⚡ How can I help?",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isDark ? const Color(0xFF0A0A12) : const Color(0xFFF5F7FF),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F0F1A) : Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, Color(0xFF005FD6)],
                ),
              ),
              child: const Icon(Icons.bolt, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Volt — VoltHive AI',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Online',
                      style: TextStyle(fontSize: 11, color: Color(0xFF22C55E)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset chat',
            onPressed: _resetChat,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark ? const Color(0xFF1E1E30) : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg, isDark);
                },
              ),
            ),

            // Suggestion chips (only if no user message yet)
            if (_messages.length <= 1)
              _buildSuggestionChips(isDark),

            // Input bar
            _buildInputBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isDark) {
    if (msg.isLoading) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, right: 60),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(18),
              bottomLeft: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TypingDot(delay: 0),
              const SizedBox(width: 4),
              TypingDot(delay: 200),
              const SizedBox(width: 4),
              TypingDot(delay: 400),
            ],
          ),
        ),
      );
    }

    final isUser = msg.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 12,
          left: isUser ? 60 : 0,
          right: isUser ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF005FD6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isUser ? null : (isDark ? const Color(0xFF1A1A2E) : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: isUser
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: MarkdownText(
          text: msg.text,
          isUser: isUser,
          isDark: isDark,
        ),
      ),
    );
  }

  Widget _buildSuggestionChips(bool isDark) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _suggestions.length,
        separatorBuilder: (ctx, idx) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          return GestureDetector(
            onTap: () => _sendMessage(_suggestions[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _suggestions[i],
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F1A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E1E30) : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Ask Volt anything...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 15,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _sendMessage(_inputController.text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _isSending
                    ? null
                    : const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF005FD6)],
                      ),
                color: _isSending ? Colors.grey : null,
              ),
              child: Icon(
                _isSending ? Icons.hourglass_top_rounded : Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple Markdown-like text renderer for bold (**text**) support.
class MarkdownText extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isDark;

  const MarkdownText({
    super.key,
    required this.text,
    required this.isUser,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isUser ? Colors.white : (isDark ? Colors.white : Colors.black87);
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(color: baseColor, fontSize: 14.5, height: 1.45),
        children: spans,
      ),
    );
  }
}

/// Animated typing indicator dot.
class TypingDot extends StatefulWidget {
  final int delay;
  const TypingDot({super.key, required this.delay});

  @override
  State<TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<TypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
