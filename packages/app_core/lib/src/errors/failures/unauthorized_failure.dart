import '../failure.dart';

/// Represents an authentication or authorization failure.
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required super.message, super.code});
}
