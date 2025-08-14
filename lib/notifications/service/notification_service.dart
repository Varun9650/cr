import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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

    // Show notification with a payload
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: 'Notification ID: $id', // You can add any data in the payload
    );
  }
}
