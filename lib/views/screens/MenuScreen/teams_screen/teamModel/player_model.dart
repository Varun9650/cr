class PlayerModel {
  final String id;
  final String playerName;
  final String playerTag;
  final String? image;
  final double? rating;
  final String? position;
  final String? teamId;

  PlayerModel({
    required this.id,
    required this.playerName,
    required this.playerTag,
    this.image,
    this.rating,
    this.position,
    this.teamId,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id']?.toString() ?? '',
      playerName: json['player_name']?.toString() ?? 'Unknown Player',
      playerTag: json['player_tag']?.toString() ?? '',
      image: json['image']?.toString(),
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      position: json['position']?.toString(),
      teamId: json['team_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player_name': playerName,
      'player_tag': playerTag,
      'image': image,
      'rating': rating,
      'position': position,
      'team_id': teamId,
    };
  }

  PlayerModel copyWith({
    String? id,
    String? playerName,
    String? playerTag,
    String? image,
    double? rating,
    String? position,
    String? teamId,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      playerName: playerName ?? this.playerName,
      playerTag: playerTag ?? this.playerTag,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      position: position ?? this.position,
      teamId: teamId ?? this.teamId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayerModel &&
        other.id == id &&
        other.playerName == playerName &&
        other.playerTag == playerTag;
  }

  @override
  int get hashCode {
    return id.hashCode ^ playerName.hashCode ^ playerTag.hashCode;
  }

  @override
  String toString() {
    return 'PlayerModel(id: $id, playerName: $playerName, playerTag: $playerTag)';
  }
}
