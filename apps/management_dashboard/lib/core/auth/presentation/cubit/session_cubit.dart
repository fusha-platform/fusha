import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._repository) : super(const SessionInitial());

  final AuthRepository _repository;
  StreamSubscription<dynamic>? _subscription;
  bool _started = false;

  void start() {
    if (_started) return;
    _started = true;
    emit(const SessionLoading());
    _subscription = _repository.authStateChanges.listen(
      (user) {
        if (user == null) {
          emit(const SessionUnauthenticated());
        } else {
          emit(SessionAuthenticated(user));
        }
      },
      onError: (Object error) {
        emit(
          SessionFailure(
            'Unable to observe the authentication session.',
            code: error.runtimeType.toString(),
          ),
        );
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
