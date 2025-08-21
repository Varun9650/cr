import 'dart:convert'; // Added for jsonDecode and jsonEncode

import 'package:flutter/material.dart';

import '../points_table/points_table_service.dart';
import 'bracket_service.dart';

class BracketViewModel extends ChangeNotifier {
  final BracketService _bracketService = BracketService();
  final PointsTableService _pointsService = PointsTableService();

  void Function(String matchId, String winnerTeam, String loserTeam)?
      onWinnerSelectedHook;

  // State variables
  List<Map<String, dynamic>> _brackets = [];
  Map<String, dynamic>? _currentBracket;
  List<Map<String, dynamic>> _bracketStructure = [];
  String _selectedGroup = '';
  bool _isLoading = false;
  String? _errorMessage;
  int _tournamentId = 0;
  List<String> _allTeams = [];
  int _selectedRound = 1; // Default to round 1
  final Map<String, int> _teamNameToId = {};
  int _totalRounds = 0;
  String _teamSearchQuery = '';

  // Getters
  List<Map<String, dynamic>> get brackets => _brackets;
  Map<String, dynamic>? get currentBracket => _currentBracket;
  List<Map<String, dynamic>> get bracketStructure => _bracketStructure;
  String get selectedGroup => _selectedGroup;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get tournamentId => _tournamentId;
  int get selectedRound => _selectedRound;
  int? teamIdByName(String name) => _teamNameToId[name];
  int get totalRounds => _totalRounds;
  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Inject/override team id mapping from UI/service
  void setTeamIdMapping(Map<String, int> mapping) {
    _teamNameToId
      ..clear()
      ..addAll(mapping);
    notifyListeners();
  }

  // Filter teams by search query (applies to current round view)
  void filterTeamsBySearch(String query) {
    _teamSearchQuery = query.toLowerCase().trim();
    notifyListeners();
  }

  // Set tournament ID
  void setTournamentId(int tournamentId) {
    _tournamentId = tournamentId;
    notifyListeners();
  }

  // Set selected group
  void setSelectedGroup(String groupName) {
    _selectedGroup = groupName;
    notifyListeners();
  }

  // Set selected round
  void setSelectedRound(int round) {
    _selectedRound = round;
    notifyListeners();
  }

