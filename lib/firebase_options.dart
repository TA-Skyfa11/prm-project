import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
/// Generated for project: prm-projects
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBZI-uleKUFvlFoVn-ywxupMTHh1NFEv58',
    appId: '1:213546833802:web:dc522280f180f3baeeda73',
    messagingSenderId: '213546833802',
    projectId: 'prm-projects',
    authDomain: 'prm-projects.firebaseapp.com',
    storageBucket: 'prm-projects.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBZI-uleKUFvlFoVn-ywxupMTHh1NFEv58',
    appId: '1:213546833802:android:dc522280f180f3baeeda73',
    messagingSenderId: '213546833802',
    projectId: 'prm-projects',
    storageBucket: 'prm-projects.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBZI-uleKUFvlFoVn-ywxupMTHh1NFEv58',
    appId: '1:213546833802:ios:dc522280f180f3baeeda73',
    messagingSenderId: '213546833802',
    projectId: 'prm-projects',
    storageBucket: 'prm-projects.firebasestorage.app',
  );
}
