

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
    apiKey: 'AIzaSyBP2RkqSvpBigP3xsJVaXrqP_B6il3pedo',
    appId: '1:730093151187:web:88b68af2f1a207768b8526',
    messagingSenderId: '730093151187',
    projectId: 'stay-india-owner',
    authDomain: 'stay-india-owner.firebaseapp.com',
    storageBucket: 'stay-india-owner.firebasestorage.app',
    measurementId: 'G-WJJLB2R9DJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKIpOcnkMDeZFSnDFacJJ_GIBIevH-G_o',
    appId: '1:730093151187:android:a9bc20872776c1f18b8526',
    messagingSenderId: '730093151187',
    projectId: 'stay-india-owner',
    storageBucket: 'stay-india-owner.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB0XztbOOa4LDPtxVa_AZd4QPPyP_RcbGw',
    appId: '1:730093151187:ios:c522b2f7c95e85368b8526',
    messagingSenderId: '730093151187',
    projectId: 'stay-india-owner',
    storageBucket: 'stay-india-owner.firebasestorage.app',
    iosBundleId: 'com.example.stayindiaOwner',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB0XztbOOa4LDPtxVa_AZd4QPPyP_RcbGw',
    appId: '1:730093151187:ios:c522b2f7c95e85368b8526',
    messagingSenderId: '730093151187',
    projectId: 'stay-india-owner',
    storageBucket: 'stay-india-owner.firebasestorage.app',
    iosBundleId: 'com.example.stayindiaOwner',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBP2RkqSvpBigP3xsJVaXrqP_B6il3pedo',
    appId: '1:730093151187:web:d510abe7c796ff7e8b8526',
    messagingSenderId: '730093151187',
    projectId: 'stay-india-owner',
    authDomain: 'stay-india-owner.firebaseapp.com',
    storageBucket: 'stay-india-owner.firebasestorage.app',
    measurementId: 'G-YYK02N7GKD',
  );
}
