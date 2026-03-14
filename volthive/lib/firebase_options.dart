// File generated manually from Firebase Console config.
// Do NOT commit API keys to public repos.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCozG4hRBV8loIHNh7aNvthr7swDxEMv68',
    authDomain: 'volthive-84a79.firebaseapp.com',
    projectId: 'volthive-84a79',
    storageBucket: 'volthive-84a79.firebasestorage.app',
    messagingSenderId: '1023253923170',
    appId: '1:1023253923170:web:d2cdb136805535c6a8183b',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD0t5AJzhms3Fa8uKE7ypnClvZ0mIzXClY',
    appId: '1:1023253923170:android:28a6e99c358fc417a8183b',
    messagingSenderId: '1023253923170',
    projectId: 'volthive-84a79',
    storageBucket: 'volthive-84a79.firebasestorage.app',
  );
}
