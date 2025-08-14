import 'package:flutter/material.dart';
import 'package:cricyard/core/utils/smart_print.dart';
import '../../../tournament/repository/tournament_badminton_repo.dart';

class EditGamesViewModel extends ChangeNotifier {
  final TournamentBadmintonRepository _repository =
      TournamentBadmintonRepository();

  // State variables
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  // Match data
  List<int> _team1Points = [0, 0, 0];
  List<int> _team2Points = [0, 0, 0];
  int _team1Sets = 0;
  int _team2Sets = 0;
  Map<String, int> _playerPoints = {};
  int _matchId = 0;
  String? _matchType;
  String? _team1Name;
  String? _team2Name;
  String? _player1;
  String? _player2;
  String? _team1Player1;
  String? _team1Player2;
  String? _team2Player1;
  String? _team2Player2;
  bool _matchOver = false;
  String? _winner;
  int? _winnerTeam;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  List<int> get team1Points => _team1Points;
  List<int> get team2Points => _team2Points;
  int get team1Sets => _team1Sets;
  int get team2Sets => _team2Sets;
  Map<String, int> get playerPoints => _playerPoints;
  int get matchId => _matchId;
  String? get matchType => _matchType;
  String? get team1Name => _team1Name;
  String? get team2Name => _team2Name;
  String? get player1 => _player1;
  String? get player2 => _player2;
  String? get team1Player1 => _team1Player1;
  String? get team1Player2 => _team1Player2;
  String? get team2Player1 => _team2Player1;
  String? get team2Player2 => _team2Player2;
  bool get matchOver => _matchOver;
  String? get winner => _winner;
  int? get winnerTeam => _winnerTeam;

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Load match data
  Future<void> loadMatchData(int matchId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _matchId = matchId;
      notifyListeners();

      smartPrint('Loading match data for match ID: $matchId');

      // Get latest badminton record using TournamentBadmintonRepository
      final data = await _repository.getLatestBadmintonRecord(matchId);
      if (data != null) {
        // Extract match data from TournamentBadmintonModel
        _team1Name = data.team1Name ?? 'Team 1';
        _team2Name = data.team2Name ?? 'Team 2';
        _matchType = data.matchType ?? 'Unknown';
        _player1 = data.player1;
        _player2 = data.player2;
        _team1Player1 = data.team1Player1;
        _team1Player2 = data.team1Player2;
        _team2Player1 = data.team2Player1;
        _team2Player2 = data.team2Player2;

        // Extract scoreboard data
        _team1Points = data.team1Points ?? [0, 0, 0];
        _team2Points = data.team2Points ?? [0, 0, 0];
        _team1Sets = data.team1Sets ?? 0;
        _team2Sets = data.team2Sets ?? 0;
        _matchOver = data.matchOver ?? false;
        _winner = data.winner;
        _winnerTeam = data.winnerTeam;
        _playerPoints = data.playerPoints ?? {};

        smartPrint('Match details loaded: $_team1Name vs $_team2Name');
        smartPrint('Team 1 Sets: $_team1Sets, Team 2 Sets: $_team2Sets');
        smartPrint('Team 1 Points: $_team1Points');
        smartPrint('Team 2 Points: $_team2Points');
      } else {
        smartPrint('No match data found, using default values');
      }
    } catch (e) {
      _errorMessage = 'Failed to load match data: $e';
      smartPrintError('Error loading match data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Setters for editing
  void setTeam1Sets(int value) {
    _team1Sets = value;
    notifyListeners();
  }

  void setTeam2Sets(int value) {
    _team2Sets = value;
    notifyListeners();
  }

  void setTeam1Point(int setIndex, int value) {
    if (setIndex >= 0 && setIndex < _team1Points.length) {
      _team1Points[setIndex] = value;
      notifyListeners();
    }
  }

  void setTeam2Point(int setIndex, int value) {
    if (setIndex >= 0 && setIndex < _team2Points.length) {
      _team2Points[setIndex] = value;
      notifyListeners();
    }
  }

  void setPlayerPoint(String playerName, int value) {
    _playerPoints[playerName] = value;
    notifyListeners();
  }

  // Save match history
  Future<void> saveMatchHistory() async {
    try {
      _isSaving = true;
      notifyListeners();

      smartPrint('Saving match history for match ID: $_matchId');

      // Prepare data for saving
      final scoreData = {
        'gameNumber': 1, // Default game number
        'matchType': _matchType ?? 'Unknown',
        'player1': _player1 ?? '',
        'player2': _player2 ?? '',
        'team1Name': _team1Name ?? 'Team 1',
        'team2Name': _team2Name ?? 'Team 2',
        'team1Player1': _team1Player1 ?? '',
        'team1Player2': _team1Player2 ?? '',
        'team2Player1': _team2Player1 ?? '',
        'team2Player2': _team2Player2 ?? '',
        'team1Points': _team1Points.join(','),
        'team2Points': _team2Points.join(','),
        'playerPoints': _playerPoints.toString(),
        'currentSet': 0, // Default current set
        'team1Sets': _team1Sets,
        'team2Sets': _team2Sets,
        'matchOver': _matchOver,
        'completed': _matchOver,
        'winnerTeam': _winnerTeam,
        'preferred_sport': 'Badminton', // Default sport
        'match_id': _matchId,
        'tournament_id': 0, // Default tournament ID
      };

      // Call the API to save the data using TournamentBadmintonRepository
      final response =
          await _repository.updateBadmintonScore(_matchId, scoreData);

      if (response != null) {
        smartPrint('Match history saved successfully');
      } else {
        throw Exception('Failed to save match history');
      }
    } catch (e) {
      _errorMessage = 'Failed to save match history: $e';
      smartPrintError('Error saving match history: $e');
      throw e; // Re-throw to handle in UI
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Validate data before saving
  bool validateData() {
    // Check if team sets are valid
    if (_team1Sets < 0 || _team2Sets < 0) {
      _errorMessage = 'Team sets cannot be negative';
      notifyListeners();
      return false;
    }

    // Check if set points are valid
    for (int i = 0; i < _team1Points.length; i++) {
      if (_team1Points[i] < 0 || _team2Points[i] < 0) {
        _errorMessage = 'Set points cannot be negative';
        notifyListeners();
        return false;
      }
    }

    // Check if player points are valid
    for (final entry in _playerPoints.entries) {
      if (entry.value < 0) {
        _errorMessage = 'Player points cannot be negative';
        notifyListeners();
        return false;
      }
    }

    return true;
  }
}
