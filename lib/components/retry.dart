import 'dart:async';
import 'dart:math';

import 'package:cardmarket_wizard/components/clamp_duration.dart';
import 'package:logging/logging.dart';
import 'package:micha_core/micha_core.dart';

final _logger = createNamedLogger('withRetry');

/// Retries a given [operation] with exponential backoff and forwards the return value.
/// The [operation] is retried after throwing an exception of type [TException] or after any exception, if no type is specified.
/// Between calls, this function waits for [initialDelay] and exponentially doubles the delay until [maxDelay] is reached.
/// A call is attempted at least once. Once [maxAttemptCount] is reached any exception will be rethrown.
/// You can configure [logLevel] or set it to null to disable logging from this function.
Future<T> withRetry<T, TException extends Object>(
  FutureOr<T> Function() operation, {
  int maxAttemptCount = 3,
  Duration initialDelay = const Duration(seconds: 1),
  Duration maxDelay = const Duration(seconds: 30),
  Level? logLevel = Level.WARNING,
}) async {
  int attemptCount = 0;
  while (true) {
    try {
      return await operation();
    } on TException catch (e) {
      if (logLevel != null) {
        _logger.log(
          logLevel,
          'An error occurred in a retried operation.',
          e,
          StackTrace.current,
        );
      }
      attemptCount++;

      if (attemptCount >= maxAttemptCount) {
        if (logLevel != null) {
          _logger.log(logLevel, 'Retry limit reached.');
        }
        rethrow;
      }

      var delay = (initialDelay * pow(2, attemptCount - 1))
          .clamp(initialDelay, maxDelay);
      await Future.delayed(delay);
    }
  }
}
