import 'package:flutter/material.dart';
import 'package:volthive/core/theme/app_colors.dart';
import 'package:volthive/features/chatbot/presentation/screens/chat_screen.dart';

/// Global floating AI chat bubble that opens the native Volt AI assistant.
class AiChatBubble extends StatefulWidget {
  final VoidCallback? onNavigateToDashboard;
  final VoidCallback? onNavigateToPlans;
  final VoidCallback? onNavigateToBilling;
  final VoidCallback? onNavigateToSupport;
  final VoidCallback? onNavigateToHome;

  const AiChatBubble({
    super.key,
    this.onNavigateToDashboard,
    this.onNavigateToPlans,
    this.onNavigateToBilling,
    this.onNavigateToSupport,
    this.onNavigateToHome,
  });

  @override
  State<AiChatBubble> createState() => AiChatBubbleState();
}

/// Public state so a [GlobalKey<AiChatBubbleState>] can call [openChat].
class AiChatBubbleState extends State<AiChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Public: open the AI chat screen. Called by Live Chat in SupportScreen.
  Future<void> openChat() async {
    await _animController.forward();
    await _animController.reverse();
    if (!mounted) return;
    _pushChatScreen();
  }

  void _pushChatScreen() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: ChatScreen(
            onNavigateToDashboard: () {
              Navigator.pop(context);
              widget.onNavigateToDashboard?.call();
            },
            onNavigateToPlans: () {
              Navigator.pop(context);
              widget.onNavigateToPlans?.call();
            },
            onNavigateToBilling: () {
              Navigator.pop(context);
              widget.onNavigateToBilling?.call();
            },
            onNavigateToSupport: () {
              Navigator.pop(context);
              widget.onNavigateToSupport?.call();
            },
            onNavigateToHome: () {
              Navigator.pop(context);
              widget.onNavigateToHome?.call();
            },
          ),
        ),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: GestureDetector(
          onTap: openChat,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF005FD6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.chat_bubble, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}
