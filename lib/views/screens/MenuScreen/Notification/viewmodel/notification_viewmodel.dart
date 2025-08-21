import 'package:flutter/material.dart';
import '../model/notification_model.dart';
import '../repository/notification_repository.dart';

enum NotificationStatus { initial, loading, success, error }

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  // State variables
  List<NotificationModel> _notifications = [];
  List<NotificationModel> _filteredNotifications = [];
  List<NotificationModel> _searchNotifications = [];

  NotificationStatus _status = NotificationStatus.initial;
  String _errorMessage = '';

  bool _isLoading = false;
  int _currentPage = 0;
  int _pageSize = 10;

  // Loading states for individual buttons
  Set<int> _acceptingIds = {};
  Set<int> _ignoringIds = {};

  // Search and filter
  String _searchQuery = '';
  bool _showCardView = true;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get filteredNotifications => _filteredNotifications;
  List<NotificationModel> get searchNotifications => _searchNotifications;

  NotificationStatus get status => _status;
  String get errorMessage => _errorMessage;

  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  Set<int> get acceptingIds => _acceptingIds;
  Set<int> get ignoringIds => _ignoringIds;

  String get searchQuery => _searchQuery;
  bool get showCardView => _showCardView;

  /// Initialize and fetch initial data
  Future<void> initialize() async {
    await Future.wait([
      fetchNotifications(),
      fetchNotificationsWithoutPaging(),
    ]);
  }

  /// Fetch notifications with pagination
  Future<void> fetchNotifications() async {
    try {
      _setStatus(NotificationStatus.loading);
      _isLoading = true;
      notifyListeners();

      final fetchedNotifications = await _repository.getAllWithPagination(
        '', // Token is handled by NetworkApiService
        _currentPage,
        _pageSize,
      );

      _notifications.addAll(fetchedNotifications);
      _filteredNotifications = _notifications.toList();
      _currentPage++;

      _setStatus(NotificationStatus.success);
    } catch (e) {
      _setStatus(NotificationStatus.error);
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch all notifications without pagination (for search)
  Future<void> fetchNotificationsWithoutPaging() async {
    try {
      final fetchedNotifications = await _repository.getByUserId();
      _searchNotifications = fetchedNotifications;
      notifyListeners();
    } catch (e) {
      _setStatus(NotificationStatus.error);
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    _currentPage = 0;
    _notifications.clear();
    _filteredNotifications.clear();
    await fetchNotifications();
  }

  /// Accept a notification
  Future<void> acceptNotification(int notificationId) async {
    try {
      _acceptingIds.add(notificationId);
      notifyListeners();

      await _repository.acceptNotification(notificationId);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          isAccepted: true,
          isIgnored: false,
        );
        _filteredNotifications = _notifications.toList();
      }

      _acceptingIds.remove(notificationId);
      notifyListeners();
    } catch (e) {
      _acceptingIds.remove(notificationId);
      _setStatus(NotificationStatus.error);
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Ignore a notification
  Future<void> ignoreNotification(int notificationId) async {
    try {
      _ignoringIds.add(notificationId);
      notifyListeners();

      await _repository.ignoreNotification(notificationId);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          isIgnored: true,
          isAccepted: false,
        );
        _filteredNotifications = _notifications.toList();
      }

      _ignoringIds.remove(notificationId);
      notifyListeners();
    } catch (e) {
      _ignoringIds.remove(notificationId);
      _setStatus(NotificationStatus.error);
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Search notifications
  void filterNotifications(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredNotifications = _notifications.toList();
    } else {
      _filteredNotifications = _searchNotifications
          .where((notification) => notification.notification
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  /// Toggle view mode
  void toggleViewMode() {
    _showCardView = !_showCardView;
    notifyListeners();
  }

  /// Set view mode
  void setViewMode(bool showCardView) {
    _showCardView = showCardView;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _setStatus(NotificationStatus.success);
    _errorMessage = '';
    notifyListeners();
  }

  /// Check if can load more
  bool get canLoadMore => !_isLoading && _status != NotificationStatus.error;

  /// Load more notifications
  Future<void> loadMore() async {
    if (canLoadMore) {
      await fetchNotifications();
    }
  }

  /// Private method to set status
  void _setStatus(NotificationStatus status) {
    _status = status;
    if (status == NotificationStatus.error) {
      _errorMessage =
          _errorMessage.isEmpty ? 'An error occurred' : _errorMessage;
    }
  }

  /// Dispose resources
  @override
  void dispose() {
    super.dispose();
  }
}
