import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cricyard/core/utils/smart_print.dart';
import '../repository/tournament_badminton_repo.dart';
import '../model/tournament_badminton_model.dart';

class TournamentBadmintonViewModel extends ChangeNotifier {
  final TournamentBadmintonRepository _repository =
      TournamentBadmintonRepository();

  // Badminton game constants
  static const int setsToWin = 2;
  static const int pointsToWinSet = 21;
  static const int maxPoints = 30;

  // State variables
  TournamentBadmintonModel? _matchData;
  List<int> _team1Points = [0, 0, 0];
  List<int> _team2Points = [0, 0, 0];
  List<int> _gameTimes = [0, 0, 0]; // ✅ Individual game times
  int _currentSet = 0;
  int _team1Sets = 0;
  int _team2Sets = 0;
  bool _matchOver = false;
  String? _winner;
  List<ScoreAction> _history = [];
  Map<String, int> _playerPoints = {};
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSaving = false;
  bool _isTeam1Serving = true;
  Timer? _matchTimer;
  int _matchDuration = 0;
  bool _isTimerRunning = false;
  bool _isPaused = false;
  int _currentGameTime = 0;
  String _lastAction = '';
  int _lastActionTeam = 0;
  String _lastActionPlayer = '';
  bool _lastActionWasFault = false;
  bool _lastActionWasLet = false;
  int _matchId = 0;

  // Getters
  TournamentBadmintonModel? get matchData => _matchData;
  List<int> get team1Points => _team1Points;
  List<int> get team2Points => _team2Points;
  List<int> get gameTimes => _gameTimes; // ✅ Game times getter
  int get currentSet => _currentSet;
  int get team1Sets => _team1Sets;
  int get team2Sets => _team2Sets;
  bool get matchOver => _matchOver;
  String? get winner => _winner;
  List<ScoreAction> get history => _history;
  Map<String, int> get playerPoints => _playerPoints;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;
  bool get isTeam1Serving => _isTeam1Serving;
  int get matchDuration => _matchDuration;
  bool get isTimerRunning => _isTimerRunning;
  bool get isPaused => _isPaused;
  int get currentGameTime => _currentGameTime;
  String get lastAction => _lastAction;
  int get lastActionTeam => _lastActionTeam;
  String get lastActionPlayer => _lastActionPlayer;
  bool get lastActionWasFault => _lastActionWasFault;
  bool get lastActionWasLet => _lastActionWasLet;
  int get matchId => _matchId;

  // Team display names
  String get team1Display => _matchData?.team1Name ?? 'Team 1';
  String get team2Display => _matchData?.team2Name ?? 'Team 2';

  bool get _isDoublesMatch {
    final type = _matchData?.matchType?.toUpperCase() ?? '';
    if (type.contains('DOUBLE')) return true;
    // Fallback: treat as doubles if we have second player names present
    return (_matchData?.team1Player2?.isNotEmpty == true) ||
        (_matchData?.team2Player2?.isNotEmpty == true);
  }

  String _playerKeyFor(int team, String player) {
    if (!_isDoublesMatch) return player;
    final normalizedName = player.trim();
    return '$team|$normalizedName';
  }

  String _slotKeyFor(int team, String player) {
    final p = player.trim();
    if (!_isDoublesMatch) {
      // Singles mapping
      if (_matchData?.player1?.trim() == p) return 'player1';
      if (_matchData?.player2?.trim() == p) return 'player2';
      // Fallback by team when names don't match exactly
      return team == 1 ? 'player1' : 'player2';
    }
    // Doubles mapping by exact match to roster slots
    if (team == 1) {
      if (_matchData?.team1Player1?.trim() == p) return 'team1Player1';
      if (_matchData?.team1Player2?.trim() == p) return 'team1Player2';
      // Fallback to first slot
      return 'team1Player1';
    } else {
      if (_matchData?.team2Player1?.trim() == p) return 'team2Player1';
      if (_matchData?.team2Player2?.trim() == p) return 'team2Player2';
      // Fallback to first slot
      return 'team2Player1';
    }
  }

  // int getPlayerPointsFor(int team, String player) {
  //   final key = _playerKeyFor(team, player);
  //   if (_playerPoints.containsKey(key)) return _playerPoints[key] ?? 0;
  //   // Backward compatibility: if old data stored plain names
  //   return _playerPoints[player] ?? 0;
  // }

