
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Provides Firebase service instances for a specific Firebase app.
final class FirebaseInstances {
  factory FirebaseInstances({FirebaseApp? app}) {
    final firebaseApp = app ?? Firebase.app();

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

  final FirebaseApp app;

  final FirebaseAuth auth;

  final FirebaseFirestore firestore;

  final FirebaseStorage storage;

  final FirebaseMessaging messaging;
}
