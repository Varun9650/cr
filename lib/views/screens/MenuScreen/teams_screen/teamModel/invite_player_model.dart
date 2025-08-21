class InvitePlayerModel {
  final int? id;
  final int? fromTeamId;
  final String? teamName;
  final int? toUserId;
  final String? mobileNumber;
  final String? playerName;
  final String? playerTag;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  InvitePlayerModel({
    this.id,
    this.fromTeamId,
    this.teamName,
    this.toUserId,
    this.mobileNumber,
    this.playerName,
    this.playerTag,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory InvitePlayerModel.fromJson(Map<String, dynamic> json) {
    return InvitePlayerModel(
      id: json['id'],
      fromTeamId: json['from_team_id'],
      teamName: json['team_name'],
      toUserId: json['to_user_id'],
      mobileNumber: json['mob_number'],
      playerName: json['player_name'],
      playerTag: json['player_tag'],
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : null,
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_team_id': fromTeamId,
      'team_name': teamName,
      'to_user_id': toUserId,
      'mob_number': mobileNumber,
      'player_name': playerName,
      'player_tag': playerTag,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  InvitePlayerModel copyWith({
    int? id,
    int? fromTeamId,
    String? teamName,
    int? toUserId,
    String? mobileNumber,
    String? playerName,
    String? playerTag,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return InvitePlayerModel(
      id: id ?? this.id,
      fromTeamId: fromTeamId ?? this.fromTeamId,
      teamName: teamName ?? this.teamName,
      toUserId: toUserId ?? this.toUserId,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      playerName: playerName ?? this.playerName,
      playerTag: playerTag ?? this.playerTag,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  String toString() {
    return 'InvitePlayerModel(id: $id, fromTeamId: $fromTeamId, teamName: $teamName, toUserId: $toUserId, mobileNumber: $mobileNumber, playerName: $playerName, playerTag: $playerTag)';
  }
}

class SearchedUserModel {
  final String? fullName;
  final String? mobileNumber;
  final String? email;
  final bool found;

  SearchedUserModel({
    this.fullName,
    this.mobileNumber,
    this.email,
    required this.found,
  });

  factory SearchedUserModel.fromJson(Map<String, dynamic> json) {
    return SearchedUserModel(
      fullName: json['fullName'],
      mobileNumber: json['mobileNumber'],
      email: json['email'],
      found: json['found'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'email': email,
      'found': found,
    };
  }
}
