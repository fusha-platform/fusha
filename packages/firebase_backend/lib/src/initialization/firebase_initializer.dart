import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

/// Initializes the default Firebase app for a Fusha application.
abstract final class FirebaseInitializer {
  /// Initializes Firebase using the application's platform-specific options.
  ///
  /// The [options] should come from the application's generated
  /// `firebase_options.dart` file.
  static Future<FirebaseApp> initialize({
    required FirebaseOptions options,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    return Firebase.initializeApp(options: options);
  }
}
