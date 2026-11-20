// File generated manually for Firebase configuration.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions have not been configured for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCaqv2b-kVsQp4aBdaSOHO5Y76hmjnTDXU',
    appId: '1:176141681501:web:ae5be1aff91887e6499eb4',
    messagingSenderId: '176141681501',
    projectId: 'app-casadivisas',
    authDomain: 'app-casadivisas.firebaseapp.com',
    storageBucket: 'app-casadivisas.firebasestorage.app',
  );
}