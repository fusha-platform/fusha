import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Provides Firebase service instances for the default Firebase app.
final class FirebaseInstances {
  factory FirebaseInstances() {
    final firebaseApp = Firebase.app();

    return FirebaseInstances._(
      app: firebaseApp,
      auth: FirebaseAuth.instanceFor(app: firebaseApp),
      firestore: FirebaseFirestore.instanceFor(app: firebaseApp),
      storage: FirebaseStorage.instanceFor(app: firebaseApp),
      messaging: FirebaseMessaging.instance,
    );
  }

  const FirebaseInstances._({
    required this.app,
    required this.auth,
    required this.firestore,
    required this.storage,
    required this.messaging,
  });

  /// The default Firebase app associated with these services.
  final FirebaseApp app;

  /// The Firebase Authentication instance.
  final FirebaseAuth auth;

  /// The Cloud Firestore instance.
  final FirebaseFirestore firestore;

  /// The Firebase Storage instance.
  final FirebaseStorage storage;

  /// The Firebase Messaging instance for the default app.
  final FirebaseMessaging messaging;
}
