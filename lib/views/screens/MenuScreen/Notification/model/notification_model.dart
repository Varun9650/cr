class NotificationModel {
  final int id;
  final String notification;
  final bool isAccepted;
  final bool isIgnored;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NotificationModel({
    required this.id,
    required this.notification,
    this.isAccepted = false,
    this.isIgnored = false,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      notification: json['notification'] ?? '',
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification': notification,
      'isaccepted': isAccepted,
      'isignored': isIgnored,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    int? id,
    String? notification,
    bool? isAccepted,
    bool? isIgnored,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      notification: notification ?? this.notification,
      isAccepted: isAccepted ?? this.isAccepted,
      isIgnored: isIgnored ?? this.isIgnored,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel &&
        other.id == id &&
        other.notification == notification &&
        other.isAccepted == isAccepted &&
        other.isIgnored == isIgnored;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        notification.hashCode ^
        isAccepted.hashCode ^
        isIgnored.hashCode;
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, notification: $notification, isAccepted: $isAccepted, isIgnored: $isIgnored)';
  }
}
