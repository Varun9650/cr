import 'package:flutter/material.dart';
import '../models/logistics_model.dart';
import '../repository/logistics_repository.dart';

enum LogisticsState { initial, loading, loaded, error }

class LogisticsViewModel extends ChangeNotifier {
  final LogisticsRepository _repository = LogisticsRepository();

  LogisticsData? _logisticsData;
  LogisticsState _state = LogisticsState.initial;
  String _errorMessage = '';

  // Getters
  LogisticsData? get logisticsData => _logisticsData;
  LogisticsState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isLoading => _state == LogisticsState.loading;
  bool get hasError => _state == LogisticsState.error;
  bool get isLoaded => _state == LogisticsState.loaded;

  /// Fetch logistics data from the repository
  Future<void> fetchLogisticsData() async {
    _setState(LogisticsState.loading);
    _clearError();

    try {
      _logisticsData = await _repository.fetchLogisticsData();
      print('Logistics data fetched successfully: $_logisticsData');
      _setState(LogisticsState.loaded);
    } catch (e) {
      _setError(e.toString());
      _setState(LogisticsState.error);
    }
  }

  /// Retry fetching data
  void retry() {
    fetchLogisticsData();
  }

  /// Clear current error state
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Refresh data
  Future<void> refresh() async {
    await fetchLogisticsData();
  }

  // Private methods
  void _setState(LogisticsState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
  }

  void _clearError() {
    _errorMessage = '';
  }

  /// Get formatted error message for UI
  String getFormattedErrorMessage() {
    if (_errorMessage.contains('401')) {
      return 'Authentication failed. Please login again.';
    } else if (_errorMessage.contains('404')) {
      return 'Logistics data not found.';
    } else if (_errorMessage.contains('500')) {
      return 'Server error. Please try again later.';
    } else if (_errorMessage.contains('network') ||
        _errorMessage.contains('timeout')) {
      return 'Network error. Please check your internet connection.';
    } else {
      return _errorMessage.isNotEmpty
          ? _errorMessage
          : 'An unexpected error occurred.';
    }
  }

  /// Check if specific logistics item is completed
  bool isItemCompleted(String itemType) {
    if (_logisticsData == null) return false;

    switch (itemType) {
      case 'pickup':
        return _logisticsData!.pickUp ?? false;
      case 'tshirt':
        return _logisticsData!.tshirtReceived ?? false;
      case 'certificate':
        return _logisticsData!.certificate ?? false;
      case 'payment':
        return _logisticsData!.paymentReceived ?? false;
      default:
        return false;
    }
  }

  /// Get completion percentage
  double getCompletionPercentage() {
    if (_logisticsData == null) return 0.0;

    int completedItems = 0;
    int totalItems = 4; // pickup, tshirt, certificate, payment

    if (_logisticsData!.pickUp ?? false) completedItems++;
    if (_logisticsData!.tshirtReceived ?? false) completedItems++;
    if (_logisticsData!.certificate ?? false) completedItems++;
    if (_logisticsData!.paymentReceived ?? false) completedItems++;

    return completedItems / totalItems;
  }

  /// Get status summary
  Map<String, bool> getStatusSummary() {
    return {
      'pickup': _logisticsData?.pickUp ?? false,
      'tshirt': _logisticsData?.tshirtReceived ?? false,
      'certificate': _logisticsData?.certificate ?? false,
      'payment': _logisticsData?.paymentReceived ?? false,
    };
  }
}
