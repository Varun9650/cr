import 'package:cricyard/data/network/network_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/resources/api_constants.dart';
import 'dart:convert';

class BracketService {
  final NetworkApiService _networkApiService = NetworkApiService();

  // Get bracket by tournament and group
  Future<Map<String, dynamic>?> getBracket(
      int tournamentId, String groupName) async {
    try {
      final response = await _networkApiService.getGetApiResponse(
        '${ApiConstants.baseUrl}/Bracket/Bracket/tournament?tourId=$tournamentId&groupName=$groupName',
      );

      print("Bracket response: $response");
      if (response != null) {
        print("Successfully fetched bracket for group: $groupName");
        return response;
      } else {
        print("No bracket found for group: $groupName");
        return null;
      }
    } catch (e) {
      print("Error fetching bracket: $e");
      return null;
    }
  }

  // Create tournament bracket
  Future<Map<String, dynamic>?> createBracket(int tournamentId,
      String groupName, List<Map<String, dynamic>> teams) async {
    try {
      // Generate bracket structure
      final bracketStructure = generateBracketStructure(
          teams.map((t) => t['team_name'].toString()).toList());
      // Compute total rounds
      final totalRounds = _computeTotalRounds(bracketStructure);
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final preferredSport = prefs.getString('preferred_sport');

      // Create bracket data
      Map<String, dynamic> bracketData = {
        'name': 'Tournament Bracket',
        'description': 'Bracket for $groupName',
        'active': true,
        'group_name': groupName,
        'model': jsonEncode({
          'teams': teams,
          'structure': bracketStructure,
          'created_at': DateTime.now().toIso8601String(),
        }),
        'tournament_id': tournamentId,
        'preferred_sport': preferredSport,
        'total_round': totalRounds,
      };

      final response = await _networkApiService.getPostApiResponse(
        '${ApiConstants.baseUrl}/Bracket/Bracket',
        bracketData,
      );

      if (response != null) {
        print("Successfully created bracket for group: $groupName");
        return response;
      } else {
        throw Exception('Failed to create bracket: No response received');
      }
    } catch (e) {
      print("Error creating bracket: $e");
      throw Exception('Failed to create bracket: $e');
    }
  }

  // Save bracket data
  Future<Map<String, dynamic>?> saveBracket(
      Map<String, dynamic> bracketData) async {
    try {
      print("BracketService: Saving bracket data: $bracketData");

      final response = await _networkApiService.getPostApiResponse(
        '${ApiConstants.baseUrl}/Bracket/Bracket',
        bracketData,
      );

      print("BracketService: API response: $response");

      if (response != null) {
        print("Successfully saved bracket");
        return response;
      } else {
        throw Exception('Failed to save bracket: No response received');
      }
    } catch (e) {
      print("Error saving bracket: $e");
      throw Exception('Failed to save bracket: $e');
    }
  }

  // Schedule matches for a bracket
  Future<dynamic> scheduleMatches(int bracketId) async {
    try {
      final url =
          '${ApiConstants.baseUrl}/Bracket/Bracket/schedule?bracketId=$bracketId';
      print('Scheduling matches via: $url');
      final response = await _networkApiService.getPostApiResponse(
        url,
        {},
      );
      print('Schedule response: $response');
      return response;
    } catch (e) {
      print('Error scheduling matches: $e');
      throw Exception('Failed to schedule matches: $e');
    }
  }

