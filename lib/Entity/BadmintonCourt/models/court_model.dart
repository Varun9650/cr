class Court {
  final int? id;
  final String courtName;
  final String description;
  final bool active;
  final int? tournamentId;
  final int? umpireId;
  final String? category;
  final String? tournamentName;
  final String? umpireName;

  Court({
    this.id,
    required this.courtName,
    required this.description,
    required this.active,
    this.tournamentId,
    this.umpireId,
    this.category,
    this.tournamentName,
    this.umpireName,
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'],
      courtName: json['court_name'] ?? '',
      description: json['description'] ?? '',
      active: json['active'] ?? false,
      tournamentId: json['tournament_id'],
      umpireId: json['umpire_id'] is int
          ? json['umpire_id']
          : int.tryParse((json['umpire_id'] ?? '').toString()),
      category: json['category'],
      tournamentName: json['tournament_name'] ?? json['tournamentName'],
      umpireName: json['umpire_name'] ?? json['umpireName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'court_name': courtName,
      'description': description,
      'active': active,
      'tournament_id': tournamentId,
      'umpire_id': umpireId,
      'category': category,
      'tournament_name': tournamentName,
      'umpire_name': umpireName,
    };
  }

  Court copyWith({
    int? id,
    String? courtName,
    String? description,
    bool? active,
    int? tournamentId,
    int? umpireId,
    String? category,
    String? tournamentName,
    String? umpireName,
  }) {
    return Court(
      id: id ?? this.id,
      courtName: courtName ?? this.courtName,
      description: description ?? this.description,
      active: active ?? this.active,
      tournamentId: tournamentId ?? this.tournamentId,
      umpireId: umpireId ?? this.umpireId,
      category: category ?? this.category,
      tournamentName: tournamentName ?? this.tournamentName,
      umpireName: umpireName ?? this.umpireName,
    );
  }

  @override
  String toString() {
    return 'Court(id: $id, courtName: $courtName, description: $description, active: $active, tournamentId: $tournamentId, umpireId: $umpireId, category: $category, tournamentName: $tournamentName, umpireName: $umpireName)';
  }
}
