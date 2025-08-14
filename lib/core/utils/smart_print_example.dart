import 'smart_print.dart';

/// Example usage of smart print functions
/// This shows how to replace existing print statements with smart print
class SmartPrintExample {
  void demonstrateUsage() {
    // Basic usage - shows file name and line number automatically
    smartPrint('This is a normal message');
    smartPrintError('This is an error message');
    smartPrintWarning('This is a warning message');
    smartPrintSuccess('This is a success message');
    smartPrintDebug('This is a debug message');

    // Using extension methods (even shorter)
    'User logged in'.p(); // Normal print
    'API failed'.e(); // Error print
    'Network slow'.w(); // Warning print
    'Data saved'.s(); // Success print
    'Debug info'.d(); // Debug print
  }

  void replaceExistingPrints() {
    // OLD WAY:
    // print('User logged in');
    // print('Error: API failed');
    // print('Success: Data saved');

    // NEW WAY:
    smartPrint('User logged in');
    smartPrintError('API failed');
    smartPrintSuccess('Data saved');

    // OR using extensions (even shorter):
    'User logged in'.p();
    'API failed'.e();
    'Data saved'.s();
  }

  void showConsoleOutput() {
    // This will show in console like:
    // [Entity/cricket/Cricket/viewmodel/Cricket_viewmodel.dart:45] User logged in
    // [Entity/cricket/Cricket/viewmodel/Cricket_viewmodel.dart:46] ❌ API failed
    // [Entity/cricket/Cricket/viewmodel/Cricket_viewmodel.dart:47] ✅ Data saved

    smartPrint('User logged in');
    smartPrintError('API failed');
    smartPrintSuccess('Data saved');
  }
}

/// Quick Reference:
/// 
/// Instead of: print('message')
/// Use:       smartPrint('message')
/// Or:        'message'.p()
/// 
/// Instead of: print('Error: something went wrong')
/// Use:       smartPrintError('something went wrong')
/// Or:        'something went wrong'.e()
/// 
/// Instead of: print('Success: data saved')
/// Use:       smartPrintSuccess('data saved')
/// Or:        'data saved'.s()
/// 
/// Instead of: print('Warning: network slow')
/// Use:       smartPrintWarning('network slow')
/// Or:        'network slow'.w()
/// 
/// Instead of: print('Debug: API response')
/// Use:       smartPrintDebug('API response')
/// Or:        'API response'.d() 