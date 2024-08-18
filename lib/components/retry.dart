import 'dart:async';
import 'dart:math';

import 'package:cardmarket_wizard/components/clamp_duration.dart';
import 'package:micha_core/micha_core.dart';

final _logger = createNamedLogger('withRetry');

typedef RetryStrategy = Duration Function(int attemptCount);

/// Between calls, this function waits for [initialDelay] and exponentially doubles the delay until [maxDelay] is reached.
RetryStrategy createExponentialBackoff({
  Duration initialDelay = const Duration(seconds: 1),
  Duration maxDelay = const Duration(seconds: 30),
}) {
  assert(initialDelay <= maxDelay);
  assert(maxDelay > Duration.zero);

  return (attemptCount) =>
      (initialDelay * pow(2, attemptCount - 1)).clamp(initialDelay, maxDelay);
}

/// Retries a given [operation] with exponential backoff and forwards the return value.
/// The [operation] is retried after throwing an exception of type [TException] or after any exception, if no type is specified.
/// Use [shouldRetry] to further restrict exceptions to retry for.
/// A call is attempted at least once and at most [maxAttemptCount] times.
Future<T> withRetry<T, TException extends Object>(
  FutureOr<T> Function() operation, {
  int? maxAttemptCount = 3,
  RetryStrategy? strategy,
  bool Function(TException exception)? shouldRetry,
}) async {
  final nonNullStrategy = strategy ?? createExponentialBackoff();

  int attemptCount = 0;
  while (true) {
    try {
      return await operation();
    } on TException catch (exception) {
      if (shouldRetry != null && !shouldRetry(exception)) {
        rethrow;
      }

      attemptCount++;
      if (maxAttemptCount != null && attemptCount >= maxAttemptCount) {
        _logger.severe(
          'Retry limit reached.',
          exception,
          StackTrace.current,
        );
        rethrow;
      }

      var delay = nonNullStrategy(attemptCount);
      _logger.finest(
          'A retried operation failed. Waiting for ${delay.inMilliseconds / 1000} seconds.');
      await Future.delayed(delay);
      _logger.finest('Retrying.');
    }
  }
}

class RetryException implements Exception {
  final String? message;

  RetryException(this.message);

  @override
  String toString() {
    const type = RetryException;
    if (message == null) return type.toString();
    return '$type: $message';
  }
}
