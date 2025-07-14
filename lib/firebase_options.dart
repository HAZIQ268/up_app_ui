import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyDZkfovRxR3lSRdTBG82rTwBD_xPHhXbOo',
    appId: '1:804538823277:web:a2d2e5f44b700c3879c564',
    messagingSenderId: '804538823277',
    projectId: 'cityguidedb-5d294',
    authDomain: 'cityguidedb-5d294.firebaseapp.com',
    storageBucket: 'cityguidedb-5d294.firebasestorage.app',
    measurementId: 'G-0P74T9WEM4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCwfxC9CGWZOgtlHfCl1Gt9iUGxlscDCP0',
    appId: '1:804538823277:android:2c9b32f6661bbc2679c564',
    messagingSenderId: '804538823277',
    projectId: 'cityguidedb-5d294',
    storageBucket: 'cityguidedb-5d294.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAcsBVNxZo1P7C_WLxnOctLlk5w2l-wEow',
    appId: '1:804538823277:ios:e2b5c7a5ac8870df79c564',
    messagingSenderId: '804538823277',
    projectId: 'cityguidedb-5d294',
    storageBucket: 'cityguidedb-5d294.firebasestorage.app',
    iosBundleId: 'com.example.cityGuideApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAcsBVNxZo1P7C_WLxnOctLlk5w2l-wEow',
    appId: '1:804538823277:ios:e2b5c7a5ac8870df79c564',
    messagingSenderId: '804538823277',
    projectId: 'cityguidedb-5d294',
    storageBucket: 'cityguidedb-5d294.firebasestorage.app',
    iosBundleId: 'com.example.cityGuideApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDZkfovRxR3lSRdTBG82rTwBD_xPHhXbOo',
    appId: '1:804538823277:web:da3e590afe76e64d79c564',
    messagingSenderId: '804538823277',
    projectId: 'cityguidedb-5d294',
    authDomain: 'cityguidedb-5d294.firebaseapp.com',
    storageBucket: 'cityguidedb-5d294.firebasestorage.app',
    measurementId: 'G-4K7111YNFV',
  );
}
