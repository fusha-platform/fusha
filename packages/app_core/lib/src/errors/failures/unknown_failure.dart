import '../failure.dart';

/// Represents an unexpected or unclassified failure.
final class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code});
}
