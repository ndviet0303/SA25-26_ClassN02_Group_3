import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return _ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }

  static const FirebaseOptions _ios = FirebaseOptions(
    apiKey: 'AIzaSyAHRbGrTcniAysk9p509sZhdPY50kgXX3g',
    appId: '1:133383338782:ios:c2a9369b269915cf2e270f',
    messagingSenderId: '133383338782',
    projectId: 'fir-84e19',
    storageBucket: 'fir-84e19.firebasestorage.app',
    iosClientId: '133383338782-bqv8s2q9v8fv23a70bfivffsi5sg52g6.apps.googleusercontent.com',
    iosBundleId: 'com.oggy.nozie',
  );
}


