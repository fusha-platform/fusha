import 'package:app_core/app_core.dart';

import '../entities/authenticated_user.dart';

abstract interface class AuthRepository {
  Stream<AuthenticatedUser?> get authStateChanges;

  Future<Result<AuthenticatedUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Result<AuthenticatedUser>> createAccountWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Result<AuthenticatedUser>> signInWithGoogle();

  /// Explicitly links Google to the currently authenticated Firebase user.
  /// Never call automatically merely because two accounts share an email.
  Future<Result<AuthenticatedUser>> linkGoogleToCurrentAccount();

  Future<Result<void>> signOut();
}
