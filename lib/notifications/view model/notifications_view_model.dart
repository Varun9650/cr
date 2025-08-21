import 'package:cricyard/Utils/managers/user_manager.dart';
import 'package:cricyard/core/utils/smart_print.dart';
import 'package:cricyard/core/utils/toasterMessages/toast_message_util.dart';
import 'package:cricyard/data/response/api_response.dart';
import 'package:cricyard/notifications/repo/notifications_repo.dart';
import 'package:cricyard/notifications/service/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../notification_model/notification_model.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationsRepo _repo = NotificationsRepo();
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;
  String _error = '';

  bool get isLoading => _isLoading;
  String get error => _error;

  NotificationViewModel() {
    _initializeNotifications();
  }

  ApiResponse<List<NotificationModel>> notifications = ApiResponse.loading();
  setNotificationData(ApiResponse<List<NotificationModel>> val) {
    notifications = val;
    notifyListeners();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  int _readableNotificationsCount = 0; // Private variable

  // Getter for readable notifications count
  int get readableNotificationsCount => _readableNotificationsCount;

  // Setter for readable notifications count (private)
  set readableNotificationsCount(int value) {
    _readableNotificationsCount = value;
    notifyListeners(); // Notify UI whenever the count changes
  }

  // Method to decrement the count when a notification is marked as read
  void decrementNotificationCount() {
    if (_readableNotificationsCount > 0) {
      _readableNotificationsCount--;
      notifyListeners(); // Notify UI of the update
    }
  }

  Future<void> requestNotificationPermissions() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      print('Notification permissions granted');
      // await _notificationService.showNotification(
      //     1, "Permission grnted", "I love notifications");
    } else {
      print('Notification permissions denied');
      await _notificationService.showNotification(
          1, "Dummy", "I hate notifications");
      ToastMessageUtil.showToast(
          message: "Notification permissions denied",
          toastType: ToastType.error);
    }
  }

  Future<void> getNotifications() async {
    setNotificationData(ApiResponse.loading());
    // final token = UserManager().token;
    // final headers = {
    //   'Authorization': 'Bearer $token',
    //   'Content-Type': 'application/json',
    // };
    _repo.getNotifications().then(
      (value) {
        print(value);
        if (value != null) {
          // Assuming response is a list of maps (JSON objects)
          List<dynamic> notificationList = value as List<dynamic>;
          // Convert dynamic list to a List<NotificationModel>
          List<NotificationModel> notifications = notificationList
              .map((json) =>
                  NotificationModel.fromJson(json as Map<String, dynamic>))
              .toList();

          setNotificationData(ApiResponse.success(notifications));
        } else {
          setNotificationData(ApiResponse.success([]));
        }
      },
    ).onError(
      (error, stackTrace) {
        setNotificationData(ApiResponse.error(error.toString()));
        print(error);
      },
    );
  }

  /// Mark a notification as read
  // Future<void> markNotificationAsRead(String notificationId) async {
  //   try {
  //     _setLoading(true);

  //     final response = await _repo.markNotificationAsRead(notificationId);

  //     if (response != null) {
  //       // Update local state
  //       if (notifications.data != null) {
  //         final updatedNotifications = notifications.data!.map((notification) {
  //           if (notification.id == notificationId) {
  //             return notification.copyWith(isRead: true);
  //           }
  //           return notification;
  //         }).toList();

  //         setNotificationData(ApiResponse.success(updatedNotifications));

  //         // Decrement the readable count
  //         decrementNotificationCount();

  //         smartPrint('Notification marked as read successfully');
  //       }
  //     }
  //   } catch (e) {
  //     _setError('Failed to mark notification as read: $e');
  //     smartPrint('Error marking notification as read: $e');
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  /// Mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      _setLoading(true);

      final response = await _repo.markNotificationAsRead(notificationId);

      if (response != null) {
        // Update local state: remove the notification from the list
        if (notifications.data != null) {
          final remaining =
              notifications.data!.where((n) => n.id != notificationId).toList();

          setNotificationData(ApiResponse.success(remaining));

          // Decrement the readable count
          decrementNotificationCount();

          smartPrint('Notification marked as read successfully');
        }
      }
    } catch (e) {
      _setError('Failed to mark notification as read: $e');
      smartPrint('Error marking notification as read: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Accept a notification
  Future<void> acceptNotification(String notificationId) async {
    try {
      _setLoading(true);

      final response = await _repo.acceptNotification(notificationId);

      if (response != null) {
        // Update local state
        if (notifications.data != null) {
          final updatedNotifications = notifications.data!.map((notification) {
            if (notification.id == notificationId) {
              return notification.copyWith(
                isAccepted: true,
                isIgnored: false,
              );
            }
            return notification;
          }).toList();

          setNotificationData(ApiResponse.success(updatedNotifications));
          smartPrint('Notification accepted successfully');
        }
      }
    } catch (e) {
      _setError('Failed to accept notification: $e');
      smartPrint('Error accepting notification: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Ignore a notification
  Future<void> ignoreNotification(String notificationId) async {
    try {
      _setLoading(true);

      final response = await _repo.ignoreNotification(notificationId);

      if (response != null) {
        // Update local state
        if (notifications.data != null) {
          final updatedNotifications = notifications.data!.map((notification) {
            if (notification.id == notificationId) {
              return notification.copyWith(
                isIgnored: true,
                isAccepted: false,
              );
            }
            return notification;
          }).toList();

          setNotificationData(ApiResponse.success(updatedNotifications));
          smartPrint('Notification ignored successfully');
        }
      }
    } catch (e) {
      _setError('Failed to ignore notification: $e');
      smartPrint('Error ignoring notification: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get unread notifications count
  int get unreadCount {
    if (notifications.data == null) return 0;
    return notifications.data!.where((n) => !n.isRead).length;
  }

  /// Get unread notifications
  List<NotificationModel> get unreadNotifications {
    if (notifications.data == null) return [];
    return notifications.data!.where((n) => !n.isRead).toList();
  }

  /// Get read notifications
  List<NotificationModel> get readNotifications {
    if (notifications.data == null) return [];
    return notifications.data!.where((n) => n.isRead).toList();
  }

  Future<void> getReadableNotifications() async {
    // final token = UserManager().token;
    // final headers = {
    //   'Authorization': 'Bearer $token',
    //   'Content-Type': 'application/json',
    // };
    final queryParam = {'isRead': false.toString()};
    _repo.getAllReadableNotifications(queryParam).then(
      (value) async {
        print("Redable are -- ${value.length}");
        if (value != null && value is List) {
          readableNotificationsCount = value.length;
          print("Noti count --$readableNotificationsCount");
          smartPrint("Noti count --$readableNotificationsCount");

          for (var notification in value) {
            // print('notification print ');
            await _notificationService.showNotification(notification['id'],
                notification['notification'], notification['time']);
          }
        } else {
          print("Value is null or not list");
        }
      },
    ).onError(
      (error, stackTrace) {
        print(stackTrace);
        print("Redable error --$error");
      },
    );
  }

  Future<void> markSingleNotificationRead(String id) async {
    final token = UserManager().token;
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    _repo.markSingleAsRead(headers, id).then(
      (value) {
        print(value);
        // Remove from in-memory list after marking read
        if (notifications.data != null) {
          final remaining =
              notifications.data!.where((notif) => notif.id != id).toList();
          setNotificationData(ApiResponse.success(remaining));
        }
        decrementNotificationCount(); // Decrement count when notification is marked as read
      },
    ).onError(
      (error, stackTrace) {
        print(stackTrace);
        print("single notification $error");
      },
    );
  }
  // Future<void> markSingleNotificationRead(String id) async {
  //   final token = UserManager().token;
  //   final headers = {
  //     'Authorization': 'Bearer $token',
  //     'Content-Type': 'application/json',
  //   };
  //   _repo.markSingleAsRead(headers, id).then(
  //     (value) {
  //       print(value);
  //       // Find the notification by ID and mark it as read
  //       final notification =
  //           notifications.data!.firstWhere((notif) => notif.id == id);
  //       notification.markAsRead();
  //       decrementNotificationCount(); // Decrement count when notification is marked as read
  //       notifyListeners(); // Notify listeners to rebuild the UI
  //     },
  //   ).onError(
  //     (error, stackTrace) {
  //       print(stackTrace);
  //       print("single notification $error");
  //     },
  //   );
  // }

  Future<void> markAllAsRead() async {
    final token = UserManager().token;
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    _repo.markAllAsRead(headers).then(
      (value) {
        print(value);
      },
    ).onError(
      (error, stackTrace) {
        print(error);
      },
    );
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
}
