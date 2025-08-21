class InviteTeamModel {
  final int? id;
  final String? teamName;
  final String? description;
  final int? members;
  final int? matches;
  final bool? addMyself;
  final bool? active;
  final bool? invited;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? preferredSport;

  InviteTeamModel({
    this.id,
    this.teamName,
    this.description,
    this.members,
    this.matches,
    this.addMyself,
    this.active,
    this.invited,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.preferredSport,
  });

  factory InviteTeamModel.fromJson(Map<String, dynamic> json) {
    return InviteTeamModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0'),
      teamName: json['team_name']?.toString() ?? 'Unknown Team',
      description: json['description']?.toString() ?? 'No description',
      members: json['members'] is int
          ? json['members']
          : int.tryParse(json['members']?.toString() ?? '0'),
      matches: json['matches'] is int
          ? json['matches']
          : int.tryParse(json['matches']?.toString() ?? '0'),
      addMyself: json['add_myself'] == null
          ? false
          : (json['add_myself'] is bool
              ? json['add_myself']
              : (json['add_myself'] is int
                  ? json['add_myself'] != 0
                  : (json['add_myself'] is String
                      ? int.tryParse(json['add_myself']) != 0
                      : false))),
      active: json['active'] is bool
          ? json['active']
          : (json['active'] is int ? json['active'] != 0 : false),
      invited: json['invited'] is bool
          ? json['invited']
          : (json['invited'] is int ? json['invited'] != 0 : false),
      createdBy: json['createdBy']?.toString(),
      updatedBy: json['updatedBy']?.toString(),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is DateTime
              ? json['createdAt']
              : (json['createdAt'] is int
                  ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
                  : DateTime.tryParse(json['createdAt'].toString())))
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] is DateTime
              ? json['updatedAt']
              : (json['updatedAt'] is int
                  ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
                  : DateTime.tryParse(json['updatedAt'].toString())))
          : null,
      preferredSport: json['preferred_sport']?.toString() ?? 'Unknown Sport',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team_name': teamName,
      'description': description,
      'members': members,
      'matches': matches,
      'add_myself': addMyself,
      'active': active,
      'invited': invited,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'preferredSport': preferredSport,
    };
  }

  InviteTeamModel copyWith({
    int? id,
    String? teamName,
    String? description,
    int? members,
    int? matches,
    bool? addMyself,
    bool? active,
    bool? invited,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? preferredSport,
  }) {
    return InviteTeamModel(
      id: id ?? this.id,
      teamName: teamName ?? this.teamName,
      description: description ?? this.description,
      members: members ?? this.members,
      matches: matches ?? this.matches,
      addMyself: addMyself ?? this.addMyself,
      active: active ?? this.active,
      invited: invited ?? this.invited,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferredSport: preferredSport ?? this.preferredSport,
    );
  }
}

class InviteTeamResponse {
  final String message;
  final bool success;
  final Map<String, dynamic>? data;

  InviteTeamResponse({
    required this.message,
    required this.success,
    this.data,
  });

  factory InviteTeamResponse.fromJson(Map<String, dynamic> json) {
    return InviteTeamResponse(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      data: json['data'],
    );
  }

  factory InviteTeamResponse.fromString(String response) {
    return InviteTeamResponse(
      message: response,
      success: response.contains('successfully') || response.contains('Sent'),
      data: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
      'data': data,
    };
  }
}