  // Update match result in bracket
  Future<bool> updateMatchResult(
      int bracketId, int matchId, int winnerTeamId, int loserTeamId) async {
    try {
      // For now, return true since API doesn't exist yet
      // TODO: Implement actual API call when backend is ready
      print(
          "Successfully updated match result locally (API not implemented yet)");
      return true;

      // Uncomment when API is ready:
      /*
      final token = await TokenManager.getToken();
      if (token == null) throw Exception('Token is null');

      Map<String, dynamic> matchResult = {
        'winner_team_id': winnerTeamId,
        'loser_team_id': loserTeamId,
        'updated_at': DateTime.now().toIso8601String(),
      };

      dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await dio.put(
          '$baseUrl/tournament/bracket/match/$matchId/result',
          data: matchResult);

      if (response.statusCode == 200) {
        print("Successfully updated match result");
        return true;
      } else {
        throw Exception(
            'Failed to update match result: ${response.statusCode}');
      }
      */
    } catch (e) {
      print("Error updating match result: $e");
      return false;
    }
  }

  // Update match status in bracket structure
  void updateMatchStatus(List<Map<String, dynamic>> bracketStructure,
      String matchId, String newStatus) {
    final index = bracketStructure.indexWhere((m) => m['match_id'] == matchId);
    if (index != -1) {
      bracketStructure[index]['status'] = newStatus;
    }
  }

  // Shuffle teams for a round (only if matches are not completed)
  void shuffleRoundTeams(
      List<Map<String, dynamic>> bracketStructure, int round) {
    // Get all matches for this round
    final matches = bracketStructure.where((m) => m['round'] == round).toList();
    // Only shuffle if all matches are not completed
    if (matches.any((m) => m['status'] == 'completed')) return;

    // Collect all teams and count dummy slots present in this round
    final List<String> assignedUnique = [];
    int dummySlots = 0;
    for (var match in matches) {
      final t1 = match['team1'];
      final t2 = match['team2'];
      if (t1 != null && t1 != 'BYE' && !assignedUnique.contains(t1)) {
        assignedUnique.add(t1);
      } else if (t1 == null || t1 == 'BYE') {
        dummySlots++;
      }
      if (t2 != null && t2 != 'BYE' && !assignedUnique.contains(t2)) {
        assignedUnique.add(t2);
      } else if (t2 == null || t2 == 'BYE') {
        dummySlots++;
      }
    }

    // Randomize unique teams
    assignedUnique.shuffle();

    // Build pairs: fill BYE first, then pair remaining teams uniquely
    final List<List<String?>> pairs = [];
    int useDummy = dummySlots.clamp(0, assignedUnique.length);
    for (int i = 0; i < useDummy; i++) {
      pairs.add([assignedUnique[i], 'BYE']);
    }
    int idx = useDummy;
    while (idx + 1 < assignedUnique.length) {
      pairs.add([assignedUnique[idx], assignedUnique[idx + 1]]);
      idx += 2;
    }
    if (idx < assignedUnique.length) {
      // One team left, give a BYE
      pairs.add([assignedUnique[idx], 'BYE']);
    }

    // Reassign pairs to matches without duplicating any team
    int p = 0;
    for (var match in matches) {
      if (p < pairs.length) {
        match['team1'] = pairs[p][0];
        match['team2'] = pairs[p][1];
        match['winner'] = null;
        final hasTeam1 = match['team1'] != null && match['team1'] != 'BYE';
        final hasTeam2 = match['team2'] != null && match['team2'] != 'BYE';
        match['status'] = (hasTeam1 || hasTeam2) ? 'ready' : 'pending';
        p++;
      } else {
        // No more pairs -> clear this match, treat both as BYE (no team)
        match['team1'] = null;
        match['team2'] = null;
        match['winner'] = null;
        match['status'] = 'pending';
      }
    }
  }

  // Get all brackets for a tournament
  Future<List<Map<String, dynamic>>> getAllBrackets(int tournamentId) async {
    try {
      final url =
          '${ApiConstants.baseUrl}/Bracket/Bracket/tournament?tourId=$tournamentId';
      print('Fetching all brackets via: $url');

      final response = await _networkApiService.getGetApiResponse(url);
      print('Get all brackets response: $response');

      if (response != null) {
        print(
            "Successfully fetched all brackets for tournament: $tournamentId");
        return List<Map<String, dynamic>>.from(response);
      } else {
        print("No brackets found for tournament: $tournamentId");
        return [];
      }
    } catch (e) {
      print("Error fetching all brackets: $e");
      return [];
    }
  }

