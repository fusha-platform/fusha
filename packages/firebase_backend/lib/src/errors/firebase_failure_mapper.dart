
import 'package:app_core/app_core.dart';
import 'package:firebase_core/firebase_core.dart';

/// Converts Firebase exceptions into application-level failures.
abstract final class FirebaseFailureMapper {
  static Failure fromException(FirebaseException exception) {
    final message =
        exception.message ?? 'An unexpected Firebase error occurred.';

    final code = exception.code.toLowerCase();

    if (_networkErrorCodes.contains(code)) {
      return NetworkFailure(
        message: message,
        code: exception.code,
      );
    }

    if (_unauthorizedErrorCodes.contains(code)) {
      return UnauthorizedFailure(
        message: message,
        code: exception.code,
      );
    }

    if (_validationErrorCodes.contains(code)) {
      return ValidationFailure(
        message: message,
        code: exception.code,
      );
    }

    if (_serverErrorCodes.contains(code)) {
      return ServerFailure(
        message: message,
        code: exception.code,
      );
    }

    return UnknownFailure(
      message: message,
      code: exception.code,
    );
  }

  static const Set<String> _networkErrorCodes = {
    'network-request-failed',
    'network_error',
  };

  static const Set<String> _unauthorizedErrorCodes = {
    'unauthenticated',
    'permission-denied',
    'user-disabled',
    'invalid-credential',
    'wrong-password',
    'requires-recent-login',
    'operation-not-allowed',
  };

  static const Set<String> _validationErrorCodes = {
    'invalid-argument',
    'invalid-email',
    'weak-password',
    'email-already-in-use',
  };

  static const Set<String> _serverErrorCodes = {
    'internal',
    'unavailable',
    'deadline-exceeded',
    'resource-exhausted',
    'aborted',
  };
}
