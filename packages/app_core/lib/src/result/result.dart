import '../errors/failure.dart';

/// Represents the outcome of an operation.
sealed class Result<T> {
  const Result();

  /// Handles both success and failure cases.
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      Failed<T>(:final failure) => onFailure(failure),
    };
  }

  /// Transforms successful data while preserving failures.
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success<T>(:final data) => Success<R>(transform(data)),
      Failed<T>(:final failure) => Failed<R>(failure),
    };
  }

  /// Chains another operation that returns a Result.
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    return switch (this) {
      Success<T>(:final data) => transform(data),
      Failed<T>(:final failure) => Failed<R>(failure),
    };
  }
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