  // Delete bracket
  Future<bool> deleteBracket(int bracketId) async {
    try {
      final url = '${ApiConstants.baseUrl}/Bracket/Bracket/$bracketId';
      print('Deleting bracket via: $url');

      final response = await _networkApiService.getDeleteApiResponse(url);
      print('Delete response: $response');

      // Delete API can return empty response or response with data on success
      // Both cases should be considered as successful deletion
      if (response != null) {
        print("Successfully deleted bracket");
        return true;
      } else {
        // Even if response is null/empty, consider it success for delete operations
        // as some delete APIs return empty responses on successful deletion
        print("Delete operation completed (empty response)");
        return true;
      }
    } catch (e) {
      print("Error deleting bracket: $e");
      return false;
    }
  }

  // Helper to compute max round in structure
  int _computeTotalRounds(List<Map<String, dynamic>> structure) {
    int maxRound = 0;
    for (final m in structure) {
      final r = int.tryParse(m['round'].toString()) ?? 0;
      if (r > maxRound) maxRound = r;
    }
    return maxRound;
  }

  // Generate bracket structure for teams
  List<Map<String, dynamic>> generateBracketStructure(List<String> teamNames) {
    List<Map<String, dynamic>> bracketStructure = [];

    // Deduplicate team names to avoid duplicates in the bracket
    final List<String> uniqueTeams = teamNames.toSet().toList();

    // Calculate number of rounds needed â pad to next power of two
    int numTeams = uniqueTeams.length;
    int numRounds =
        (numTeams <= 1) ? 1 : (numTeams - 1).bitLength; // ceil(log2)

    // Total slots and dummies to reach power of two
    int totalSlots = 1 << numRounds; // 2^numRounds
    int byes = totalSlots - numTeams;

    // Prepare team pools
    List<String> actualTeams = List.from(uniqueTeams);
    actualTeams.shuffle();

    // Build first round pairs: prioritize actual vs BYE, then actual vs actual. Never BYE vs BYE.
    final List<List<String?>> firstRoundPairs = [];
    int useByes = byes.clamp(0, actualTeams.length);
    for (int i = 0; i < useByes; i++) {
      firstRoundPairs.add([actualTeams[i], 'BYE']);
    }
    int idx = useByes;
    while (idx + 1 < actualTeams.length) {
      firstRoundPairs.add([actualTeams[idx], actualTeams[idx + 1]]);
      idx += 2;
    }
    if (idx < actualTeams.length) {
      // One team left, give a BYE
      firstRoundPairs.add([actualTeams[idx], 'BYE']);
    }

    // Create first round matches
    for (int i = 0; i < firstRoundPairs.length; i++) {
      final pair = firstRoundPairs[i];
      final team1 = pair[0];
      final team2 = pair[1];
      final hasTeam1 = team1 != null && team1 != 'BYE';
      final hasTeam2 = team2 != null && team2 != 'BYE';
      bracketStructure.add({
        'round': 1,
        'match_id': 'match_1_${i + 1}',
        'team1': team1,
        'team2': team2,
        'winner': null,
        // Mark ready if at least one real team is present; pending otherwise
        'status': (hasTeam1 || hasTeam2) ? 'ready' : 'pending',
      });
    }

    // Generate subsequent rounds structure
    for (int round = 2; round <= numRounds; round++) {
      int matchesInRound = totalSlots >> round; // 2^(numRounds - round)
      for (int match = 1; match <= matchesInRound; match++) {
        bracketStructure.add({
          'round': round,
          'match_id': 'match_${round}_$match',
          'team1': null,
          'team2': null,
          'winner': null,
          'status': 'pending',
        });
      }
    }

    return bracketStructure;
  }
}
