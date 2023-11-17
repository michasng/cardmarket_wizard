import 'package:logging/logging.dart';

const dependenciesLogLevel = Level.WARNING;
const projectLogLevel = Level.ALL;

void initLogging() {
  Logger.root.level = dependenciesLogLevel;
  hierarchicalLoggingEnabled = true;

  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print(_formatLogRecord(record));
  });
}

String _formatLogRecord(LogRecord record) {
  final level = record.level.name.padRight(7, ' ');
  final isoTime = record.time.toIso8601String();

  return '$level $isoTime ${record.loggerName}: ${record.message}';
}

Logger createLogger(Type t) {
  return createNamedLogger(t.toString());
}

Logger createNamedLogger(String name) {
  final logger = Logger(name);
  logger.level = projectLogLevel;
  return logger;
}
