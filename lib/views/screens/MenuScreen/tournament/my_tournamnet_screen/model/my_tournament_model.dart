class MyTournamentModel {
  final int? id;
  final String? tournamentName;
  final String? venues;
  final String? sponsors;
  final String? dates;
  final String? description;
  final String? rules;
  final String? logoUrl;
  final String? createdBy;
  final String? updatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? preferredSport;
  final bool? isActive;
  final bool? isDeleted;

  MyTournamentModel({
    this.id,
    this.tournamentName,
    this.venues,
    this.sponsors,
    this.dates,
    this.description,
    this.rules,
    this.logoUrl,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.preferredSport,
    this.isActive,
    this.isDeleted,
  });

  factory MyTournamentModel.fromJson(Map<String, dynamic> json) {
    return MyTournamentModel(
      id: json['id'],
      tournamentName: json['tournament_name'],
      venues: json['venues'],
      sponsors: json['sponsors'],
      dates: json['dates'],
      description: json['description'],
      rules: json['rules'],
      logoUrl: json['logo_url'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
      preferredSport: json['preferredSport'],
      isActive: json['isActive'],
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournament_name': tournamentName,
      'venues': venues,
      'sponsors': sponsors,
      'dates': dates,
      'description': description,
      'rules': rules,
      'logo_url': logoUrl,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'preferredSport': preferredSport,
      'isActive': isActive,
      'isDeleted': isDeleted,
    };
  }

  MyTournamentModel copyWith({
    int? id,
    String? tournamentName,
    String? venues,
    String? sponsors,
    String? dates,
    String? description,
    String? rules,
    String? logoUrl,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? preferredSport,
    bool? isActive,
    bool? isDeleted,
  }) {
    return MyTournamentModel(
      id: id ?? this.id,
      tournamentName: tournamentName ?? this.tournamentName,
      venues: venues ?? this.venues,
      sponsors: sponsors ?? this.sponsors,
      dates: dates ?? this.dates,
      description: description ?? this.description,
      rules: rules ?? this.rules,
      logoUrl: logoUrl ?? this.logoUrl,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferredSport: preferredSport ?? this.preferredSport,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

class EnrolledTournamentModel {
  final int? id;
  final int? tournamentId;
  final String? tournamentName;
  final String? userId;
  final String? userName;
  final DateTime? enrolledAt;
  final String? status;
  final bool? isActive;

  EnrolledTournamentModel({
    this.id,
    this.tournamentId,
    this.tournamentName,
    this.userId,
    this.userName,
    this.enrolledAt,
    this.status,
    this.isActive,
  });

  factory EnrolledTournamentModel.fromJson(Map<String, dynamic> json) {
    return EnrolledTournamentModel(
      id: json['id'],
      tournamentId: json['tournament_id'],
      tournamentName: json['tournament_name'],
      userId: json['user_id'],
      userName: json['user_name'],
      enrolledAt: json['enrolled_at'] != null
          ? DateTime.parse(json['enrolled_at'].toString())
          : null,
      status: json['status'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournament_id': tournamentId,
      'tournament_name': tournamentName,
      'user_id': userId,
      'user_name': userName,
      'enrolled_at': enrolledAt?.toIso8601String(),
      'status': status,
      'isActive': isActive,
    };
  }

  EnrolledTournamentModel copyWith({
    int? id,
    int? tournamentId,
    String? tournamentName,
    String? userId,
    String? userName,
    DateTime? enrolledAt,
    String? status,
    bool? isActive,
  }) {
    return EnrolledTournamentModel(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      tournamentName: tournamentName ?? this.tournamentName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
    );
  }
}
