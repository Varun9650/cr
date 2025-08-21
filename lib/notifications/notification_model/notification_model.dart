class NotificationModel {
  final String id;
  final String notification;
  final String time;
  final int userId;
  bool isRead;
  final bool isAccepted;
  final bool isIgnored;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NotificationModel({
    required this.id,
    required this.notification,
    required this.time,
    required this.userId,
    required this.isRead,
    this.isAccepted = false,
    this.isIgnored = false,
    this.createdAt,
    this.updatedAt,
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
      isRead: json['isread'] ?? false,
      isAccepted: json['isaccepted'] ?? false,
      isIgnored: json['isignored'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
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
      'isaccepted': isAccepted,
      'isignored': isIgnored,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Copy with method for updating fields
  NotificationModel copyWith({
    String? id,
    String? notification,
    String? time,
    int? userId,
    bool? isRead,
    bool? isAccepted,
    bool? isIgnored,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      notification: notification ?? this.notification,
      time: time ?? this.time,
      userId: userId ?? this.userId,
      isRead: isRead ?? this.isRead,
      isAccepted: isAccepted ?? this.isAccepted,
      isIgnored: isIgnored ?? this.isIgnored,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
