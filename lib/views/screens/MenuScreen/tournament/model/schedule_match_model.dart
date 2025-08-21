class ScheduleMatchModel {
  final String? team1Id;
  final String? team2Id;
  final String? team1Name;
  final String? team2Name;
  final String? location;
  final String? description;
  final String? datetimeField;
  final bool isActive;
  final String? matchType;
  final String? preferred_sport;
  final String? match_category;
  final int tournamentId;
  final String? courtId;
  final String? courtName;
  final String? umpireId;
  final String? umpireName;

  ScheduleMatchModel({
    this.team1Id,
    this.team2Id,
    this.team1Name,
    this.team2Name,
    this.location,
    this.description,
    this.datetimeField,
    this.isActive = false,
    this.matchType,
    this.preferred_sport,
    this.match_category,
    required this.tournamentId,
    this.courtId,
    this.courtName,
    this.umpireId,
    this.umpireName,
  });

  Map<String, dynamic> toJson() {
    return {
      'team_1_id': team1Id,
      'team_2_id': team2Id,
      'team_1_name': team1Name,
      'team_2_name': team2Name,
      'location': location,
      'description': description,
      'datetime_field': datetimeField,
      'isactive': isActive,
      'matchType': matchType,
      'preferred_sport': preferred_sport,
      'match_category': match_category,
      'tournament_id': tournamentId,
      'court_id': courtId,
      'court_name': courtName,
      'umpire_id': umpireId,
      'umpire_name': umpireName,
    };
  }

  ScheduleMatchModel copyWith({
    String? team1Id,
    String? team2Id,
    String? team1Name,
    String? team2Name,
    String? location,
    String? description,
    String? datetimeField,
    bool? isActive,
    String? matchType,
    String? preferred_sport,
    String? match_category,
    int? tournamentId,
    String? courtId,
    String? courtName,
    String? umpireId,
    String? umpireName,
  }) {
    return ScheduleMatchModel(
      team1Id: team1Id ?? this.team1Id,
      team2Id: team2Id ?? this.team2Id,
      team1Name: team1Name ?? this.team1Name,
      team2Name: team2Name ?? this.team2Name,
      location: location ?? this.location,
      description: description ?? this.description,
      datetimeField: datetimeField ?? this.datetimeField,
      isActive: isActive ?? this.isActive,
      matchType: matchType ?? this.matchType,
      preferred_sport: preferred_sport ?? this.preferred_sport,
      match_category: match_category ?? this.match_category,
      tournamentId: tournamentId ?? this.tournamentId,
      courtId: courtId ?? this.courtId,
      courtName: courtName ?? this.courtName,
      umpireId: umpireId ?? this.umpireId,
      umpireName: umpireName ?? this.umpireName,
    );
  }
}

class TeamModel {
  final String teamId;
  final String teamName;

  TeamModel({
    required this.teamId,
    required this.teamName,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      teamId: json['team_id']?.toString() ?? '',
      teamName: json['team_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'team_name': teamName,
    };
  }
}
