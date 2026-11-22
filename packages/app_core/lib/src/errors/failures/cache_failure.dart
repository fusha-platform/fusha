import '../failure.dart';

/// Represents a local cache or storage failure.
final class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}
