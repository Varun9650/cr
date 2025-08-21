import 'package:flutter/material.dart';
import '../repository/badminton_match_repo.dart';

class BadmintonMatchViewModel extends ChangeNotifier {
  final BadmintonMatchRepository _repository = BadmintonMatchRepository();

  // State variables
  Map<String, dynamic> _lastRecord = {};
  Map<String, dynamic> _matchDetails = {};

  int _matchId = 0;
  int _tournamentId = 0;
  String _matchType = 'Single';
  String _team1Name = 'Team 1';
  String _team2Name = 'Team 2';

  bool _isData = false;
  bool _isLastRecord = false;
  bool _hasError = false;
  bool _isLoading = false;
  bool _showOverlay = false;
  bool _isLoadingData = false;
  String? _errorMessage;

  // Getters
  Map<String, dynamic> get lastRecord => _lastRecord;
  Map<String, dynamic> get matchDetails => _matchDetails;
  int get matchId => _matchId;
  int get tournamentId => _tournamentId;
  String get matchType => _matchType;
  String get team1Name => _team1Name;
  String get team2Name => _team2Name;
  bool get isData => _isData;
  bool get isLastRecord => _isLastRecord;
  bool get hasError => _hasError;
  bool get isLoading => _isLoading;
  bool get showOverlay => _showOverlay;
  bool get isLoadingData => _isLoadingData;
  String? get errorMessage => _errorMessage;

  /// Initialize the ViewModel with match data
  Future<void> initializeMatch(Map<String, dynamic> entity, bool status) async {
    _matchId = entity['id'] ?? 0;
    _tournamentId = entity['tournament_id'] ?? 0;
    _matchType = entity['matchType'] ?? 'Single';
    _team1Name = entity['team_1_name'] ?? 'Team 1';
    _team2Name = entity['team_2_name'] ?? 'Team 2';
    _isData = status;
    notifyListeners();

    // Check for last record
    await getLastRecordBadminton();
  }

  /// Check if badminton scoreboard exists
  Future<void> getLastRecordBadminton() async {
    _setLoadingData(true);
    _clearError();

    try {
      await checkLastRecord();
    } catch (e) {
      _setError('Failed to fetch data: $e');
      print("Error occurred: $e");
    } finally {
      _setLoadingData(false);
    }
  }

  /// Check last record
  Future<void> checkLastRecord() async {
    try {
      final response =
          await _repository.checkBadmintonScoreboardExists(_matchId);

      // Set the response data to _lastRecord
      if (response != null) {
        _lastRecord = response is Map<String, dynamic> ? response : {};
        _isLastRecord = true;
        print(
            'BadmintonMatchViewModel: Last record found - data: $_lastRecord');
      } else {
        _lastRecord = {};
        _isLastRecord = false;
        print('BadmintonMatchViewModel: No last record found');
      }

      print(
          'BadmintonMatchViewModel: Last record check - hasRecord: $_isLastRecord, isData: $_isData, isLoadingData: $_isLoadingData');
      notifyListeners();
    } catch (e) {
      _lastRecord = {};
      _isLastRecord = false;
      print('BadmintonMatchViewModel: Error checking last record: $e');
      notifyListeners();
    }
  }

  /// Start badminton match
  Future<void> startBadmintonMatch() async {
    _setShowOverlay(true);

    try {
      final response = await _repository.startBadmintonMatch(_matchId);
      if (response.isNotEmpty) {
        _isData = true;
        _setShowOverlay(false);
        notifyListeners();
      }
    } catch (e) {
      _setError('Error starting match: $e');
      print("Error starting match: $e");
    } finally {
      _setShowOverlay(false);
    }
  }

  /// Cancel badminton match
  Future<void> cancelBadmintonMatch() async {
    try {
      final success = await _repository.cancelBadmintonMatch(_matchId);
      if (success) {
        // Handle successful cancellation
        print('Match cancelled successfully');
      } else {
        _setError('Failed to cancel match');
      }
    } catch (e) {
      _setError('Error canceling match: $e');
      print("Error canceling match: $e");
    }
  }

  /// Get badminton match details
  Future<void> getBadmintonMatchDetails() async {
    try {
      final details = await _repository.getBadmintonMatchDetails(_matchId);
      _matchDetails = details;
      notifyListeners();
    } catch (e) {
      _setError('Error getting match details: $e');
      print("Error getting match details: $e");
    }
  }

  // Private helper methods
  void _setLoadingData(bool loading) {
    _isLoadingData = loading;
    notifyListeners();
  }

  void _setShowOverlay(bool show) {
    _showOverlay = show;
    notifyListeners();
  }

  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }
}
