class Umpire {
  final int? id;
  final String? name;
  final String? description;
  final bool? active;
  final int? userId;
  final String? userName;
  final int? tournamentId;
  final String? tournamentName;
  final String? userTag;
  final String? preferredSport;

  Umpire({
    this.id,
    this.name,
    this.description,
    this.active,
    this.userId,
    this.userName,
    this.tournamentId,
    this.tournamentName,
    this.userTag,
    this.preferredSport,
  });

  factory Umpire.fromJson(Map<String, dynamic> json) {
    return Umpire(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      active: json['active'],
      userId: json['user_id'],
      userName: json['user_name'],
      tournamentId: json['tournament_id'],
      tournamentName: json['tournamentName'],
      userTag: json['user_tag'],
      preferredSport: json['preferredSport'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'active': active,
      'user_id': userId,
      'user_name': userName,
      'tournament_id': tournamentId,
      'tournamentName': tournamentName,
      'user_tag': userTag,
      'preferredSport': preferredSport,
    };
  }

  Umpire copyWith({
    int? id,
    String? name,
    String? description,
    bool? active,
    int? userId,
    String? userName,
    int? tournamentId,
    String? tournamentName,
    String? userTag,
    String? preferredSport,
  }) {
    return Umpire(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      active: active ?? this.active,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      tournamentId: tournamentId ?? this.tournamentId,
      tournamentName: tournamentName ?? this.tournamentName,
      userTag: userTag ?? this.userTag,
      preferredSport: preferredSport ?? this.preferredSport,
    );
  }

  @override
  String toString() {
    return 'Umpire(id: $id, name: $name, description: $description, active: $active, userId: $userId, userName: $userName, tournamentId: $tournamentId, tournamentName: $tournamentName, userTag: $userTag, preferredSport: $preferredSport)';
  }
}
