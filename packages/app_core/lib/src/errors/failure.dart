/// Base class for failures across Fusha applications.
abstract class Failure {
  const Failure({required this.message, this.code});

  /// A human-readable description of the failure.
  final String message;

  /// An optional machine-readable identifier.
  final String? code;
}
