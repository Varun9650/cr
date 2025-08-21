class TournamentBadmintonModel {
  final int? id;
  final int? matchId;
  final String? matchType;
  final String? player1;
  final String? player2;
  final String? team1Name;
  final String? team2Name;
  final String? team1Player1;
  final String? team1Player2;
  final String? team2Player1;
  final String? team2Player2;
  final List<int>? team1Points;
  final List<int>? team2Points;
  final List<int>? gameTimes; // ✅ Individual game times
  final int? currentSet;
  final int? team1Sets;
  final int? team2Sets;
  final bool? matchOver;
  final String? winner;
  final int? winnerTeam;
  final Map<String, int>? playerPoints;
  final String? playerPointsString;
  final bool? isTeam1Serving;
  final int? matchDuration;
  final int? currentGameTime;
  final String? lastAction;
  final int? lastActionTeam;
  final String? lastActionPlayer;
  final bool? lastActionWasFault;
  final bool? lastActionWasLet;
  final bool? isTimerRunning;
  final bool? isPaused;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? tournamentId;
  final String? location;
  final String? description;
  final String? umpireName;
  final String? courtName;

  TournamentBadmintonModel({
    this.id,
    this.matchId,
    this.matchType,
    this.player1,
    this.player2,
    this.team1Name,
    this.team2Name,
    this.team1Player1,
    this.team1Player2,
    this.team2Player1,
    this.team2Player2,
    this.team1Points,
    this.team2Points,
    this.gameTimes,
    this.currentSet,
    this.team1Sets,
    this.team2Sets,
    this.matchOver,
    this.winner,
    this.winnerTeam,
    this.playerPoints,
    this.playerPointsString,
    this.isTeam1Serving,
    this.matchDuration,
    this.currentGameTime,
    this.lastAction,
    this.lastActionTeam,
    this.lastActionPlayer,
    this.lastActionWasFault,
    this.lastActionWasLet,
    this.isTimerRunning,
    this.isPaused,
    this.createdAt,
    this.updatedAt,
    this.tournamentId,
    this.location,
    this.description,
    this.umpireName,
    this.courtName,
  });

  factory TournamentBadmintonModel.fromJson(Map<String, dynamic> json) {
    // Parse team points
    List<int> parseTeamPoints(dynamic points) {
      if (points == null) return [0, 0, 0];
      if (points is String) {
        List<String> pointsStr = points.split(',');
        List<int> result =
            pointsStr.map((e) => int.tryParse(e.trim()) ?? 0).toList();
        while (result.length < 3) result.add(0);
        if (result.length > 3) result = result.take(3).toList();
        return result;
      } else if (points is List) {
        List<int> result = List<int>.from(points);
        while (result.length < 3) result.add(0);
        if (result.length > 3) result = result.take(3).toList();
        return result;
      }
      return [0, 0, 0];
    }

    // Parse player points
    Map<String, int> parsePlayerPoints(dynamic playerPoints) {
      if (playerPoints == null) return {};
      if (playerPoints is Map) {
        return Map<String, int>.from(playerPoints);
      } else if (playerPoints is String) {
        Map<String, int> result = {};
        String playerPointsStr = playerPoints;
        if (playerPointsStr.startsWith('{') && playerPointsStr.endsWith('}')) {
          playerPointsStr =
              playerPointsStr.substring(1, playerPointsStr.length - 1);
          List<String> entries = playerPointsStr.split(',');
          for (String entry in entries) {
            entry = entry.trim();
            if (entry.contains(':')) {
              List<String> parts = entry.split(':');
              if (parts.length == 2) {
                String playerName = parts[0].trim();
                int points = int.tryParse(parts[1].trim()) ?? 0;
                result[playerName] = points;
              }
            }
          }
        }
        return result;
      }
      return {};
    }

    return TournamentBadmintonModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0'),
      matchId: json['matchId'] is int
          ? json['matchId']
          : int.tryParse(json['matchId']?.toString() ?? '0'),
      matchType: json['matchType']?.toString(),
      player1: json['player1']?.toString(),
      player2: json['player2']?.toString(),
      team1Name: json['team1_name']?.toString() ?? 'Team 1',
      team2Name: json['team2_name']?.toString() ?? 'Team 2',
      team1Player1: json['team1Player1']?.toString(),
      team1Player2: json['team1Player2']?.toString(),
      team2Player1: json['team2Player1']?.toString(),
      team2Player2: json['team2Player2']?.toString(),
      team1Points: parseTeamPoints(json['team1Points']),
      team2Points: parseTeamPoints(json['team2Points']),
      gameTimes: parseTeamPoints(json['gameTimes']), // ✅ Parse game times
      currentSet: json['currentSet'] is int
          ? json['currentSet']
          : int.tryParse(json['currentSet']?.toString() ?? '0'),
      team1Sets: json['team1Sets'] is int
          ? json['team1Sets']
          : int.tryParse(json['team1Sets']?.toString() ?? '0'),
      team2Sets: json['team2Sets'] is int
          ? json['team2Sets']
          : int.tryParse(json['team2Sets']?.toString() ?? '0'),
      matchOver: json['matchOver'] is bool
          ? json['matchOver']
          : (json['matchOver'] is int ? json['matchOver'] != 0 : false),
      winner: json['winner']?.toString(),
      winnerTeam: json['winnerTeam'] is int
          ? json['winnerTeam']
          : int.tryParse(json['winnerTeam']?.toString() ?? '0'),
      playerPoints: parsePlayerPoints(json['playerPoints']),
      playerPointsString: json['playerPoints']?.toString(),
      isTeam1Serving: json['isTeam1Serving'] is bool
          ? json['isTeam1Serving']
          : (json['isTeam1Serving'] is int
              ? json['isTeam1Serving'] != 0
              : true),
      matchDuration: json['matchDuration'] is int
          ? json['matchDuration']
          : int.tryParse(json['matchDuration']?.toString() ?? '0'),
      currentGameTime: json['currentGameTime'] is int
          ? json['currentGameTime']
          : int.tryParse(json['currentGameTime']?.toString() ?? '0'),
      lastAction: json['lastAction']?.toString(),
      lastActionTeam: json['lastActionTeam'] is int
          ? json['lastActionTeam']
          : int.tryParse(json['lastActionTeam']?.toString() ?? '0'),
      lastActionPlayer: json['lastActionPlayer']?.toString(),
      lastActionWasFault: json['lastActionWasFault'] is bool
          ? json['lastActionWasFault']
          : (json['lastActionWasFault'] is int
              ? json['lastActionWasFault'] != 0
              : false),
      lastActionWasLet: json['lastActionWasLet'] is bool
          ? json['lastActionWasLet']
          : (json['lastActionWasLet'] is int
              ? json['lastActionWasLet'] != 0
              : false),
      isTimerRunning: json['isTimerRunning'] is bool
          ? json['isTimerRunning']
          : (json['isTimerRunning'] is int
              ? json['isTimerRunning'] != 0
              : false),
      isPaused: json['isPaused'] is bool
          ? json['isPaused']
          : (json['isPaused'] is int ? json['isPaused'] != 0 : false),
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
      tournamentId: json['tournamentId']?.toString(),
      location: json['location']?.toString(),
      description: json['description']?.toString(),
      umpireName: json['umpireName']?.toString(),
      courtName: json['courtName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchId': matchId,
      'matchType': matchType,
      'player1': player1,
      'player2': player2,
      'team1Name': team1Name,
      'team2Name': team2Name,
      'team1Player1': team1Player1,
      'team1Player2': team1Player2,
      'team2Player1': team2Player1,
      'team2Player2': team2Player2,
      'team1Points': team1Points?.join(','),
      'team2Points': team2Points?.join(','),
      'gameTimes': gameTimes?.join(','), // ✅ Add game times to JSON
      'currentSet': currentSet,
      'team1Sets': team1Sets,
      'team2Sets': team2Sets,
      'matchOver': matchOver,
      'winner': winner,
      'winnerTeam': winnerTeam,
      'playerPoints': playerPointsString ?? playerPoints?.toString(),
      'isTeam1Serving': isTeam1Serving,
      'matchDuration': matchDuration,
      'currentGameTime': currentGameTime,
      'lastAction': lastAction,
      'lastActionTeam': lastActionTeam,
      'lastActionPlayer': lastActionPlayer,
      'lastActionWasFault': lastActionWasFault,
      'lastActionWasLet': lastActionWasLet,
      'isTimerRunning': isTimerRunning,
      'isPaused': isPaused,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'tournamentId': tournamentId,
      'location': location,
      'description': description,
      'umpireName': umpireName,
      'courtName': courtName,
    };
  }

  TournamentBadmintonModel copyWith({
    int? id,
    int? matchId,
    String? matchType,
    String? player1,
    String? player2,
    String? team1Name,
    String? team2Name,
    String? team1Player1,
    String? team1Player2,
    String? team2Player1,
    String? team2Player2,
    List<int>? team1Points,
    List<int>? team2Points,
    List<int>? gameTimes,
    int? currentSet,
    int? team1Sets,
    int? team2Sets,
    bool? matchOver,
    String? winner,
    int? winnerTeam,
    Map<String, int>? playerPoints,
    String? playerPointsString,
    bool? isTeam1Serving,
    int? matchDuration,
    int? currentGameTime,
    String? lastAction,
    int? lastActionTeam,
    String? lastActionPlayer,
    bool? lastActionWasFault,
    bool? lastActionWasLet,
    bool? isTimerRunning,
    bool? isPaused,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? tournamentId,
    String? location,
    String? description,
    String? umpireName,
    String? courtName,
  }) {
    return TournamentBadmintonModel(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      matchType: matchType ?? this.matchType,
      player1: player1 ?? this.player1,
      player2: player2 ?? this.player2,
      team1Name: team1Name ?? this.team1Name,
      team2Name: team2Name ?? this.team2Name,
      team1Player1: team1Player1 ?? this.team1Player1,
      team1Player2: team1Player2 ?? this.team1Player2,
      team2Player1: team2Player1 ?? this.team2Player1,
      team2Player2: team2Player2 ?? this.team2Player2,
      team1Points: team1Points ?? this.team1Points,
      team2Points: team2Points ?? this.team2Points,
      gameTimes: gameTimes ?? this.gameTimes,
      currentSet: currentSet ?? this.currentSet,
      team1Sets: team1Sets ?? this.team1Sets,
      team2Sets: team2Sets ?? this.team2Sets,
      matchOver: matchOver ?? this.matchOver,
      winner: winner ?? this.winner,
      winnerTeam: winnerTeam ?? this.winnerTeam,
      playerPoints: playerPoints ?? this.playerPoints,
      playerPointsString: playerPointsString ?? this.playerPointsString,
      isTeam1Serving: isTeam1Serving ?? this.isTeam1Serving,
      matchDuration: matchDuration ?? this.matchDuration,
      currentGameTime: currentGameTime ?? this.currentGameTime,
      lastAction: lastAction ?? this.lastAction,
      lastActionTeam: lastActionTeam ?? this.lastActionTeam,
      lastActionPlayer: lastActionPlayer ?? this.lastActionPlayer,
      lastActionWasFault: lastActionWasFault ?? this.lastActionWasFault,
      lastActionWasLet: lastActionWasLet ?? this.lastActionWasLet,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      isPaused: isPaused ?? this.isPaused,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tournamentId: tournamentId ?? this.tournamentId,
      location: location ?? this.location,
      description: description ?? this.description,
      umpireName: umpireName ?? this.umpireName,
      courtName: courtName ?? this.courtName,
    );
  }
}

class ScoreAction {
  final String action;
  final int team;
  final String player;
  final bool isFault;
  final bool isLet;
  final DateTime timestamp;
  final int setNumber;
  final bool completedSet;

  ScoreAction({
    required this.action,
    required this.team,
    required this.player,
    this.isFault = false,
    this.isLet = false,
    required this.timestamp,
    this.setNumber = 0,
    this.completedSet = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'team': team,
      'player': player,
      'isFault': isFault,
      'isLet': isLet,
      'timestamp': timestamp.toIso8601String(),
      'setNumber': setNumber,
      'completedSet': completedSet,
    };
  }

  factory ScoreAction.fromJson(Map<String, dynamic> json) {
    return ScoreAction(
      action: json['action'] ?? '',
      team: json['team'] ?? 0,
      player: json['player'] ?? '',
      isFault: json['isFault'] ?? false,
      isLet: json['isLet'] ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      setNumber: json['setNumber'] ?? 0,
      completedSet: json['completedSet'] ?? false,
    );
  }
}
