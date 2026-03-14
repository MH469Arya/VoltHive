import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Handles FCM initialization, permissions, token management,
/// and foreground/background message handling for VoltHive.
class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Callback invoked when a foreground message arrives — used by the UI
  // to show an in-app banner.
  static void Function(RemoteMessage)? onForegroundMessage;

  // ─── Top-level background message handler (must be top-level function) ─────
  // This is registered externally in main.dart via
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler)

  /// Initialize FCM: request permissions, get token, set up listeners.
  static Future<void> initialize() async {
    if (kIsWeb) {
      if (kDebugMode) {
        debugPrint('[FCM] Push notifications not configured for Web yet.');
      }
      return;
    }

    // 1. Request notification permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');
    }

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[FCM] Notifications permission denied by user.');
      return;
    }

    // 2. Get & log the FCM device token (for testing via Firebase Console)
    final token = await _messaging.getToken();
    if (kDebugMode) {
      debugPrint(
        '\n═══════════════════════════════════════════\n'
        '  FCM Device Token (use in Firebase Console):\n'
        '  $token\n'
        '═══════════════════════════════════════════\n',
      );
    }

    // Listen for token refreshes (e.g. app reinstall)
    _messaging.onTokenRefresh.listen((newToken) {
      if (kDebugMode) debugPrint('[FCM] Token refreshed: $newToken');
      // TODO: Save newToken to Firestore for server-side sending
    });

    // 3. Handle foreground messages (app is open)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint(
            '[FCM] Foreground message: ${message.notification?.title}');
      }
      onForegroundMessage?.call(message);
    });

    // 4. Handle notification taps when app is in background (already launched)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        debugPrint('[FCM] Opened from background: ${message.data}');
      }
      _handleNotificationTap(message);
    });

    // 5. Handle initial message (app was terminated, notification tapped to open)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        debugPrint('[FCM] Opened from terminated: ${initialMessage.data}');
      }
      _handleNotificationTap(initialMessage);
    }
  }

  /// Routes notification taps to the right screen based on payload type.
  static void _handleNotificationTap(RemoteMessage message) {
    final type = message.data['type'] as String?;
    switch (type) {
      case 'batteryAlert':
        // Navigate to Dashboard
        break;
      case 'billReady':
      case 'paymentSuccess':
        // Navigate to Billing
        break;
      case 'gridOutage':
        // Navigate to Home
        break;
    }
    // Deep-link routing can be wired to go_router in a future iteration.
  }

  /// FCM background message handler — MUST be a top-level function.
  /// Registered in main.dart via FirebaseMessaging.onBackgroundMessage(...)
  static Future<void> backgroundHandler(RemoteMessage message) async {
    if (kDebugMode) {
      debugPrint(
          '[FCM] Background message: ${message.notification?.title}');
    }
    // Firebase shows OS notification automatically for background messages
    // that have a `notification` payload. No extra code needed.
  }
}
