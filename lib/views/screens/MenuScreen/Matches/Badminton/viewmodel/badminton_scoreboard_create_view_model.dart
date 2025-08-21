import 'package:cricyard/core/utils/smart_print.dart';
import 'package:flutter/material.dart';
import '../repository/badminton_scoreboard_create_repo.dart';

class BadmintonScoreboardCreateViewModel extends ChangeNotifier {
  final BadmintonScoreboardCreateRepository _repository =
      BadmintonScoreboardCreateRepository();

  // State variables
  int _matchId = 0;
  int _tourId = 0;
  String _matchType = 'Single';
  Map<String, dynamic> _entity = {};

  // Team data from entity
  String _team1Id = '';
  String _team2Id = '';
  String _team1Name = '';
  String _team2Name = '';

  // Team members data
  List<Map<String, dynamic>> _team1Members = [];
  List<Map<String, dynamic>> _team2Members = [];
  bool _isLoadingMembers = false;

  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isSuccess = false;
  String? _errorMessage;

  // Getters
  int get matchId => _matchId;
  int get tourId => _tourId;
  String get matchType => _matchType;
  Map<String, dynamic> get entity => _entity;
  String get team1Id => _team1Id;
  String get team2Id => _team2Id;
  String get team1Name => _team1Name;
  String get team2Name => _team2Name;
  List<Map<String, dynamic>> get team1Members => _team1Members;
  List<Map<String, dynamic>> get team2Members => _team2Members;
  bool get isLoadingMembers => _isLoadingMembers;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;

  /// Initialize the ViewModel with match data and entity
  void initializeData(
      int matchId, int tourId, String matchType, Map<String, dynamic> entity) {
    _matchId = matchId;
    _tourId = tourId;
    _matchType = matchType;
    _entity = entity;

    // Extract team IDs from entity
    _extractTeamData();

    // Fetch team members
    _fetchTeamMembers();

    notifyListeners();
  }

  /// Extract team data from entity
  void _extractTeamData() {
    print('entity id $entity');
    try {
      // Extract team IDs - adjust field names based on your entity structure
      _team1Id = _entity['team_1_id']?.toString() ?? '';

      _team2Id = _entity['team_2_id']?.toString() ?? '';

      // Extract team names
      _team1Name = _entity['team_1_name']?.toString() ?? 'Team 1';

      _team2Name = _entity['team_2_name']?.toString() ?? 'Team 2';

      smartPrint('Extracted team data:');
      smartPrint('Team 1 ID: $_team1Id, Name: $_team1Name');
      smartPrint('Team 2 ID: $_team2Id, Name: $_team2Name');
    } catch (e) {
      smartPrint('Error extracting team data: $e');
    }
  }

  /// Fetch team members for both teams
  Future<void> _fetchTeamMembers() async {
    print('tem member fetching for id $_team1Id');
    _isLoadingMembers = true;
    notifyListeners();

    try {
      // Fetch team 1 members
      if (_team1Id.isNotEmpty) {
        _team1Members = await _repository.getTeamMembers(_team1Id);
        smartPrint('Team 1 members fetched: $_team1Members');
      }

      // Fetch team 2 members
      if (_team2Id.isNotEmpty) {
        _team2Members = await _repository.getTeamMembers(_team2Id);
        smartPrint('Team 2 members fetched: $_team2Members');
      }
    } catch (e) {
      smartPrint('Error fetching team members: $e');
    } finally {
      _isLoadingMembers = false;
      notifyListeners();
    }
  }

  /// Get player names for singles match
  Map<String, String> getSinglesPlayerNames() {
    Map<String, String> playerNames = {};

    print('teamemember $_team1Members');
    if (_team1Members.isNotEmpty) {
      playerNames['player1'] = _team1Members.first['player_name'] ??
          _team1Members.first['name'] ??
          'Player 1';
    }

    if (_team2Members.isNotEmpty) {
      playerNames['player2'] = _team2Members.first['player_name'] ??
          _team2Members.first['name'] ??
          'Player 2';
    }

    return playerNames;
  }

  /// Get player names for doubles match
  Map<String, String> getDoublesPlayerNames() {
    Map<String, String> playerNames = {};

    // Team 1 players
    if (_team1Members.isNotEmpty) {
      playerNames['team1Player1'] = _team1Members.first['player_name'] ??
          _team1Members.first['name'] ??
          'Team 1 Player 1';
      if (_team1Members.length > 1) {
        playerNames['team1Player2'] = _team1Members[1]['player_name'] ??
            _team1Members[1]['name'] ??
            'Team 1 Player 2';
      }
    }

    // Team 2 players
    if (_team2Members.isNotEmpty) {
      playerNames['team2Player1'] = _team2Members.first['player_name'] ??
          _team2Members.first['name'] ??
          'Team 2 Player 1';
      if (_team2Members.length > 1) {
        playerNames['team2Player2'] = _team2Members[1]['player_name'] ??
            _team2Members[1]['name'] ??
            'Team 2 Player 2';
      }
    }

    return playerNames;
  }

  /// Create badminton scoreboard with player data
  Future<void> createBadmintonScoreboard(
      Map<String, dynamic> playerData) async {
    _setSubmitting(true);
    _clearError();

    smartPrint(' player data $playerData \n');
    try {
      final response = await _repository.createBadmintonScoreboard(
        _matchId,
        _tourId,
        _matchType,
        playerData,
      );

      if (response['success'] == true) {
        _isSuccess = true;
      } else {
        _setError(response['message'] ?? 'Failed to create scoreboard');
      }
    } catch (e) {
      _setError('Error creating scoreboard: $e');
      print("Error creating scoreboard: $e");
    } finally {
      _setSubmitting(false);
    }
  }

  // Private helper methods
  void _setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
