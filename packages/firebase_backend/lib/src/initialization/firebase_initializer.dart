
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

/// Initializes Firebase for a Fusha application.
abstract final class FirebaseInitializer {
  /// Initializes Firebase using platform-specific options.
  ///
  /// The [options] should come from the application's generated
  /// `firebase_options.dart` file.
  static Future<FirebaseApp> initialize({
    required FirebaseOptions options,
    String? name,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    return Firebase.initializeApp(
      options: options,
      name: name,
    );
  }
}