  int getPlayerPointsFor(int team, String player) {
    final slotKey = _slotKeyFor(team, player);
    if (_playerPoints.containsKey(slotKey)) return _playerPoints[slotKey] ?? 0;
    // Backward compatibility: team-aware key then plain name
    final teamNameKey = _playerKeyFor(team, player);
    if (_playerPoints.containsKey(teamNameKey))
      return _playerPoints[teamNameKey] ?? 0;
    return _playerPoints[player] ?? 0;
  }

  // Get current game time (for display)
  int get currentGameTimeDisplay {
    if (_isTimerRunning && !_isPaused && !_matchOver) {
      return _currentGameTime;
    }
    return _gameTimes[_currentSet];
  }

  // Set match ID
  void setMatchId(int matchId) {
    _matchId = matchId;
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Fetch match data by match ID
  Future<void> fetchMatchData(int matchId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final data = await _repository.getLatestBadmintonRecord(matchId);
      smartPrint('data got  is $data');

      if (data != null) {
        _matchData = data;
        _team1Points = data.team1Points ?? [0, 0, 0];
        _team2Points = data.team2Points ?? [0, 0, 0];
        _gameTimes = data.gameTimes ?? [0, 0, 0]; // ✅ Load game times
        _currentSet = data.currentSet ?? 0;
        _team1Sets = data.team1Sets ?? 0;
        _team2Sets = data.team2Sets ?? 0;
        _matchOver = data.matchOver ?? false;
        _isTeam1Serving = data.isTeam1Serving ?? true;
        _matchDuration = data.matchDuration ?? 0;
        _currentGameTime = data.currentGameTime ?? 0;
        _playerPoints = data.playerPoints ?? {};

        // â Migrate legacy plain-name keys to team-aware keys (non-destructive)
        if (_isDoublesMatch && _playerPoints.isNotEmpty) {
          final migrated = <String, int>{}..addAll(_playerPoints);
          void migrateForPlayer(int team, String? name) {
            if (name == null || name.trim().isEmpty) return;
            final plain = name.trim();
            final teamKey = _playerKeyFor(team, plain);
            final existing = _playerPoints[plain];
            if (existing != null && !migrated.containsKey(teamKey)) {
              migrated[teamKey] = existing;
            }
          }

          migrateForPlayer(1, _matchData?.team1Player1);
          migrateForPlayer(1, _matchData?.team1Player2);
          migrateForPlayer(2, _matchData?.team2Player1);
          migrateForPlayer(2, _matchData?.team2Player2);
          _playerPoints = migrated;
        }
        // â Migrate to slot-based keys (player1/player2 or teamNPlayerM)
        if (_playerPoints.isNotEmpty) {
          final Map<String, int> slotMap = {};
          void addToSlot(int team, String? name) {
            if (name == null || name.trim().isEmpty) return;
            final slot = _slotKeyFor(team, name);
            final teamKey = _playerKeyFor(team, name);
            final plain = name.trim();
            final value = (_playerPoints[slot] ?? 0) +
                (_playerPoints[teamKey] ?? 0) +
                (_playerPoints[plain] ?? 0);
            if (value > 0) slotMap[slot] = value;
          }

          if (_isDoublesMatch) {
            addToSlot(1, _matchData?.team1Player1);
            addToSlot(1, _matchData?.team1Player2);
            addToSlot(2, _matchData?.team2Player1);
            addToSlot(2, _matchData?.team2Player2);
          } else {
            addToSlot(1, _matchData?.player1);
            addToSlot(2, _matchData?.player2);
          }

          // If nothing matched (edge cases), keep originals
          if (slotMap.isNotEmpty) {
            _playerPoints = slotMap;
          }
        }

        // Debug: Print player data
        smartPrint('=== PLAYER DATA DEBUG ===');
        smartPrint('Player1: ${data.player1}');
        smartPrint('Player2: ${data.player2}');
        smartPrint('Team1Player1: ${data.team1Player1}');
        smartPrint('Team1Player2: ${data.team1Player2}');
        smartPrint('Team2Player1: ${data.team2Player1}');
        smartPrint('Team2Player2: ${data.team2Player2}');
        smartPrint('Team1Name: ${data.team1Name}');
        smartPrint('team_2_Name: ${data.team2Name}');
        smartPrint('MatchType: ${data.matchType}');
        smartPrint('========================');

        // ✅ Load timer state
        final wasTimerRunning =
            data.isTimerRunning == null ? false : data.isTimerRunning ?? false;
        final wasPaused =
            data.isPaused == null ? false : data.isPaused ?? false;

        // Restore timer state if it was running and not paused
        if (wasTimerRunning && !wasPaused && !_matchOver) {
          _isTimerRunning = true;
          _isPaused = false;
          startTimer(); // Restart the timer
          smartPrint("Timer restored - was running and not paused");
        } else if (wasPaused) {
          _isPaused = true;
          _isTimerRunning = false;
          smartPrint("Timer restored - was paused");
        } else {
          _isTimerRunning = false;
          _isPaused = true; // Start in paused state
          smartPrint("Timer started in paused state - ready to resume");
        }

        // Set winner
        if (_matchOver && data.winnerTeam != null) {
          if (data.winnerTeam == 1) {
            _winner = team1Display;
          } else if (data.winnerTeam == 2) {
            _winner = team2Display;
          }
        } else {
          _winner = data.winner;
        }

        smartPrint(
            "Fetched match data: ${data.team1Name} vs ${data.team2Name}");
      } else {
        _errorMessage = 'No match data found';
        smartPrint("No match data found for match ID: $matchId");
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch match data: $e';
      smartPrintError("Error fetching match data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update score
  Future<void> updateScore(int team, String player, String action,
      {bool isFault = false, bool isLet = false}) async {
    try {
      // Check if match is paused
      if (_isPaused) {
        smartPrint("Cannot update score - match is paused");
        return;
      }

      _isSaving = true;
      notifyListeners();

      // Update local state //before deuse
      // if (team == 1) {

      //   _team1Points[_currentSet]++;
      //   if (_team1Points[_currentSet] >= pointsToWinSet) {
      //     _team1Sets++;
      //     if (_team1Sets >= setsToWin) {
      //       // Match won - stop all timers
      //       _matchOver = true;
      //       _winner = team1Display;
      //       _stopAllTimers();
      //     } else {
      //       // Set won - move to next set and pause the game
      //       smartPrint(
      //           "Team 1 won set ${_currentSet}! Moving from set ${_currentSet} to ${_currentSet + 1}");
      //       _currentSet++;
      //       _currentGameTime = 0; // Reset game time for new set
      //       _gameTimes[_currentSet] = 0; // Reset game time for current set
      //       pauseMatch(); // Pause the game when moving to next set
      //     }
      //   }
      // } else {
      //   _team2Points[_currentSet]++;
      //   if (_team2Points[_currentSet] >= pointsToWinSet) {
      //     _team2Sets++;
      //     if (_team2Sets >= setsToWin) {
      //       // Match won - stop all timers
      //       _matchOver = true;
      //       _winner = team2Display;
      //       _stopAllTimers();
      //     } else {
      //       // Set won - move to next set and pause the game
      //       smartPrint(
      //           "Team 2 won set ${_currentSet}! Moving from set ${_currentSet} to ${_currentSet + 1}");
      //       _currentSet++;
      //       _currentGameTime = 0; // Reset game time for new set
      //       _gameTimes[_currentSet] = 0; // Reset game time for current set
      //       pauseMatch(); // Pause the game when moving to next set
      //     }
      //   }
      // }

      // Handle LET: no point change, record history and exit
      if (isLet) {
        final scoreAction = ScoreAction(
          action: action,
          team: team,
          player: player,
          isFault: isFault,
          isLet: isLet,
          timestamp: DateTime.now(),
          setNumber: _currentSet,
          completedSet: false,
        );
        _history.add(scoreAction);

        _lastAction = action;
        _lastActionTeam = team;
        _lastActionPlayer = player;
        _lastActionWasFault = isFault;
        _lastActionWasLet = isLet;

        smartPrint("Let called - no score change");
        return;
      }

      // Preserve set index before any potential change
      final int historySetIndex = _currentSet;

      // Determine which team actually gets the point
      final int scoringTeam = isFault ? (team == 1 ? 2 : 1) : team;

      // Award point to the scoring team
      if (scoringTeam == 1) {
        _team1Points[_currentSet]++;
      } else {
        _team2Points[_currentSet]++;
      }

      // Auto-assign serve to rally winner (team-level)
      _isTeam1Serving = scoringTeam == 1;

      // Update player points only for normal point actions (not faults)
      if (!isFault && action == 'point') {
        // _playerPoints[player] = (_playerPoints[player] ?? 0) + 1;
        final slotKey = _slotKeyFor(team, player);
        _playerPoints[slotKey] = (_playerPoints[slotKey] ?? 0) + 1;
        // Keep legacy keys in sync (optional backward compatibility)
        final teamNameKey = _playerKeyFor(team, player);
        _playerPoints[teamNameKey] = (_playerPoints[teamNameKey] ?? 0) + 1;
        _playerPoints[player] = (_playerPoints[player] ?? 0) + 1;
        print('playerpoint  $_playerPoints');
      }

      // Evaluate set win using badminton rules: win by 2 from 21, cap at 30
      final int t1 = _team1Points[_currentSet];
      final int t2 = _team2Points[_currentSet];
      final bool team1WinsSet =
          ((t1 >= pointsToWinSet) && ((t1 - t2) >= 2)) || (t1 == maxPoints);
      final bool team2WinsSet =
          ((t2 >= pointsToWinSet) && ((t2 - t1) >= 2)) || (t2 == maxPoints);

      bool completedSet = false;
      if (team1WinsSet || team2WinsSet) {
        completedSet = true;

        // Save time for the completed set
        _gameTimes[_currentSet] = _currentGameTime;

        if (team1WinsSet) {
          _team1Sets++;
          smartPrint("Team 1 won set $_currentSet");
        } else {
          _team2Sets++;
          smartPrint("Team 2 won set $_currentSet");
        }

        // Check if match is won
        if (_team1Sets >= setsToWin || _team2Sets >= setsToWin) {
          _matchOver = true;
          _winner = _team1Sets >= setsToWin ? team1Display : team2Display;
          _stopAllTimers();
        } else {
          // Start next set: winner serves first in next set
          _isTeam1Serving = team1WinsSet;
          _currentSet++;
          _currentGameTime = 0; // reset timer for new set
          if (_currentSet < _gameTimes.length) {
            _gameTimes[_currentSet] = 0;
          }
          // Pause between sets
          await pauseMatch();
        }
      }

      // Add to history with set completion info
      final scoreAction = ScoreAction(
        action: action,
        team: scoringTeam,
        player: player,
        isFault: isFault,
        isLet: false,
        timestamp: DateTime.now(),
        setNumber: historySetIndex,
        completedSet: completedSet,
      );
      _history.add(scoreAction);

      // Update last action
      _lastAction = action;
      _lastActionTeam = scoringTeam;
      _lastActionPlayer = player;
      _lastActionWasFault = isFault;
      _lastActionWasLet = false;

      // Save to backend
      final scoreData = {
        'team1Points': _team1Points.join(','),
        'team2Points': _team2Points.join(','),
        'currentSet': _currentSet,
        'team1Sets': _team1Sets,
        'team2Sets': _team2Sets,
        'matchOver': _matchOver,
        'winner': _winner,
        'winnerTeam': _matchOver ? (_winner == team1Display ? 1 : 2) : null,
        'playerPoints': _playerPoints.toString(),
        'isTeam1Serving': _isTeam1Serving,
        'matchDuration': _matchDuration,
        'currentGameTime': _currentGameTime,
        'lastAction': _lastAction,
        'lastActionTeam': _lastActionTeam,
        'lastActionPlayer': _lastActionPlayer,
        'lastActionWasFault': _lastActionWasFault,
        'lastActionWasLet': _lastActionWasLet,
      };

      // // Update player points //before dues
      // _playerPoints[player] = (_playerPoints[player] ?? 0) + 1;

      // // Check if this action will complete a set BEFORE updating scores
      // bool willCompleteSet = false;
      // if (team == 1) {
      //   willCompleteSet = (_team1Points[_currentSet] + 1) >= pointsToWinSet;
      // } else {
      //   willCompleteSet = (_team2Points[_currentSet] + 1) >= pointsToWinSet;
      // }

      // // Add to history with set information
      // final scoreAction = ScoreAction(
      //   action: action,
      //   team: team,
      //   player: player,
      //   isFault: isFault,
      //   isLet: isLet,
      //   timestamp: DateTime.now(),
      //   setNumber:
      //       _currentSet, // Store the set number when this action occurred
      //   completedSet:
      //       willCompleteSet, // Track if this action will complete a set
      // );
      // _history.add(scoreAction);

      // // Update last action
      // _lastAction = action;
      // _lastActionTeam = team;
      // _lastActionPlayer = player;
      // _lastActionWasFault = isFault;
      // _lastActionWasLet = isLet;

      // // Save to backend
      // final scoreData = {
      //   'team1Points': _team1Points.join(','),
      //   'team2Points': _team2Points.join(','),
      //   'currentSet': _currentSet,
      //   'team1Sets': _team1Sets,
      //   'team2Sets': _team2Sets,
      //   'matchOver': _matchOver,
      //   'winner': _winner,
      //   'winnerTeam': _matchOver ? (_winner == team1Display ? 1 : 2) : null,
      //   'playerPoints': _playerPoints.toString(),
      //   'isTeam1Serving': _isTeam1Serving,
      //   'matchDuration': _matchDuration,
      //   'currentGameTime': _currentGameTime,
      //   'lastAction': _lastAction,
      //   'lastActionTeam': _lastActionTeam,
      //   'lastActionPlayer': _lastActionPlayer,
      //   'lastActionWasFault': _lastActionWasFault,
      //   'lastActionWasLet': _lastActionWasLet,
      // };

      // await _repository.updateBadmintonScore(_matchId, scoreData);
      print("Score updated: Team $scoringTeam scored. Action: $action");
    } catch (e) {
      _errorMessage = 'Failed to update score: $e';
      smartPrintError("Error updating score: $e");
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Undo last action
  Future<void> undoLastAction() async {
    try {
      // Undo can be performed even when match is paused

      if (_history.isNotEmpty) {
        final lastAction = _history.removeLast();

// If last action was a LET, do not change scores or sets
        if (lastAction.isLet) {
          // Update last action pointers to previous (if any)
          if (_history.isNotEmpty) {
            final previousAction = _history.last;
            _lastAction = previousAction.action;
            _lastActionTeam = previousAction.team;
            _lastActionPlayer = previousAction.player;
            _lastActionWasFault = previousAction.isFault;
            _lastActionWasLet = previousAction.isLet;
          } else {
            _lastAction = '';
            _lastActionTeam = 0;
            _lastActionPlayer = '';
            _lastActionWasFault = false;
            _lastActionWasLet = false;
          }

          smartPrint("Undid a LET - no score change");
          notifyListeners();
          return;
        }
        // Check if we need to revert a set completion using stored information
        if (lastAction.completedSet) {
          // This action completed a set, so we need to go back to the previous set
          if (lastAction.team == 1 && _team1Sets > 0) {
            _team1Sets--;
            smartPrint("Undoing set completion for Team 1 - reducing sets won");
          } else if (lastAction.team == 2 && _team2Sets > 0) {
            _team2Sets--;
            smartPrint("Undoing set completion for Team 2 - reducing sets won");
          }

          // Move back to the set where this action occurred (which completed the set)
          _currentSet = lastAction.setNumber;
          smartPrint(
              "Moving back to set ${lastAction.setNumber} where set was completed");

          // Restart game timer since we're going back to a previous set
          _restartGameTimer();
        }

        // Revert the score
        if (lastAction.team == 1) {
          _team1Points[_currentSet]--;
          if (_team1Points[_currentSet] < 0) _team1Points[_currentSet] = 0;
        } else {
          _team2Points[_currentSet]--;
          if (_team2Points[_currentSet] < 0) _team2Points[_currentSet] = 0;
        }

        // Check if current set is now empty (0-0) and we should go back to previous set
        if (_team1Points[_currentSet] == 0 &&
            _team2Points[_currentSet] == 0 &&
            _currentSet > 0) {
          // Current set is empty, go back to previous set
          _currentSet--;
          smartPrint(
              "Current set is empty (0-0), moving back to previous set: $_currentSet");

          // Also check if we need to go back further if previous set is also empty
          while (_currentSet > 0 &&
              _team1Points[_currentSet] == 0 &&
              _team2Points[_currentSet] == 0) {
            _currentSet--;
            smartPrint(
                "Previous set also empty, moving back to set: $_currentSet");
          }
        }

        // Revert player points
        // _playerPoints[lastAction.player] =
        //     (_playerPoints[lastAction.player] ?? 1) - 1;
        // if (_playerPoints[lastAction.player]! < 0)
        //   _playerPoints[lastAction.player] = 0;
        // Revert player points using team-aware key
        final slotUndoKey = _slotKeyFor(lastAction.team, lastAction.player);
        _playerPoints[slotUndoKey] = (_playerPoints[slotUndoKey] ?? 1) - 1;
        if (_playerPoints[slotUndoKey]! < 0) _playerPoints[slotUndoKey] = 0;

        // Also keep legacy plain key in sync if it exists
        final teamNameUndoKey =
            _playerKeyFor(lastAction.team, lastAction.player);
        if (_playerPoints.containsKey(teamNameUndoKey)) {
          _playerPoints[teamNameUndoKey] =
              (_playerPoints[teamNameUndoKey] ?? 1) - 1;
          if ((_playerPoints[teamNameUndoKey] ?? 0) < 0) {
            _playerPoints[teamNameUndoKey] = 0;
          }
        }
        // Also keep legacy plain key in sync if it exists
        if (_playerPoints.containsKey(lastAction.player)) {
          _playerPoints[lastAction.player] =
              (_playerPoints[lastAction.player] ?? 1) - 1;

          if ((_playerPoints[lastAction.player] ?? 0) < 0) {
            _playerPoints[lastAction.player] = 0;
          }
        }

        // Check if match was over and needs to be reverted
        if (_matchOver) {
          _matchOver = false;
          _winner = null;
        }

        // Update last action
        if (_history.isNotEmpty) {
          final previousAction = _history.last;
          _lastAction = previousAction.action;
          _lastActionTeam = previousAction.team;
          _lastActionPlayer = previousAction.player;
          _lastActionWasFault = previousAction.isFault;
          _lastActionWasLet = previousAction.isLet;
        } else {
          _lastAction = '';
          _lastActionTeam = 0;
          _lastActionPlayer = '';
          _lastActionWasFault = false;
          _lastActionWasLet = false;
        }

        smartPrint(
            "Last action undone - Team ${lastAction.team} score reverted");
        smartPrint(
            "Current set: $_currentSet, Team1 sets: $_team1Sets, Team2 sets: $_team2Sets");
        smartPrint(
            "Current scores - Team1: ${_team1Points[_currentSet]}, Team2: ${_team2Points[_currentSet]}");
        smartPrint(
            "All set scores - Team1: $_team1Points, Team2: $_team2Points");

        // Validate sets count after undo to prevent incorrect winner detection
        _validateSetsCount();

        notifyListeners();
      }
    } catch (e) {
      smartPrintError("Error undoing action: $e");
    }
  }

  // Validate sets count to prevent incorrect winner detection
  void _validateSetsCount() {
    // Count actual sets won based on completed sets //before dues
    // int actualTeam1Sets = 0;
    // int actualTeam2Sets = 0;

    // for (int i = 0; i < _team1Points.length; i++) {
    //   if (_team1Points[i] >= pointsToWinSet) {
    //     actualTeam1Sets++;
    //   } else if (_team2Points[i] >= pointsToWinSet) {
    //     actualTeam2Sets++;
    //   }
    // }

    // Count actual sets won based on completed sets with badminton rules
    int actualTeam1Sets = 0;
    int actualTeam2Sets = 0;

    for (int i = 0; i < _team1Points.length; i++) {
      final int t1 = _team1Points[i];
      final int t2 = _team2Points[i];
      final bool t1Wins =
          ((t1 >= pointsToWinSet) && ((t1 - t2) >= 2)) || (t1 == maxPoints);
      final bool t2Wins =
          ((t2 >= pointsToWinSet) && ((t2 - t1) >= 2)) || (t2 == maxPoints);
      if (t1Wins && !t2Wins) {
        actualTeam1Sets++;
      } else if (t2Wins && !t1Wins) {
        actualTeam2Sets++;
      }
    }

    // Update sets count to match actual completed sets
    if (_team1Sets != actualTeam1Sets) {
      smartPrint("Correcting Team 1 sets: $_team1Sets -> $actualTeam1Sets");
      _team1Sets = actualTeam1Sets;
    }

    if (_team2Sets != actualTeam2Sets) {
      smartPrint("Correcting Team 2 sets: $_team2Sets -> $actualTeam2Sets");
      _team2Sets = actualTeam2Sets;
    }

    // Check if match should be over based on corrected sets
    if (_team1Sets >= setsToWin || _team2Sets >= setsToWin) {
      _matchOver = true;
      _winner = _team1Sets >= setsToWin ? team1Display : team2Display;
      _stopAllTimers();
      smartPrint("Match over after sets validation - Winner: $_winner");
    } else if (_matchOver) {
      // If match was over but shouldn't be, revert it
      _matchOver = false;
      _winner = null;
      smartPrint("Match was incorrectly over, reverting to active state");
    }
  }

  // Toggle serve
  void toggleServe() {
    // Check if match is paused
    if (_isPaused) {
      smartPrint("Cannot toggle serve - match is paused");
      return;
    }

    _isTeam1Serving = !_isTeam1Serving;
    notifyListeners();
  }

  // Start timer
  void startTimer() {
    if (!_isTimerRunning) {
      _isTimerRunning = true;
      _matchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _matchDuration++;
        _currentGameTime++;
        notifyListeners();
      });
    }
  }

  // Stop timer
  void stopTimer() {
    _isTimerRunning = false;
    _matchTimer?.cancel();
    notifyListeners();
  }

  // Stop all timers (when match is over)
  void _stopAllTimers() {
    _isTimerRunning = false;
    _matchTimer?.cancel();
    smartPrint("All timers stopped - match completed");
    notifyListeners();
  }

  // Restart game timer (when new set starts)
  void _restartGameTimer() {
    // Save current game time to the completed set
    if (_currentSet > 0) {
      _gameTimes[_currentSet - 1] = _currentGameTime;
      smartPrint(
          "Saved game time for set ${_currentSet}: ${_currentGameTime} seconds");
    }

    _currentGameTime = 0;
    smartPrint("Game timer restarted for new set");
    notifyListeners();
  }

  // Pause match
  Future<void> pauseMatch() async {
    try {
      _isPaused = true;
      _isTimerRunning = false;
      _matchTimer?.cancel();
      // await _repository.pauseMatch(_matchId);
      smartPrint("Match paused - all controls disabled");
      notifyListeners();
    } catch (e) {
      smartPrintError("Error pausing match: $e");
    }
  }

  // Resume match
  Future<void> resumeMatch() async {
    try {
      _isPaused = false;
      startTimer(); // Call startTimer first, it will set _isTimerRunning = true
      // await _repository.resumeMatch(_matchId);
      smartPrint("Match resumed - controls enabled");
      notifyListeners();
    } catch (e) {
      smartPrintError("Error resuming match: $e");
    }
  }

  // End match
  Future<void> endMatch() async {
    try {
      _matchOver = true;
      _isTimerRunning = false;
      _matchTimer?.cancel();

      // Determine winner
      if (_team1Sets > _team2Sets) {
        _winner = team1Display;
      } else if (_team2Sets > _team1Sets) {
        _winner = team2Display;
      } else {
        // If sets are equal, check points in current set
        if (_team1Points[_currentSet] > _team2Points[_currentSet]) {
          _winner = team1Display;
        } else {
          _winner = team2Display;
        }
      }

      await _repository.endMatch(_matchId, {'winner': _winner!});
      smartPrint("Match ended. Winner: $_winner");
      notifyListeners();
    } catch (e) {
      smartPrintError("Error ending match: $e");
    }
  }

  // Save match history
  Future<void> saveMatchHistory() async {
    try {
      // Prepare current match data for saving
      final scoreData = {
        'gameNumber': _currentSet + 1, // 1, 2 or 3
        'matchType': _matchData?.matchType ?? 'Unknown',
        'player1': _matchData?.player1 ?? '',
        'player2': _matchData?.player2 ?? '',
        'team1Name': _matchData?.team1Name ?? 'Team 1',
        'team2Name': _matchData?.team2Name ?? 'Team 2',
        'team1Player1': _matchData?.team1Player1 ?? '',
        'team1Player2': _matchData?.team1Player2 ?? '',
        'team2Player1': _matchData?.team2Player1 ?? '',
        'team2Player2': _matchData?.team2Player2 ?? '',
        'team1Points': _team1Points.join(','),
        'team2Points': _team2Points.join(','),
        'gameTimes': _gameTimes.join(','), // ✅ Save game times
        'playerPoints': _playerPoints.toString(),
        'currentSet': _currentSet,
        'team1Sets': _team1Sets,
        'team2Sets': _team2Sets,
        'matchOver': _matchOver,
        'completed': _matchOver,
        'winnerTeam': _matchOver ? (_winner == team1Display ? 1 : 2) : null,
        'preferred_sport': 'Badminton',
        'match_id': _matchId,
        // ✅ Add timer data
        'matchDuration': _matchDuration,
        'currentGameTime': _currentGameTime,
        'isTimerRunning': _isTimerRunning,
        'isPaused': _isPaused,
      };

      await _repository.updateBadmintonScore(_matchId, scoreData);
      smartPrint(
          "Match history saved via updateBadmintonScore with timer data");
    } catch (e) {
      smartPrintError("Error saving match history: $e");
    }
  }

  // Get match statistics
  Future<Map<String, dynamic>> getMatchStatistics() async {
    try {
      return await _repository.getMatchStatistics(_matchId);
    } catch (e) {
      smartPrintError("Error getting match statistics: $e");
      return {};
    }
  }

  // Initialize match
  Future<void> initializeMatch(int matchId) async {
    _matchId = matchId;
    await fetchMatchData(matchId);

    // Always start in paused state when navigating to the screen
    if (!_matchOver) {
      _isPaused = true;
      _isTimerRunning = false;
      _matchTimer?.cancel();
      smartPrint("Match initialized - always starting in paused state");
    }

    smartPrint(
        "Match initialized with timer state: running=${_isTimerRunning}, paused=${_isPaused}");
  }

  // Reset match
  Future<void> resetMatch() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Reset all game state
      _team1Points = [0, 0, 0];
      _team2Points = [0, 0, 0];
      _gameTimes = [0, 0, 0]; // ✅ Reset game times
      _currentSet = 0;
      _team1Sets = 0;
      _team2Sets = 0;
      _matchOver = false;
      _winner = null;
      _history.clear();
      _playerPoints.clear();
      _isTeam1Serving = true;
      _matchDuration = 0;
      _currentGameTime = 0;
      _gameTimes[0] = 0; // Reset current set game time
      _lastAction = '';
      _lastActionTeam = 0;
      _lastActionPlayer = '';
      _lastActionWasFault = false;
      _lastActionWasLet = false;

      // Stop current timer and keep in paused state
      _matchTimer?.cancel();
      _isTimerRunning = false;
      _isPaused = true; // Keep the game in paused state after reset

      // Save reset state to backend
      final resetData = {
        'team1Points': _team1Points.join(','),
        'team2Points': _team2Points.join(','),
        'gameTimes': _gameTimes.join(','), // ✅ Reset game times
        'currentSet': _currentSet,
        'team1Sets': _team1Sets,
        'team2Sets': _team2Sets,
        'matchOver': _matchOver,
        'winner': _winner,
        'winnerTeam': null,
        'playerPoints': _playerPoints.toString(),
        'isTeam1Serving': _isTeam1Serving,
        'matchDuration': _matchDuration,
        'currentGameTime': _currentGameTime,
        'lastAction': _lastAction,
        'lastActionTeam': _lastActionTeam,
        'lastActionPlayer': _lastActionPlayer,
        'lastActionWasFault': _lastActionWasFault,
        'lastActionWasLet': _lastActionWasLet,
        'isTimerRunning': _isTimerRunning,
        'isPaused': _isPaused,
      };

      await _repository.updateBadmintonScore(_matchId, resetData);
      smartPrint("Match reset successfully");
    } catch (e) {
      _errorMessage = 'Failed to reset match: $e';
      smartPrintError("Error resetting match: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Dispose
  @override
  void dispose() {
    _matchTimer?.cancel();
    super.dispose();
  }
}
