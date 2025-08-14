class NotificationModel {
  final String id;
  final String notification;
  final String time;
  final int userId;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.notification,
    required this.time,
    required this.userId,
    required this.isRead,
  });

  void markAsRead() {
    isRead = true;
  }

  // Factory constructor to create an instance from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      notification: json['notification'],
      time: json['time'],
      userId: json['user_id'],
      isRead: json['isread'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification': notification,
      'time': time,
      'user_id': userId,
      'isread': isRead,
    };
  }
}
