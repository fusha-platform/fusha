import 'package:app_core/app_core.dart';
import 'package:test/test.dart';

void main() {
  group('Result with Repository', () {
    late _FakeUserRepository repository;

    setUp(() {
      repository = _FakeUserRepository();
    });

    test('returns user data when repository succeeds', () async {
      repository.result = const Success(_User(id: 1, name: 'Alaa'));

      final result = await repository.getUser();

      expect(result, isA<Success<_User>>());

      final user = result.fold(
        onSuccess: (data) => data,
        onFailure: (failure) => throw StateError(failure.message),
      );

      expect(user.id, 1);
      expect(user.name, 'Alaa');
    });

    test('returns failure when repository fails', () async {
      const failure = NetworkFailure(
        message: 'No internet connection',
        code: 'NETWORK_ERROR',
      );

      repository.result = const Failed(failure);

      final result = await repository.getUser();

      expect(result, isA<Failed<_User>>());

      final message = result.fold(
        onSuccess: (user) => 'Welcome ${user.name}',
        onFailure: (failure) => failure.message,
      );

      expect(message, 'No internet connection');
    });

    test('supports transforming repository results', () async {
      repository.result = const Success(_User(id: 1, name: 'Alaa'));

      final result = await repository.getUser();

      final greeting = result
          .map((user) => user.name)
          .map((name) => 'Welcome, $name!')
          .fold(
            onSuccess: (message) => message,
            onFailure: (failure) => failure.message,
          );

      expect(greeting, 'Welcome, Alaa!');
    });

    test('preserves failure across chained operations', () async {
      const failure = ServerFailure(message: 'Server is unavailable');

      repository.result = const Failed(failure);

      final result = await repository.getUser();

      final transformed = result
          .map((user) => user.name)
          .flatMap((name) => Success('Welcome, $name!'));

      expect(transformed, isA<Failed<String>>());

      final preservedFailure = (transformed as Failed<String>).failure;

      expect(preservedFailure, same(failure));
    });
  });
}

class _User {
  const _User({required this.id, required this.name});

  final int id;
  final String name;
}

class _FakeUserRepository {
  Result<_User> result = const Failed(
    UnknownFailure(message: 'No result configured'),
  );

  Future<Result<_User>> getUser() async {
    return result;
  }
}
