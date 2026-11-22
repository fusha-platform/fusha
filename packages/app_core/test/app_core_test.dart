import 'package:app_core/app_core.dart';
import 'package:test/test.dart';

void main() {
  group('Failure', () {
    test('stores message and optional code', () {
      const failure = NetworkFailure(
        message: 'No internet connection',
        code: 'NETWORK_ERROR',
      );

      expect(failure.message, 'No internet connection');
      expect(failure.code, 'NETWORK_ERROR');
    });

    test('supports all predefined failure types', () {
      const failures = <Failure>[
        NetworkFailure(message: 'Network error'),
        ServerFailure(message: 'Server error'),
        ValidationFailure(message: 'Invalid input'),
        UnauthorizedFailure(message: 'Unauthorized'),
        CacheFailure(message: 'Cache error'),
        UnknownFailure(message: 'Unknown error'),
      ];

      expect(failures, hasLength(6));
      expect(failures[0], isA<NetworkFailure>());
      expect(failures[1], isA<ServerFailure>());
      expect(failures[2], isA<ValidationFailure>());
      expect(failures[3], isA<UnauthorizedFailure>());
      expect(failures[4], isA<CacheFailure>());
      expect(failures[5], isA<UnknownFailure>());
    });
  });

  group('Result', () {
    test('Success stores the returned data', () {
      const result = Success<int>(42);

      expect(result, isA<Result<int>>());
      expect(result.data, 42);
    });

    test('Failed stores the failure', () {
      const failure = NetworkFailure(message: 'Connection failed');

      const result = Failed<int>(failure);

      expect(result, isA<Result<int>>());
      expect(result.failure, same(failure));
    });

    test('supports exhaustive pattern matching', () {
      const Result<int> result = Success<int>(42);

      final message = switch (result) {
        Success<int>(:final data) => 'Success: $data',
        Failed<int>(:final failure) => 'Failure: ${failure.message}',
      };

      expect(message, 'Success: 42');
    });

    group('fold', () {
      test('calls onSuccess for successful results', () {
        const Result<int> result = Success<int>(42);

        final value = result.fold(
          onSuccess: (data) => 'Value: $data',
          onFailure: (failure) => 'Error: ${failure.message}',
        );

        expect(value, 'Value: 42');
      });

      test('calls onFailure for failed results', () {
        const Result<int> result = Failed<int>(
          NetworkFailure(message: 'Connection failed'),
        );

        final value = result.fold(
          onSuccess: (data) => 'Value: $data',
          onFailure: (failure) => 'Error: ${failure.message}',
        );

        expect(value, 'Error: Connection failed');
      });
    });

    group('map', () {
      test('transforms successful data', () {
        const Result<int> result = Success<int>(42);

        final mapped = result.map((data) => data.toString());

        expect(mapped, isA<Success<String>>());
        expect((mapped as Success<String>).data, '42');
      });

      test('preserves failure without transforming it', () {
        const failure = NetworkFailure(message: 'Connection failed');
        const Result<int> result = Failed<int>(failure);

        final mapped = result.map((data) => data.toString());

        expect(mapped, isA<Failed<String>>());
        expect((mapped as Failed<String>).failure, same(failure));
      });
    });

    group('flatMap', () {
      test('chains successful operations', () {
        const Result<int> result = Success<int>(10);

        final chained = result.flatMap(
          (value) => Success<String>('Value: $value'),
        );

        expect(chained, isA<Success<String>>());
        expect((chained as Success<String>).data, 'Value: 10');
      });

      test('preserves failure without executing transform', () {
        const failure = NetworkFailure(message: 'Connection failed');
        const Result<int> result = Failed<int>(failure);

        var transformCalled = false;

        final chained = result.flatMap<String>((value) {
          transformCalled = true;
          return Success<String>('Value: $value');
        });

        expect(transformCalled, isFalse);
        expect(chained, isA<Failed<String>>());
        expect((chained as Failed<String>).failure, same(failure));
      });
    });
  });
}
