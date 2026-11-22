import '../failure.dart';

/// Represents a network connectivity failure.
final class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}
