import 'logger.dart';

/// Example usage of the Logger utility
/// This file shows how to use the logger in your existing code
class LoggerExample {
  void demonstrateLogging() {
    // Basic logging with file and line information
    Logger.info('This is an info message');
    Logger.debug('This is a debug message');
    Logger.warning('This is a warning message');
    Logger.error('This is an error message');
    Logger.success('This is a success message');

    // Logging with custom tags
    Logger.info('User logged in successfully', tag: 'AUTH');
    Logger.debug('API call to /users', tag: 'API');
    Logger.error('Network request failed', tag: 'NETWORK');

    // Using extension methods (more convenient)
    this.logInfo('Using extension method for info');
    this.logDebug('Using extension method for debug');
    this.logWarning('Using extension method for warning');
    this.logError('Using extension method for error');
    this.logSuccess('Using extension method for success');

    // Error logging with exception
    try {
      // Some code that might throw an exception
      throw Exception('Something went wrong');
    } catch (e, stackTrace) {
      Logger.error('Caught an exception', error: e, stackTrace: stackTrace);
    }
  }

  void replacePrintStatements() {
    // Instead of: print('User data loaded');
    Logger.info('User data loaded');

    // Instead of: print('Debug: API response received');
    Logger.debug('API response received');

    // Instead of: print('Error: Failed to save data');
    Logger.error('Failed to save data');
  }
}

/// How to replace existing print statements in your code:
/// 
/// OLD WAY:
/// print('User logged in');
/// print('API call successful');
/// print('Error: Something went wrong');
/// 
/// NEW WAY:
/// Logger.info('User logged in');
/// Logger.success('API call successful');
/// Logger.error('Something went wrong');
/// 
/// OR using extension methods:
/// this.logInfo('User logged in');
/// this.logSuccess('API call successful');
/// this.logError('Something went wrong');
/// 
/// The output will show:
/// [CricYard | your_file.dart:25] ℹ️ User logged in
/// [CricYard | your_file.dart:26] ✅ API call successful
/// [CricYard | your_file.dart:27] ❌ Something went wrong 