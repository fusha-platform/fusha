import '../failure.dart';

/// Represents a server-side failure.
final class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}
