import 'dart:async';

typedef AsyncOrCallback<T> = FutureOr<T> Function();

class RateLimiter<T> {
  final Duration _interval;
  DateTime? _lastExecutionTime;
  Completer? _completer;

  RateLimiter(this._interval);

  Future<T> execute(FutureOr<T> Function() operation) async {
    while (_completer != null) {
      await _completer!.future;
    }
    _completer = Completer();

    final beforeAsyncTime = DateTime.now();
    if (_lastExecutionTime == null ||
        beforeAsyncTime.difference(_lastExecutionTime!) >= _interval) {
    } else {
      final waitTime =
          _lastExecutionTime!.add(_interval).difference(beforeAsyncTime);
      await Future.delayed(waitTime);
    }

    final result = await operation();
    _lastExecutionTime = DateTime.now();
    _completer?.complete();
    _completer = null;
    return result;
  }
}
