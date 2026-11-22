import '../failure.dart';

/// Represents invalid input or validation errors.
final class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}
