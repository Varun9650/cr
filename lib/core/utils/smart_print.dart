import 'dart:developer' as developer;

/// Smart print function that automatically shows file name and line number
/// Usage: smartPrint('Your message here');
void smartPrint(Object? message) {
  final stackTrace = StackTrace.current;
  final caller = _getCallerInfo(stackTrace);

  developer.log(
    '$message',
    name: '${caller['file']}:${caller['line']}',
    level: 800, // Info level
  );
}

/// Smart print for errors
void smartPrintError(Object? message) {
  final stackTrace = StackTrace.current;
  final caller = _getCallerInfo(stackTrace);

  developer.log(
    '❌ $message',
    name: '${caller['file']}:${caller['line']}',
    level: 1000, // Error level
  );
}

/// Smart print for warnings
void smartPrintWarning(Object? message) {
  final stackTrace = StackTrace.current;
  final caller = _getCallerInfo(stackTrace);

  developer.log(
    '⚠️ $message',
    name: '${caller['file']}:${caller['line']}',
    level: 900, // Warning level
  );
}

/// Smart print for success messages
void smartPrintSuccess(Object? message) {
  final stackTrace = StackTrace.current;
  final caller = _getCallerInfo(stackTrace);

  developer.log(
    '✅ $message',
    name: '${caller['file']}:${caller['line']}',
    level: 800, // Info level
  );
}

/// Smart print for debug messages
void smartPrintDebug(Object? message) {
  final stackTrace = StackTrace.current;
  final caller = _getCallerInfo(stackTrace);

  developer.log(
    '🐛 $message',
    name: '${caller['file']}:${caller['line']}',
    level: 500, // Debug level
  );
}

/// Get caller information from stack trace
Map<String, String> _getCallerInfo(StackTrace stackTrace) {
  final frames = stackTrace.toString().split('\n');

  // Skip the first few frames (smart print methods) and find the actual caller
  for (int i = 3; i < frames.length; i++) {
    final frame = frames[i];
    if (frame.contains('package:cricyard') &&
        !frame.contains('smart_print.dart') &&
        !frame.contains('_getCallerInfo')) {
      // Extract file name and line number
      final match = RegExp(r'package:cricyard/([^:]+):(\d+)').firstMatch(frame);
      if (match != null) {
        return {
          'file': match.group(1) ?? 'unknown',
          'line': match.group(2) ?? '0',
        };
      }
    }
  }

  return {'file': 'unknown', 'line': '0'};
}

/// Extension for easier usage
extension SmartPrintExtension on Object {
  /// Print with file location
  void p() => smartPrint(this);

  /// Print error with file location
  void e() => smartPrintError(this);

  /// Print warning with file location
  void w() => smartPrintWarning(this);

  /// Print success with file location
  void s() => smartPrintSuccess(this);

  /// Print debug with file location
  void d() => smartPrintDebug(this);
}
