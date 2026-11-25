import 'package:app_core/app_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/authenticated_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  static final GoogleAuthProvider _googleProvider = GoogleAuthProvider()
    ..addScope('email')
    ..setCustomParameters(<String, String>{'prompt': 'select_account'});

  @override
  Stream<AuthenticatedUser?> get authStateChanges =>
      _auth.authStateChanges().map(_mapUser);

  @override
  Future<Result<AuthenticatedUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return const Failed(
          UnauthorizedFailure(message: 'Authentication returned no user.'),
        );
      }
      return Success(_toEntity(user));
    } on FirebaseAuthException catch (error) {
      return Failed(_mapAuthException(error));
    } catch (error) {
      return Failed(
        UnknownFailure(
          message: 'Unable to sign in.',
          code: error.runtimeType.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<AuthenticatedUser>> createAccountWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return const Failed(
          UnauthorizedFailure(message: 'Account creation returned no user.'),
        );
      }
      return Success(_toEntity(user));
    } on FirebaseAuthException catch (error) {
      return Failed(_mapAuthException(error));
    } catch (error) {
      return Failed(
        UnknownFailure(
          message: 'Unable to create account.',
          code: error.runtimeType.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<AuthenticatedUser>> signInWithGoogle() async {
    try {
      final credential = await _auth.signInWithPopup(_googleProvider);
      final user = credential.user;
      if (user == null) {
        return const Failed(
          UnauthorizedFailure(message: 'Google sign-in returned no user.'),
        );
      }
      return Success(_toEntity(user));
    } on FirebaseAuthException catch (error) {
      return Failed(_mapAuthException(error));
    } catch (error) {
      return Failed(
        UnknownFailure(
          message: 'Unable to sign in with Google.',
          code: error.runtimeType.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<AuthenticatedUser>> linkGoogleToCurrentAccount() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return const Failed(
          UnauthorizedFailure(message: 'Sign in before linking Google.'),
        );
      }
      final credential = await currentUser.linkWithPopup(_googleProvider);
      final user = credential.user;
      if (user == null) {
        return const Failed(
          UnauthorizedFailure(message: 'Account linking returned no user.'),
        );
      }
      return Success(_toEntity(user));
    } on FirebaseAuthException catch (error) {
      return Failed(_mapAuthException(error));
    } catch (error) {
      return Failed(
        UnknownFailure(
          message: 'Unable to link Google to this account.',
          code: error.runtimeType.toString(),
        ),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Success(null);
    } on FirebaseAuthException catch (error) {
      return Failed(_mapAuthException(error));
    } catch (error) {
      return Failed(
        UnknownFailure(
          message: 'Unable to sign out.',
          code: error.runtimeType.toString(),
        ),
      );
    }
  }

  AuthenticatedUser? _mapUser(User? user) =>
      user == null ? null : _toEntity(user);

  AuthenticatedUser _toEntity(User user) => AuthenticatedUser(
    id: user.uid,
    email: user.email,
    displayName: user.displayName,
    photoUrl: user.photoURL,
    emailVerified: user.emailVerified,
  );

  Failure _mapAuthException(FirebaseAuthException error) {
    final code = error.code.toLowerCase();
    final message = switch (code) {
      'account-exists-with-different-credential' =>
        'An account already exists with this email using another sign-in method. Sign in with that method first, then link Google explicitly.',
      'email-already-in-use' => 'This email is already registered.',
      'invalid-email' => 'The email address is invalid.',
      'weak-password' => 'The password does not meet the required strength.',
      'user-not-found' => 'No account was found for these credentials.',
      'wrong-password' ||
      'invalid-credential' => 'The supplied credentials are invalid.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' => 'Too many attempts. Try again later.',
      'network-request-failed' => 'A network connection is required.',
      'operation-not-allowed' => 'This sign-in method is not enabled.',
      _ => error.message ?? 'Authentication failed.',
    };

    if (code == 'account-exists-with-different-credential') {
      return ValidationFailure(message: message, code: code);
    }
    if (code == 'invalid-email' ||
        code == 'email-already-in-use' ||
        code == 'weak-password') {
      return ValidationFailure(message: message, code: code);
    }
    if (code == 'network-request-failed') {
      return NetworkFailure(message: message, code: code);
    }
    if (code == 'user-disabled' ||
        code == 'user-not-found' ||
        code == 'wrong-password' ||
        code == 'invalid-credential' ||
        code == 'operation-not-allowed') {
      return UnauthorizedFailure(message: message, code: code);
    }
    return UnknownFailure(message: message, code: code);
  }
}
