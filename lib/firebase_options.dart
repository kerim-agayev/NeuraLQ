import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAM6caTDcUyFEYJ7b-PYHJ-fx0cHLmqRQk',
    appId: '1:715960921563:android:65efa854d8ff8c515b8bfe',
    messagingSenderId: '715960921563',
    projectId: 'neuralq-da04a',
    storageBucket: 'neuralq-da04a.firebasestorage.app',
  );
}
