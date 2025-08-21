import 'dart:developer' as developer;

/// Custom logger utility that shows file name and line number in console output
/// Similar to Angular/React console logging
class Logger {
  static const String _tag = 'CricYard';
  
  /// Log info message with file and line information
  static void info(String message, {String? tag}) {
    final stackTrace = StackTrace.current;
    final caller = _getCallerInfo(stackTrace);
    final logTag = tag ?? _tag;
    
    developer.log(
      'ℹ️ $message',
      name: '$logTag | ${caller['file']}:${caller['line']}',
      level: 800, // Info level
    );
  }
  
  /// Log debug message with file and line information
  static void debug(String message, {String? tag}) {
    final stackTrace = StackTrace.current;
    final caller = _getCallerInfo(stackTrace);
    final logTag = tag ?? _tag;
    
    developer.log(
      '🐛 $message',
      name: '$logTag | ${caller['file']}:${caller['line']}',
      level: 500, // Debug level
    );
  }
  
  /// Log warning message with file and line information
  static void warning(String message, {String? tag}) {
    final stackTrace = StackTrace.current;
    final caller = _getCallerInfo(stackTrace);
    final logTag = tag ?? _tag;
    
    developer.log(
      '⚠️ $message',
      name: '$logTag | ${caller['file']}:${caller['line']}',
      level: 900, // Warning level
    );
  }
  
  /// Log error message with file and line information
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final currentStackTrace = stackTrace ?? StackTrace.current;
    final caller = _getCallerInfo(currentStackTrace);
    final logTag = tag ?? _tag;
    
    developer.log(
      '❌ $message${error != null ? '\nError: $error' : ''}',
      name: '$logTag | ${caller['file']}:${caller['line']}',
      level: 1000, // Error level
      error: error,
      stackTrace: currentStackTrace,
    );
  }
  
  /// Log success message with file and line information
  static void success(String message, {String? tag}) {
    final stackTrace = StackTrace.current;
    final caller = _getCallerInfo(stackTrace);
    final logTag = tag ?? _tag;
    
    developer.log(
      '✅ $message',
      name: '$logTag | ${caller['file']}:${caller['line']}',
      level: 800, // Info level
    );
  }
  
  /// Get caller information from stack trace
  static Map<String, String> _getCallerInfo(StackTrace stackTrace) {
    final frames = stackTrace.toString().split('\n');
    
    // Skip the first few frames (logger methods) and find the actual caller
    for (int i = 3; i < frames.length; i++) {
      final frame = frames[i];
      if (frame.contains('package:cricyard') && 
          !frame.contains('logger.dart') &&
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
  
  /// Simple print with file and line info (for backward compatibility)
  static void print(String message, {String? tag}) {
    info(message, tag: tag);
  }
}

/// Extension for easier logging
extension LoggerExtension on Object {
  void logInfo(String message, {String? tag}) => Logger.info(message, tag: tag);
  void logDebug(String message, {String? tag}) => Logger.debug(message, tag: tag);
  void logWarning(String message, {String? tag}) => Logger.warning(message, tag: tag);
  void logError(String message, {String? tag, Object? error, StackTrace? stackTrace}) => 
      Logger.error(message, tag: tag, error: error, stackTrace: stackTrace);
  void logSuccess(String message, {String? tag}) => Logger.success(message, tag: tag);
} 