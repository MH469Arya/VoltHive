import 'package:flutter/foundation.dart';

// import 'package:firebase_ai/firebase_ai.dart';

/// Service that connects to Firebase AI (Gemini) and manages 
/// the chat session with a VoltHive-specific system prompt baked in.
class GeminiChatService {
  /*
  static const String _systemPrompt = '''
You are "Volt", the intelligent AI assistant for VoltHive — a premium solar energy subscription app in India. 

## Your Role
You help users:
1. Understand and choose the right energy subscription plan
2. Navigate through the VoltHive app
3. Understand their bills and energy usage
4. Troubleshoot common issues
5. Learn about solar energy and benefits

## VoltHive App Overview
VoltHive is a solar energy subscription platform. Customers subscribe to solar power without installing panels themselves. The app has 5 main sections:
- **Home** – Energy overview, live stats, weather, quick actions
- **Dashboard** – Real-time energy monitoring charts, battery status, consumption graphs
- **Plans** – Subscription tier selection and management  
- **Billing** – Invoices, payment history, current subscription details
- **Support** – Help, raise tickets, contact

## Subscription Plans (Monthly Pricing in INR)

| Plan | Price/Month | Solar | Battery | Backup | Best For |
|------|-------------|-------|---------|--------|----------|
| **Spark** | ₹3,999 | 2 kW | 5 kWh | 8 hrs | Studio/1BHK apartments, light users |
| **Bloom** | ₹6,799 | 3 kW | 7.5 kWh | 12 hrs | 2BHK families, moderate usage |
| **Thrive** | ₹11,999 | 5 kW | 10 kWh | 16 hrs | Large homes, heavy appliances |
| **Surge** | ₹17,999 | 7 kW | 15 kWh | 20 hrs | Villas, home offices, EV charging |
| **Forge** | ₹28,999 | 10 kW | 20 kWh | 24 hrs | Small businesses, restaurants |
| **Apex** | Custom pricing | 15+ kW | 30+ kWh | 24+ hrs | Industrial, large enterprises |

**Annual plans save 13%.**
**Pay-As-You-Go** option: ₹12/kWh, no monthly commitment.

## Plan Recommendation Logic
Ask the user about:
1. Type of space (apartment, house, office)
2. Monthly electricity bill (before solar)
3. Key appliances (AC units, EV charger, heavy machinery)
4. Backup hours needed

**Rough mapping:**
- Bill < ₹2,000/month → Spark
- Bill ₹2,000–₹4,000/month → Bloom  
- Bill ₹4,000–₹7,000/month → Thrive
- Bill ₹7,000–₹12,000/month → Surge
- Bill > ₹12,000/month → Forge or Apex

## Navigation Help
- "Check my bill" → Go to **Billing** tab (4th icon)
- "View energy usage / dashboard" → Go to **Dashboard** tab (2nd icon)
- "Change my plan" → Go to **Plans** tab (3rd icon)
- "Raise a ticket / get help" → Go to **Support** tab (5th icon)

## Common FAQs

**Q: What is net metering?**
A: Excess solar feeds back to the grid and credits your account.

**Q: Can I change my plan anytime?**
A: Yes! Go to Billing → Change Plan.

**Q: What happens during no sunlight?**
A: Battery backup kicks in. Grid supplements during extended cloudy periods.

## Tone & Style
- Be warm, helpful, and concise
- Use ₹ (not Rs.) for currency
- Always suggest next actions
- Keep responses brief — offer to elaborate if needed
''';
  */

  // late final GenerativeModel _model;
  // late ChatSession _chatSession;

  GeminiChatService() {
    // Vertex AI initialization is temporarily commented out to prevent "Quota Exceeded" errors.
    // We are proceeding with Option 1: Hard code for now.
  }

  /// Send a user message and get a response.
  Future<String> sendMessage(String userMessage) async {
    try {
      debugPrint('[Volt] Sending to MOCK AI: "$userMessage"');
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      final lowerMessage = userMessage.toLowerCase();
      
      if (lowerMessage.contains('plan') || lowerMessage.contains('price') || lowerMessage.contains('cost')) {
        return 'We have several plans available starting from ₹3,999/month for the Spark plan up to ₹28,999/month for the Forge plan. Which one are you interested in?';
      } else if (lowerMessage.contains('bill') || lowerMessage.contains('pay') || lowerMessage.contains('invoice')) {
        return 'You can check your current bill and payment history in the Billing tab.';
      } else if (lowerMessage.contains('dashboard') || lowerMessage.contains('usage') || lowerMessage.contains('monitor')) {
        return 'Your real-time energy monitoring charts and consumption graphs are available in the Dashboard tab.';
      } else if (lowerMessage.contains('hello') || lowerMessage.contains('hi') || lowerMessage.contains('hey')) {
        return 'Hello there! I am Volt, your intelligent AI assistant. How can I help you with your solar energy needs today?';
      } else if (lowerMessage.contains('support') || lowerMessage.contains('help') || lowerMessage.contains('ticket') || lowerMessage.contains('issue')) {
        return 'You can raise a support ticket or find more help in our Support tab.';
      } else if (lowerMessage.contains('battery') || lowerMessage.contains('backup')) {
        return 'Our plans come with battery backup ranging from 5 kWh (8 hrs) to 20 kWh (24 hrs). What are your backup requirements?';
      }
      
      return 'I received your message: "$userMessage". Currently, I am operating in a mocked offline mode to prevent quota limit issues. Please explore the App tabs for more features!';
    } catch (e) {
      debugPrint('[Volt] Error: $e');
      return '⚠️ Error: $e';
    }
  }

  /// Reset the conversation.
  void resetChat() {
    // No action needed for mock mode.
  }
}
