import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../repo/notifications_repo.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Add repository reference
  final NotificationsRepo _repo = NotificationsRepo();

  // Initialize the notifications
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          onSelectNotification, // Handle action when tapped
    );
  }

  // This method is called when a notification or action is tapped
  Future<void> onSelectNotification(
      NotificationResponse notificationResponse) async {
    // If the action is "Mark as Read"
    if (notificationResponse.actionId == 'mark_as_read') {
      // Logic to mark notification as read (e.g., update the state, database, etc.)
      print('Notification marked as read!');

      try {
        // Extract notification ID from payload
        final payload = notificationResponse.payload;
        if (payload != null && payload.contains('Notification ID:')) {
          final notificationId = payload.split('Notification ID: ').last.trim();

          // Call backend API to mark notification as read
          await _repo.markNotificationAsRead(notificationId);
          print('â Notification $notificationId marked as read in backend!');

          // You can also show a local success message or update UI if needed
        } else {
          print('â Could not extract notification ID from payload: $payload');
        }
      } catch (e) {
        print('â Failed to mark notification as read: $e');
        // You can show error message to user if needed
      }
      // Perform any additional actions if needed (like navigating to a specific screen)
    }
  }

  // Show Notification with a custom action
  Future<void> showNotification(int id, String title, String body) async {
    // Define the "Mark as Read" action
    const AndroidNotificationAction markAsReadAction =
        AndroidNotificationAction(
      'mark_as_read', // Action id
      'Mark as Read', // Button label
    );

    // Define notification details
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
      actions: [markAsReadAction], // Add action to notification
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Create better payload with notification ID for tracking
    final payload = 'Notification ID: $id';
    // Show notification with a payload
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Show notification with custom payload for better tracking
  Future<void> showNotificationWithPayload(
    int id,
    String title,
    String body,
    String customPayload,
  ) async {
    const AndroidNotificationAction markAsReadAction =
        AndroidNotificationAction(
      'mark_as_read',
      'Mark as Read',
    );

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
      actions: [markAsReadAction],
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: customPayload,
    );
  }
}
