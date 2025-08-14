class Court {
  final int? id;
  final String courtName;
  final String description;
  final bool active;

  Court({
    this.id,
    required this.courtName,
    required this.description,
    required this.active,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'],
      courtName: json['court_name'] ?? '',
      description: json['description'] ?? '',
      active: json['active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'court_name': courtName,
      'description': description,
      'active': active,
    };
  }

  Court copyWith({
    int? id,
    String? courtName,
    String? description,
    bool? active,
  }) {
    return Court(
      id: id ?? this.id,
      courtName: courtName ?? this.courtName,
      description: description ?? this.description,
      active: active ?? this.active,
    );
  }

  @override
  String toString() {
    return 'Court(id: $id, courtName: $courtName, description: $description, active: $active)';
  }
}
