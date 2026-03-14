import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';

/// Background FCM handler — must be a top-level function (not inside a class).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized before this is called.
  await FcmService.backgroundHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    // Register background FCM handler (must be before runApp)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Initialize FCM (permissions + token + foreground listener)
  await FcmService.initialize();

  runApp(
    const ProviderScope(
      child: VoltHiveApp(),
    ),
  );
}

class VoltHiveApp extends StatelessWidget {
  const VoltHiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VoltHive',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,

      // Router
      routerConfig: AppRouter.router,
    );
  }
}
