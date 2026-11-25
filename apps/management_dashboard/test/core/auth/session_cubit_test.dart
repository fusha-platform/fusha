import 'dart:async';

import 'package:app_core/app_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:management_dashboard/core/auth/domain/entities/authenticated_user.dart';
import 'package:management_dashboard/core/auth/domain/repositories/auth_repository.dart';
import 'package:management_dashboard/core/auth/presentation/cubit/session_cubit.dart';
import 'package:management_dashboard/core/auth/presentation/cubit/session_state.dart';

class _FakeAuthRepository implements AuthRepository {
  final controller = StreamController<AuthenticatedUser?>.broadcast();

  @override
  Stream<AuthenticatedUser?> get authStateChanges => controller.stream;

  @override
  Future<Result<AuthenticatedUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async => const Failed(UnknownFailure(message: 'Not implemented'));

  @override
  Future<Result<AuthenticatedUser>> createAccountWithEmailAndPassword({
    required String email,
    required String password,
  }) async => const Failed(UnknownFailure(message: 'Not implemented'));

  @override
  Future<Result<AuthenticatedUser>> signInWithGoogle() async =>
      const Failed(UnknownFailure(message: 'Not implemented'));

  @override
  Future<Result<AuthenticatedUser>> linkGoogleToCurrentAccount() async =>
      const Failed(UnknownFailure(message: 'Not implemented'));

  @override
  Future<Result<void>> signOut() async => const Success(null);
}

void main() {
  late _FakeAuthRepository repository;
  late SessionCubit cubit;

  setUp(() {
    repository = _FakeAuthRepository();
    cubit = SessionCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
    await repository.controller.close();
  });

  test('starts in initial state and listens for signed-out state', () async {
    cubit.start();
    expect(cubit.state, isA<SessionLoading>());

    repository.controller.add(null);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<SessionUnauthenticated>());
  });

  test('emits authenticated identity without granting permissions', () async {
    cubit.start();
    repository.controller.add(const AuthenticatedUser(id: 'uid-1'));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<SessionAuthenticated>());
  });

  test('start is idempotent', () async {
    cubit.start();
    cubit.start();

    repository.controller.add(null);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<SessionUnauthenticated>());
  });
}
