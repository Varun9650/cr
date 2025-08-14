class TeamModel {
  final String id;
  final String teamId;
  final String teamName;
  final String userId;
  final String playerName;
  final String playerTag;
  final String createdAt;
  final String createdBy;
  final String updatedAt;
  final String updatedBy;
  final String accountId;
  final Map<String, String> extensions;

  TeamModel({
    required this.id,
    required this.teamId,
    required this.teamName,
    required this.userId,
    required this.playerName,
    required this.playerTag,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    required this.accountId,
    required this.extensions,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id']?.toString() ?? '',
      teamId: json['team_id']?.toString() ?? '',
      teamName: json['team_name']?.toString() ?? 'Unknown Team',
      userId: json['user_id']?.toString() ?? '',
      playerName: json['player_name']?.toString() ?? 'Unknown Player',
      playerTag: json['player_tag']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      createdBy: json['createdBy']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      updatedBy: json['updatedBy']?.toString() ?? '',
      accountId: json['accountId']?.toString() ?? '',
      extensions: {
        'extn1': json['extn1']?.toString() ?? '',
        'extn2': json['extn2']?.toString() ?? '',
        'extn3': json['extn3']?.toString() ?? '',
        'extn4': json['extn4']?.toString() ?? '',
        'extn5': json['extn5']?.toString() ?? '',
        'extn6': json['extn6']?.toString() ?? '',
        'extn7': json['extn7']?.toString() ?? '',
        'extn8': json['extn8']?.toString() ?? '',
        'extn9': json['extn9']?.toString() ?? '',
        'extn10': json['extn10']?.toString() ?? '',
        'extn11': json['extn11']?.toString() ?? '',
        'extn12': json['extn12']?.toString() ?? '',
        'extn13': json['extn13']?.toString() ?? '',
        'extn14': json['extn14']?.toString() ?? '',
        'extn15': json['extn15']?.toString() ?? '',
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team_id': teamId,
      'team_name': teamName,
      'user_id': userId,
      'player_name': playerName,
      'player_tag': playerTag,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
      'accountId': accountId,
      ...extensions,
    };
  }

  TeamModel copyWith({
    String? id,
    String? teamId,
    String? teamName,
    String? userId,
    String? playerName,
    String? playerTag,
    String? createdAt,
    String? createdBy,
    String? updatedAt,
    String? updatedBy,
    String? accountId,
    Map<String, String>? extensions,
  }) {
    return TeamModel(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      userId: userId ?? this.userId,
      playerName: playerName ?? this.playerName,
      playerTag: playerTag ?? this.playerTag,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      accountId: accountId ?? this.accountId,
      extensions: extensions ?? this.extensions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamModel &&
        other.id == id &&
        other.teamId == teamId &&
        other.teamName == teamName;
  }

  @override
  int get hashCode {
    return id.hashCode ^ teamId.hashCode ^ teamName.hashCode;
  }

  @override
  String toString() {
    return 'TeamModel(id: $id, teamId: $teamId, teamName: $teamName)';
  }
}
