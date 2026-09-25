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
    apiKey: 'AIzaSyBsfFis5IjB8CtYmoP_vcZNhV8gE35IZlo',
    appId: '1:533876795078:android:7cab8fa7b279fe4cd459c7',
    messagingSenderId: '533876795078',
    projectId: 'stay-india-partner',
    storageBucket: 'stay-india-partner.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDDY6jTVn53jBrx4VFQfbYkzM8PSzoSUJI',
    appId: '1:533876795078:ios:42cf2d47354d4c3cd459c7',
    messagingSenderId: '533876795078',
    projectId: 'stay-india-partner',
    storageBucket: 'stay-india-partner.firebasestorage.app',
    androidClientId: '730093151187-b9i8hboeqmd6i8tk5ribcqn1teq4anig.apps.googleusercontent.com',
    iosClientId: '730093151187-dh312ecscfthjepn87g0e14jjs15f4ua.apps.googleusercontent.com',
    iosBundleId: 'com.stayindia.stayindiaowner',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB0XztbOOa4LDPtxVa_AZd4QPPyP_RcbGw',
    appId: '1:730093151187:ios:c522b2f7c95e85368b8526',
    messagingSenderId: '730093151187',
    projectId: 'stay-india-owner',
    storageBucket: 'stay-india-owner.firebasestorage.app',
    androidClientId: '730093151187-b9i8hboeqmd6i8tk5ribcqn1teq4anig.apps.googleusercontent.com',
    iosClientId: '730093151187-dh312ecscfthjepn87g0e14jjs15f4ua.apps.googleusercontent.com',
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