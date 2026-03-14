import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:volthive/features/home/presentation/screens/home_screen.dart';
import 'package:volthive/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:volthive/features/plans/presentation/screens/plans_screen.dart';
import 'package:volthive/features/billing/presentation/screens/billing_screen.dart';
import 'package:volthive/features/support/presentation/screens/support_screen.dart';
import 'package:volthive/core/widgets/botpress_chat_widget.dart';

/// Main navigation screen with bottom navigation bar
class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  /// Key to call openChat() on the bubble from the SupportScreen's Live Chat tap
  final GlobalKey<AiChatBubbleState> _chatBubbleKey =
      GlobalKey<AiChatBubbleState>();

  void _goToPlans() => setState(() => _currentIndex = 2);
  void _goToDashboard() => setState(() => _currentIndex = 1);
  void _goToBilling() => setState(() => _currentIndex = 3);
  void _goToSupport() => setState(() => _currentIndex = 4);
  void _goToHome() => setState(() => _currentIndex = 0);

  void _openAiChat() {
    _chatBubbleKey.currentState?.openChat();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateToPlans: _goToPlans),
      const DashboardScreen(),
      const PlansScreen(),
      BillingScreen(onNavigateToPlans: _goToPlans),
      SupportScreen(onOpenChat: _openAiChat),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          // Global floating AI chat bubble
          AiChatBubble(
            key: _chatBubbleKey,
            onNavigateToDashboard: _goToDashboard,
            onNavigateToPlans: _goToPlans,
            onNavigateToBilling: _goToBilling,
            onNavigateToSupport: _goToSupport,
            onNavigateToHome: _goToHome,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.layers_outlined),
            activeIcon: Icon(Icons.layers),
            label: 'Plans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Billing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.headset_mic_outlined),
            activeIcon: Icon(Icons.headset_mic),
            label: 'Support',
          ),
        ],
      ),
    );
  }
}
