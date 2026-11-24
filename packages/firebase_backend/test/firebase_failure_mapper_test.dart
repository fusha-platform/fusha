import 'package:app_core/app_core.dart';
import 'package:firebase_backend/firebase_backend.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirebaseFailureMapper', () {
    test('maps network errors to NetworkFailure', () {
      final exception = FirebaseException(
        plugin: 'firebase_auth',
        code: 'network-request-failed',
        message: 'No internet connection',
      );

      final failure = FirebaseFailureMapper.fromException(exception);

      expect(failure, isA<NetworkFailure>());
      expect(failure.message, 'No internet connection');
      expect(failure.code, 'network-request-failed');
    });

    test('maps permission errors to UnauthorizedFailure', () {
      final exception = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message: 'Access denied',
      );

      final failure = FirebaseFailureMapper.fromException(exception);

      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.message, 'Access denied');
    });

    test('maps validation errors to ValidationFailure', () {
      final exception = FirebaseException(
        plugin: 'firebase_auth',
        code: 'invalid-email',
        message: 'Invalid email address',
      );

      final failure = FirebaseFailureMapper.fromException(exception);

      expect(failure, isA<ValidationFailure>());
      expect(failure.code, 'invalid-email');
    });

    test('maps server errors to ServerFailure', () {
      final exception = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
        message: 'Service unavailable',
      );

      final failure = FirebaseFailureMapper.fromException(exception);

      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'Service unavailable');
    });

    test('maps unknown errors to UnknownFailure', () {
      final exception = FirebaseException(
        plugin: 'firebase_storage',
        code: 'some-unclassified-error',
        message: 'Unexpected error',
      );

      final failure = FirebaseFailureMapper.fromException(exception);

      expect(failure, isA<UnknownFailure>());
      expect(failure.code, 'some-unclassified-error');
    });

    test('uses fallback message when exception message is null', () {
      final exception = FirebaseException(
        plugin: 'firebase_core',
        code: 'unknown',
      );

      final failure = FirebaseFailureMapper.fromException(exception);

      expect(failure.message, 'An unexpected Firebase error occurred.');
    });

    test(
      'normalizes error code for classification and preserves original code',
      () {
        final exception = FirebaseException(
          plugin: 'firebase_auth',
          code: 'INVALID-EMAIL',
          message: 'Invalid email address',
        );

        final failure = FirebaseFailureMapper.fromException(exception);

        expect(failure, isA<ValidationFailure>());
        expect(failure.code, 'INVALID-EMAIL');
      },
    );
  });
}
