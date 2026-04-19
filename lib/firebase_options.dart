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
    apiKey: 'AIzaSyA0jypxlly8v1t4ZI_Czu8epfQfbF5s5u4',
    appId: '1:462650830305:web:daee67ad37de5e2ee9b6a0',
    messagingSenderId: '462650830305',
    projectId: 'fpractice-7df89',
    authDomain: 'fpractice-7df89.firebaseapp.com',
    storageBucket: 'fpractice-7df89.firebasestorage.app',
    measurementId: 'G-NHKZ4551XZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAyd7_Tt7PMGtehFiLHpH8NTXia0IZ9Lts',
    appId: '1:462650830305:android:c0bb3bf4166cf841e9b6a0',
    messagingSenderId: '462650830305',
    projectId: 'fpractice-7df89',
    storageBucket: 'fpractice-7df89.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA545NLivLCNpvQHzWFCwMwR0nm9xW6JIU',
    appId: '1:462650830305:ios:e9f405f4a6e7b277e9b6a0',
    messagingSenderId: '462650830305',
    projectId: 'fpractice-7df89',
    storageBucket: 'fpractice-7df89.firebasestorage.app',
    iosClientId:
        '462650830305-g4qv3o57j3l81fjvp5e2m72eh9sneq1h.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterHw32',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA545NLivLCNpvQHzWFCwMwR0nm9xW6JIU',
    appId: '1:462650830305:ios:e9f405f4a6e7b277e9b6a0',
    messagingSenderId: '462650830305',
    projectId: 'fpractice-7df89',
    storageBucket: 'fpractice-7df89.firebasestorage.app',
    iosClientId:
        '462650830305-g4qv3o57j3l81fjvp5e2m72eh9sneq1h.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterHw32',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA0jypxlly8v1t4ZI_Czu8epfQfbF5s5u4',
    appId: '1:462650830305:web:4bdbf432d4a6e996e9b6a0',
    messagingSenderId: '462650830305',
    projectId: 'fpractice-7df89',
    authDomain: 'fpractice-7df89.firebaseapp.com',
    storageBucket: 'fpractice-7df89.firebasestorage.app',
    measurementId: 'G-1EN23DZ1DR',
  );
}