  // Fetch all brackets for tournament
  Future<void> fetchAllBrackets(int tournamentId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final brackets = await _bracketService.getAllBrackets(tournamentId);
      _brackets = brackets;
      _tournamentId = tournamentId;
    } catch (e) {
      _errorMessage = 'Failed to fetch brackets: $e';
      print('Error fetching brackets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch bracket for specific group
  Future<void> fetchBracketForGroup(int tournamentId, String groupName) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final bracket = await _bracketService.getBracket(tournamentId, groupName);
      print('Fetched bracket: $bracket'); // Debugging output

      // Check if the fetched bracket is marked as deleted
      if (bracket != null) {
        try {
          final modelData = bracket['model'];
          if (modelData != null) {
            final parsedModel = jsonDecode(modelData);
            // Check if this bracket is marked as deleted
            if (parsedModel['deleted_at'] != null ||
                parsedModel['is_deleted'] == true ||
                (parsedModel['teams'] != null &&
                    parsedModel['teams'].isEmpty) ||
                (parsedModel['structure'] != null &&
                    parsedModel['structure'].isEmpty)) {
              print('Detected deleted bracket, showing empty state');
              _currentBracket = null;
              _bracketStructure = [];
              _allTeams = [];
              _totalRounds = 0;
              _selectedRound = 1;
              _teamNameToId.clear();
              _selectedGroup = groupName;
              _tournamentId = tournamentId;
              notifyListeners();
              return;
            }
          }
        } catch (e) {
          print('Error parsing bracket model: $e');
        }
      }

      _currentBracket = bracket;
      _selectedGroup = groupName;
      _tournamentId = tournamentId; // Set tournament ID
      print('Current bracket: $_currentBracket'); // Debugging output
      _totalRounds = (bracket?['total_round'] is int)
          ? bracket!['total_round'] as int
          : int.tryParse('${bracket?['total_round']}') ?? 0;
      if (bracket != null) {
        print("Bracket data received: ${bracket['model']}");

        // Parse the model JSON to get bracket structure
        if (bracket['model'] != null) {
          final modelData = jsonDecode(bracket['model']);
          print("Parsed model data: $modelData");

          _bracketStructure =
              List<Map<String, dynamic>>.from(modelData['structure'] ?? []);
          print(
              "Bracket structure loaded: ${_bracketStructure.length} matches");

          // Set all teams from the saved data
          if (modelData['teams'] != null) {
            _allTeams = List<String>.from(
                modelData['teams'].map((t) => t['team_name'].toString()));
            _teamNameToId.clear();
            for (final t in List.from(modelData['teams'])) {
              try {
                final name = t['team_name']?.toString();
                final idRaw = t['team_id'];
                if (name != null && idRaw != null) {
                  final id = int.tryParse(idRaw.toString());
                  if (id != null) _teamNameToId[name] = id;
                }
              } catch (_) {}
            }
            print("Teams loaded: $_allTeams");
          }
        } else {
          _bracketStructure = [];
          print("No model data found in bracket");
        }
      } else {
        _bracketStructure = [];
        print("No bracket data received");
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch bracket for group: $e';
      print('Error fetching bracket for group: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // // Save current bracket
  // Future<bool> saveCurrentBracket(
  //     [int? tournamentId, String? preferredSport]) async {
  //   try {
  //     // _isLoading = true;
  //     _errorMessage = null;
  //     notifyListeners();
  //     print('Saving current bracket: $_currentBracket');

  //     // If no current bracket, this might be an empty state after deletion
  //     if (_currentBracket == null) {
  //       print('No current bracket to save - this might be empty state');
  //       return true; // Return true for empty state
  //     }

  //     // Get teams from current bracket or create from allTeams
  //     List<Map<String, dynamic>> teams;
  //     if (_currentBracket!['teams'] != null) {
  //       teams = List<Map<String, dynamic>>.from(_currentBracket!['teams']);
  //     } else {
  //       // Create teams from allTeams if not available
  //       teams = _allTeams
  //           .map((name) => {
  //                 'team_name': name,
  //                 'team_id': _teamNameToId[name],
  //               })
  //           .toList();
  //     }

  //     // print(
  //     //     "Saving bracket with structure: ${_bracketStructure.length} matches");
  //     // print("Saving bracket with teams: ${teams.length} teams");
  //     // print("Tournament ID: $_tournamentId");

  //     // Prepare bracket data for saving
  //     Map<String, dynamic> bracketData = {
  //       'id': _currentBracket!['id'], // Include ID if updating existing
  //       'name': 'Tournament Bracket',
  //       'description': 'Bracket for $_selectedGroup',
  //       'active': true,
  //       'group_name': _selectedGroup,
  //       'current_round': _selectedRound,
  //       'model': jsonEncode({
  //         'teams': teams,
  //         'structure': _bracketStructure,
  //         'updated_at': DateTime.now().toIso8601String(),
  //       }),
  //       'tournament_id': tournamentId ?? _tournamentId,
  //       'preferred_sport': preferredSport,
  //       'total_round': getTotalRounds(),
  //     };

  //     print("Sending bracket data to API: ${bracketData['model']}");
  //     final savedBracket = await _bracketService.saveBracket(bracketData);

  //     if (savedBracket != null) {
  //       _currentBracket = savedBracket;
  //       print('Bracket saved successfully');
  //       print('Saved bracket response: $savedBracket');
  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     _errorMessage = 'Failed to save bracket: $e';
  //     print('Error saving bracket in viewmodel : $e');
  //     return false;
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // Save current bracket
  Future<bool> saveCurrentBracket(
      [int? tournamentId, String? preferredSport, bool isEmpty = false]) async {
    try {
      // _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      print('Saving current bracket: $_currentBracket');

      // If no current bracket, this might be an empty state after deletion
      if (_currentBracket == null) {
        print('No current bracket to save - this might be empty state');
        return true; // Return true for empty state
      }

      // Get teams from current bracket or create from allTeams
      List<Map<String, dynamic>> teams;
      if (_currentBracket!['teams'] != null) {
        teams = List<Map<String, dynamic>>.from(_currentBracket!['teams']);
      } else {
        // Create teams from allTeams if not available
        teams = _allTeams
            .map((name) => {
                  'team_name': name,
                  'team_id': _teamNameToId[name],
                })
            .toList();
      }

      // print(
      //     "Saving bracket with structure: ${_bracketStructure.length} matches");
      // print("Saving bracket with teams: ${teams.length} teams");
      // print("Tournament ID: $_tournamentId");

      // Prepare bracket data for saving
      Map<String, dynamic> bracketData = {
        'id': _currentBracket!['id'], // Include ID if updating existing
        'name': isEmpty ? 'Deleted Bracket' : 'Tournament Bracket',
        'description': isEmpty
            ? 'Bracket was deleted for $_selectedGroup'
            : 'Bracket for $_selectedGroup',
        'active': !isEmpty, // Set to false if empty
        'group_name': _selectedGroup,
        'model': jsonEncode({
          'teams': isEmpty ? [] : teams,
          'structure': isEmpty ? [] : _bracketStructure,
          'updated_at': DateTime.now().toIso8601String(),
          if (isEmpty) 'deleted_at': DateTime.now().toIso8601String(),
          if (isEmpty) 'is_deleted': true,
        }),
        'tournament_id': tournamentId ?? _tournamentId,
        'preferred_sport':
            preferredSport ?? _currentBracket!['preferred_sport'],
        'total_round': isEmpty ? 0 : getTotalRounds(),
        'current_round': isEmpty ? 1 : _selectedRound,
      };

      print("Sending bracket data to API: ${bracketData['model']}");
      final savedBracket = await _bracketService.saveBracket(bracketData);

      if (savedBracket != null) {
        _currentBracket = savedBracket;
        print('Bracket saved successfully');
        print('Saved bracket response: $savedBracket');
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to save bracket: $e';
      print('Error saving bracket in viewmodel : $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save empty bracket state (after deletion)
  Future<bool> saveEmptyBracketState([String? preferredSport]) async {
    try {
      _errorMessage = null;
      notifyListeners();

      // Update existing bracket with empty state instead of creating new record
      Map<String, dynamic> emptyBracketData = {
        'id': _currentBracket?['id'], // Use existing ID to update
        'name': 'Deleted Bracket',
        'description': 'Bracket was deleted for $_selectedGroup',
        'group_name': _selectedGroup,
        'active': true,
        'model': jsonEncode({
          'teams': [],
          'structure': [],
          'deleted_at': DateTime.now().toIso8601String(),
          'is_deleted': true,
        }),
        'tournament_id': _tournamentId,
        'preferred_sport': preferredSport ??
            _currentBracket?[
                'preferred_sport'], // Keep existing preferred sport
        'total_round': 0,
      };

      print("Updating existing bracket with empty state");
      final saved = await _bracketService.saveBracket(emptyBracketData);

      if (saved != null) {
        print('Bracket updated with empty state successfully');
        // Update current bracket with the saved empty state
        _currentBracket = saved;
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to save empty bracket state: $e';
      print('Error saving empty bracket state: $e');
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Schedule matches: confirm save then call API
  Future<bool> scheduleAllMatches() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (_currentBracket == null || _currentBracket!['id'] == null) {
        throw Exception('No bracket to schedule');
      }

      // Save latest changes before scheduling
      final saved = await saveCurrentBracket(_tournamentId, null);
      if (!saved) throw Exception('Failed to save bracket before scheduling');

      final bracketId = int.tryParse(_currentBracket!['id'].toString());
      if (bracketId == null) throw Exception('Invalid bracket id');

      final response = await _bracketService.scheduleMatches(bracketId);
      print('Scheduled matches response: $response');
      return true;
    } catch (e) {
      _errorMessage = 'Failed to schedule matches: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new bracket for group
  Future<bool> createBracketForGroup(
      int tournamentId, String groupName, List<String> teamNames) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Set allTeams from the original teamNames
      _allTeams = List<String>.from(teamNames);

      // Convert team names to team objects
      List<Map<String, dynamic>> teams = teamNames
          .map((name) => {
                'team_name': name,
                'team_id': _teamNameToId[name],
              })
          .toList();

      final bracket =
          await _bracketService.createBracket(tournamentId, groupName, teams);

      if (bracket != null) {
        // Generate bracket structure
        _bracketStructure = _bracketService.generateBracketStructure(teamNames);

        // Update current bracket
        _currentBracket = {
          'id': bracket['id'],
          'tournament_id': tournamentId,
          'group_name': groupName,
          'teams': teams,
          'structure': _bracketStructure,
        };

        // Add to brackets list
        _brackets.add(_currentBracket!);
        _selectedGroup = groupName;

        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to create bracket: $e';
      print('Error creating bracket: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Winner is selected: do not auto-advance; just mark status and call hook
  Future<bool> updateMatchResult(
      String matchId, String winnerTeam, String loserTeam) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final matchIndex =
          _bracketStructure.indexWhere((m) => m['match_id'] == matchId);
      if (matchIndex == -1) {
        throw Exception('Match not found');
      }
      _bracketStructure[matchIndex]['winner'] = winnerTeam;
      _bracketStructure[matchIndex]['status'] = 'completed';
      notifyListeners();

      // External hook to allow points insertion flow
      if (onWinnerSelectedHook != null) {
        onWinnerSelectedHook!(matchId, winnerTeam, loserTeam);
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update match: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update match result // before poibt tables
  // Future<bool> updateMatchResult(
  //     String matchId, String winnerTeam, String loserTeam) async {
  //   try {
  //     _isLoading = true;
  //     _errorMessage = null;
  //     notifyListeners();

  //     // Find the match in bracket structure
  //     int matchIndex =
  //         _bracketStructure.indexWhere((match) => match['match_id'] == matchId);

  //     if (matchIndex != -1) {
  //       // Update the match result
  //       _bracketStructure[matchIndex]['winner'] = winnerTeam;
  //       _bracketStructure[matchIndex]['status'] = 'completed';

  //       // Update next round match if exists
  //       _updateNextRoundMatch(matchIndex, winnerTeam);

  //       // Update in backend
  //       if (_currentBracket != null) {
  //         int winnerTeamId = _generateTeamId(winnerTeam);
  //         int loserTeamId = _generateTeamId(loserTeam);

  //         await _bracketService.updateMatchResult(_currentBracket!['id'],
  //             _generateMatchId(matchId), winnerTeamId, loserTeamId);
  //       }

  //       return true;
  //     }
  //     return false;
  //   } catch (e) {
  //     _errorMessage = 'Failed to update match result: $e';
  //     print('Error updating match result: $e');
  //     return false;
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // Update match status in bracket structure
  void updateMatchStatus(String matchId, String newStatus) {
    try {
      _bracketService.updateMatchStatus(_bracketStructure, matchId, newStatus);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update match status: $e';
    }
  }

  // Shuffle teams for a round (only if matches are not completed)
  void shuffleRoundTeams(int round) {
    try {
      // Prevent shuffle if any match in this round is completed
      final roundMatches =
          _bracketStructure.where((m) => m['round'] == round).toList();
      if (roundMatches.any((m) => m['status'] == 'completed')) return;

      final int numMatches = roundMatches.length;
      final int totalSlots = numMatches * 2;

      // Build candidate pool
      List<String> pool;
      if (round == 1) {
        pool = List<String>.from(_allTeams.toSet());
      } else {
        // Winners from previous round only
        pool = _bracketStructure
            .where((m) => m['round'] == (round - 1))
            .map((m) => (m['winner'] ?? '').toString())
            .where((w) => w.isNotEmpty && w != 'BYE')
            .toSet()
            .toList();
      }

      // Ensure uniqueness and random order
      pool = pool.toSet().toList();
      pool.shuffle();

      // Compute BYEs needed for this round's capacity
      int byesNeeded =
          (pool.length >= totalSlots) ? 0 : (totalSlots - pool.length);
      // Never allocate more BYEs than teams to avoid BYE vs BYE
      byesNeeded = byesNeeded.clamp(0, pool.length);

      // Build a slots list prioritizing pairing team with BYE first
      final List<String?> slots = [];
      // First add BYEs (so teams pick them up first during pairing)
      for (int i = 0; i < byesNeeded; i++) slots.add('BYE');
      // Then add teams
      for (final t in pool) slots.add(t);

      // Pairing without BYE vs BYE; ensure each team only appears once
      final List<List<String?>> pairs = [];
      final List<String?> teamsQueue = List.from(slots);
      final used = <String>{};

      while (teamsQueue.isNotEmpty) {
        final a = teamsQueue.removeAt(0);
        if (a == 'BYE') {
          final int idx = teamsQueue
              .indexWhere((e) => e != 'BYE' && e != null && !used.contains(e));
          if (idx != -1) {
            final b = teamsQueue.removeAt(idx);
            used.add(b as String);
            pairs.add([b, 'BYE']);
          }
        } else if (a != null && !used.contains(a)) {
          used.add(a);
          final int idx = teamsQueue
              .indexWhere((e) => e != 'BYE' && e != null && !used.contains(e));
          if (idx != -1) {
            final b = teamsQueue.removeAt(idx) as String?;
            if (b != null) used.add(b);
            pairs.add([a, b]);
          } else {
            final int byeIdx = teamsQueue.indexWhere((e) => e == 'BYE');
            if (byeIdx != -1) {
              teamsQueue.removeAt(byeIdx);
              pairs.add([a, 'BYE']);
            }
          }
        }
      }

      // Apply pairs to matches in order
      for (int i = 0; i < roundMatches.length; i++) {
        final match = roundMatches[i];
        final idx = _bracketStructure.indexOf(match);
        if (i < pairs.length) {
          _bracketStructure[idx]['team1'] = pairs[i][0];
          _bracketStructure[idx]['team2'] = pairs[i][1];
          _bracketStructure[idx]['winner'] = null;
          final hasTeam1 = _bracketStructure[idx]['team1'] != null &&
              _bracketStructure[idx]['team1'] != 'BYE';
          final hasTeam2 = _bracketStructure[idx]['team2'] != null &&
              _bracketStructure[idx]['team2'] != 'BYE';
          _bracketStructure[idx]['status'] =
              (hasTeam1 || hasTeam2) ? 'ready' : 'pending';
        } else {
          // Clear extra matches
          _bracketStructure[idx]['team1'] = null;
          _bracketStructure[idx]['team2'] = null;
          _bracketStructure[idx]['winner'] = null;
          _bracketStructure[idx]['status'] = 'pending';
        }
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to shuffle round: $e';
      notifyListeners();
    }
  }

  // Update next round match with winner
  void _updateNextRoundMatch(int currentMatchIndex, String winnerTeam) {
    Map<String, dynamic> currentMatch = _bracketStructure[currentMatchIndex];
    int currentRound = currentMatch['round'];
    int currentMatchNumber = _extractMatchNumber(currentMatch['match_id']);

    // Calculate next round match
    int nextRound = currentRound + 1;
    int nextMatchNumber = (currentMatchNumber + 1) ~/ 2;
    String nextMatchId = 'match_${nextRound}_$nextMatchNumber';

    // Find next round match
    int nextMatchIndex = _bracketStructure
        .indexWhere((match) => match['match_id'] == nextMatchId);

    if (nextMatchIndex != -1) {
      Map<String, dynamic> nextMatch = _bracketStructure[nextMatchIndex];

      // Determine if this winner goes to team1 or team2 slot
      bool isFirstSlot = currentMatchNumber % 2 == 1;

      if (isFirstSlot) {
        nextMatch['team1'] = winnerTeam;
      } else {
        nextMatch['team2'] = winnerTeam;
      }

      // Update status if both teams are filled
      if (nextMatch['team1'] != null && nextMatch['team2'] != null) {
        nextMatch['status'] = 'ready';
      }

      _bracketStructure[nextMatchIndex] = nextMatch;
    }
  }

  // Delete bracket
  Future<bool> deleteBracket(int bracketId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final success = await _bracketService.deleteBracket(bracketId);

      if (success) {
        // Remove from local list
        _brackets.removeWhere((bracket) => bracket['id'] == bracketId);

        // Clear current bracket if it was deleted
        if (_currentBracket != null && _currentBracket!['id'] == bracketId) {
          _currentBracket = null;
          _bracketStructure = [];
          _selectedGroup = '';
        }
      }

      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete bracket: $e';
      print('Error deleting bracket: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get matches for specific round
  List<Map<String, dynamic>> getMatchesForRound(int round) {
    // return _bracketStructure.where((match) => match['round'] == round).toList();
    final matchesForRound =
        _bracketStructure.where((match) => match['round'] == round).toList();
    if (_teamSearchQuery.isEmpty) return matchesForRound;
    return matchesForRound.where((m) {
      final t1 = (m['team1'] ?? '').toString().toLowerCase();
      final t2 = (m['team2'] ?? '').toString().toLowerCase();
      final winner = (m['winner'] ?? '').toString().toLowerCase();
      return t1.contains(_teamSearchQuery) ||
          t2.contains(_teamSearchQuery) ||
          winner.contains(_teamSearchQuery);
    }).toList();
  }

// before point tables
  // // Get total number of rounds
  // int getTotalRounds() {
  //   if (_bracketStructure.isEmpty) return 0;
  //   return _bracketStructure
  //       .map((match) => match['round'])
  //       .reduce((a, b) => a > b ? a : b);
  // }

  // Get total number of rounds
  int getTotalRounds() {
    print('Calculating total rounds from bracket structure $_bracketStructure');
    final rounds = _bracketStructure
        .map((m) => int.tryParse(m['round'].toString()) ?? 0)
        .where((r) => r > 0)
        .toSet()
        .toList()
      ..sort();
    final maxRound = rounds.isEmpty ? 0 : rounds.last;
    _totalRounds = maxRound;
    print('Total rounds calculated: $maxRound');
    return maxRound;
  }

  // Clear bracket state and save empty state
  Future<void> clearBracketState([String? preferredSport]) async {
    try {
      // First save the empty state to persist the deletion
      await saveCurrentBracket(null, preferredSport, true);

      // Then clear local state
      _currentBracket = null;
      _bracketStructure = [];
      _allTeams = [];
      _totalRounds = 0;
      _selectedRound = 1;
      _teamNameToId.clear();

      // Remove from local brackets list
      _brackets.removeWhere((b) => b['group_name'] == _selectedGroup);

      notifyListeners();
    } catch (e) {
      print('Error clearing bracket state: $e');
      _errorMessage = 'Failed to clear bracket state: $e';
      notifyListeners();
    }
  }

  // Get winner of tournament
  String? getTournamentWinner() {
    if (_bracketStructure.isEmpty) return null;

    // Find the final match (highest round)
    int finalRound = getTotalRounds();
    List<Map<String, dynamic>> finalMatches = getMatchesForRound(finalRound);

    if (finalMatches.isNotEmpty) {
      return finalMatches.first['winner'];
    }

    return null;
  }

  // Helper methods

  int _generateMatchId(String matchId) {
    // Extract numeric part from match_id like "match_1_1" -> 11
    return int.tryParse(matchId.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
  }

  int _extractMatchNumber(String matchId) {
    // Extract match number from match_id like "match_1_1" -> 1
    final parts = matchId.split('_');
    return int.tryParse(parts.last) ?? 0;
  }

  // Refresh data
  Future<void> refreshData() async {
    if (_tournamentId > 0) {
      await fetchAllBrackets(_tournamentId);
      if (_selectedGroup.isNotEmpty) {
        await fetchBracketForGroup(_tournamentId, _selectedGroup);
      }
    }
  }

  // Remove a team from a match slot
  void removeTeamFromMatch(String matchId, String teamSlot) {
    int idx = _bracketStructure.indexWhere((m) => m['match_id'] == matchId);
    if (idx != -1) {
      final removedTeam = _bracketStructure[idx][teamSlot];
      print('Removing team: $removedTeam from $matchId, slot: $teamSlot');
      _bracketStructure[idx][teamSlot] = null;
      _bracketStructure[idx]['winner'] = null;
      _bracketStructure[idx]['status'] = 'pending';
      print('Team removed successfully. Available teams should update.');
      notifyListeners();
    } else {
      print('Match not found: $matchId');
    }
  }

  // Add a team to a match slot
  void addTeamToMatch(String matchId, String teamSlot, String teamName) {
    int idx = _bracketStructure.indexWhere((m) => m['match_id'] == matchId);
    if (idx != -1) {
      print('Adding team: $teamName to $matchId, slot: $teamSlot');

      // Enforce uniqueness within the same round: remove from any other match in this round
      final int round =
          int.tryParse(_bracketStructure[idx]['round'].toString()) ?? 1;
      for (int i = 0; i < _bracketStructure.length; i++) {
        if (i == idx) continue;
        final m = _bracketStructure[i];
        if ((int.tryParse(m['round'].toString()) ?? 0) != round) continue;
        if (m['team1'] == teamName) {
          _bracketStructure[i]['team1'] = null;
          _bracketStructure[i]['winner'] = null;
          _bracketStructure[i]['status'] =
              (_bracketStructure[i]['team2'] != null &&
                      _bracketStructure[i]['team2'] != 'BYE')
                  ? 'ready'
                  : 'pending';
        }
        if (m['team2'] == teamName) {
          _bracketStructure[i]['team2'] = null;
          _bracketStructure[i]['winner'] = null;
          _bracketStructure[i]['status'] =
              (_bracketStructure[i]['team1'] != null &&
                      _bracketStructure[i]['team1'] != 'BYE')
                  ? 'ready'
                  : 'pending';
        }
      }

      _bracketStructure[idx][teamSlot] = teamName;
      // If both slots filled, set status to ready
      if (_bracketStructure[idx]['team1'] != null &&
          _bracketStructure[idx]['team2'] != null &&
          _bracketStructure[idx]['team1'] != 'BYE' &&
          _bracketStructure[idx]['team2'] != 'BYE') {
        _bracketStructure[idx]['status'] = 'ready';
      } else {
        _bracketStructure[idx]['status'] = 'pending';
      }
      print('Team added successfully. Available teams should update.');
      notifyListeners();
    } else {
      print('Match not found: $matchId');
    }
  }
// Before Point Tables
  // Get available teams for a round (not assigned to any match in that round)
  // List<String> getAvailableTeamsForRound(int round) {
  //   // Get assigned teams in current round
  //   final assigned = <String>{};
  //   final currentRoundMatches =
  //       _bracketStructure.where((m) => m['round'] == round).toList();
  //   for (var match in currentRoundMatches) {
  //     if (match['team1'] != null && match['team1'] != 'BYE')
  //       assigned.add(match['team1']);
  //     if (match['team2'] != null && match['team2'] != 'BYE')
  //       assigned.add(match['team2']);
  //   }

  //   // For Round 1: use original teams
  //   if (round == 1) {
  //     return _allTeams.where((t) => !assigned.contains(t)).toList();
  //   }

  //   // For other rounds: use winners from previous round
  //   final previousRoundMatches =
  //       _bracketStructure.where((m) => m['round'] == round - 1).toList();
  //   final previousRoundWinners = <String>{};

  //   for (var match in previousRoundMatches) {
  //     if (match['winner'] != null && match['winner'] != 'BYE') {
  //       previousRoundWinners.add(match['winner']);
  //     }
  //   }

  //   // Available = previous round winners - assigned in current round
  //   final available =
  //       previousRoundWinners.where((t) => !assigned.contains(t)).toList();

  //   print('Round $round - Previous winners: $previousRoundWinners');
  //   print('Round $round - Assigned: $assigned');
  //   print('Round $round - Available: $available');

  //   return available;
  // }

  // Get available teams for selected round
  List<String> getAvailableTeamsForSelectedRound() {
    return getAvailableTeamsForRound(_selectedRound);
  }

  List<String> getAvailableTeamsForRound(int round) {
    // Collect teams already assigned in this round (excluding BYE)
    final assigned = <String>{};
    final currentRoundMatches =
        _bracketStructure.where((m) => m['round'] == round).toList();
    for (var match in currentRoundMatches) {
      final t1 = match['team1'];
      final t2 = match['team2'];
      if (t1 != null && t1 != 'BYE') assigned.add(t1);
      if (t2 != null && t2 != 'BYE') assigned.add(t2);
    }

    // Round 1: from original team list
    if (round == 1) {
      return _allTeams.where((t) => !assigned.contains(t)).toList();
    }

    // Later rounds: winners from previous round
    final previousRoundMatches =
        _bracketStructure.where((m) => m['round'] == round - 1).toList();
    final previousRoundWinners = <String>{};
    for (var match in previousRoundMatches) {
      final w = match['winner'];
      if (w != null && w != 'BYE') previousRoundWinners.add(w);
    }

    final available =
        previousRoundWinners.where((t) => !assigned.contains(t)).toList();
    return available;
  }

  // int getTotalRounds() {
  //   final rounds = _bracketStructure
  //       .map((m) => int.tryParse(m['round'].toString()) ?? 0)
  //       .where((r) => r > 0)
  //       .toSet()
  //       .toList()
  //     ..sort();
  //   return rounds.isEmpty ? 0 : rounds.last;
  // }

  Future<int> assignTeamsToRound(
      // BuildContext context,
      int round,
      List<String> teamNames) async {
    // Collect empty slots in the target round
    final matches = getMatchesForRound(round);
    final List<MapEntry<int, String>> emptySlots = [];
    for (int i = 0; i < matches.length; i++) {
      final m = matches[i];
      if (m['team1'] == null ||
          m['team1'] == 'BYE' ||
          m['team1'].toString().isEmpty) {
        emptySlots.add(MapEntry(i, 'team1'));
      }
      if (m['team2'] == null ||
          m['team2'] == 'BYE' ||
          m['team2'].toString().isEmpty) {
        emptySlots.add(MapEntry(i, 'team2'));
      }
    }

    int assigned = 0;
    for (int t = 0; t < teamNames.length && assigned < emptySlots.length; t++) {
      final slot = emptySlots[assigned];
      final idx = slot.key;
      final key = slot.value;
      _bracketStructure[_bracketStructure.indexOf(matches[idx])][key] =
          teamNames[t];
      assigned++;
    }

    // Update match statuses to ready where both teams present
    for (final m in matches) {
      final team1 = m['team1'];
      final team2 = m['team2'];
      if (team1 != null &&
          team1 != 'BYE' &&
          team1.toString().isNotEmpty &&
          team2 != null &&
          team2 != 'BYE' &&
          team2.toString().isNotEmpty) {
        m['status'] = 'ready';
      }
    }

    notifyListeners();
    await saveCurrentBracket();
    //  yha jb next round ke liye team ko promote kr rhe hai tb points table me bhi us sabhi team ko add krna hoga
    // await _pointsTableViewModel.addTeamsToPointsTable(teamNames);

    // await _pointsService.createPoints(
    //   matchId: matchNumericId,
    //   teamId: teamId,
    //   tournamentId: tournamentId,
    //   points: points,
    //   round: 'Round $round',
    //   category: groupName,
    // );

    return assigned;
  }

  // void refreshData() {
  //   if (_tournamentId > 0 && _selectedGroup.isNotEmpty) {
  //     fetchBracketForGroup(_tournamentId, _selectedGroup);
  //   }
  // }
}
