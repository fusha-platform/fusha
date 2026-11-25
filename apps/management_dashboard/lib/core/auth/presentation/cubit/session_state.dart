import '../../domain/entities/authenticated_user.dart';

sealed class SessionState {
  const SessionState();
}

final class SessionInitial extends SessionState {
  const SessionInitial();
}

final class SessionLoading extends SessionState {
  const SessionLoading();
}

final class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

final class SessionAuthenticated extends SessionState {
  const SessionAuthenticated(this.user);

  final AuthenticatedUser user;
}

final class SessionFailure extends SessionState {
  const SessionFailure(this.message, {this.code});

  final String message;
  final String? code;
}
