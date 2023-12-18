import 'dart:async';

Future<void> waitFor(
  FutureOr<bool> Function() condition, {
  Duration? timeout,
  Duration interval = const Duration(milliseconds: 200),
}) async {
  final startTime = DateTime.now();
  while (true) {
    if (await condition()) return;

    var effectiveInterval = interval;
    if (timeout != null) {
      final passedTime = startTime.difference(DateTime.now());
      if (passedTime > timeout) {
        throw TimeoutException(
          'Condition did not pass within specified time.',
        );
      }
      final remainingTime = timeout - passedTime;
      effectiveInterval = remainingTime < interval ? remainingTime : interval;
    }

    await Future.delayed(effectiveInterval);
  }
}
