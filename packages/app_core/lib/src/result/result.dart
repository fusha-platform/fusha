import '../errors/failure.dart';

/// Represents the result of an operation.
sealed class Result<T> {
  const Result();
}

/// Represents a successful operation.
final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

/// Represents a failed operation.
final class Failed<T> extends Result<T> {
  const Failed(this.failure);

  final Failure failure;
}
