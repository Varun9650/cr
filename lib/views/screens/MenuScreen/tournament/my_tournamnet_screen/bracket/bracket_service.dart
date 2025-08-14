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
    // Collect all teams
    List<String> teams = [];
    for (var match in matches) {
      if (match['team1'] != null && match['team1'] != 'BYE')
        teams.add(match['team1']);
      if (match['team2'] != null && match['team2'] != 'BYE')
        teams.add(match['team2']);
    }
    teams.shuffle();
    // Reassign shuffled teams to matches
    int t = 0;
    for (var match in matches) {
      match['team1'] = t < teams.length ? teams[t++] : null;
      match['team2'] = t < teams.length ? teams[t++] : null;
      match['winner'] = null;
      match['status'] = 'ready';
    }
  }

  // Get all brackets for a tournament
  Future<List<Map<String, dynamic>>> getAllBrackets(int tournamentId) async {
    try {
      // For now, return empty list since API doesn't exist yet
      // TODO: Implement actual API call when backend is ready
      print(
          "No brackets found for tournament: $tournamentId (API not implemented yet)");
      return [];

      // Uncomment when API is ready:
      /*
      final token = await TokenManager.getToken();
      if (token == null) throw Exception('Token is null');

      dio.options.headers['Authorization'] = 'Bearer $token';
      final response =
          await dio.get('$baseUrl/tournament/bracket/all/$tournamentId');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        print(
            "Successfully fetched all brackets for tournament: $tournamentId");
        return List<Map<String, dynamic>>.from(data);
      } else {
        print("No brackets found for tournament: $tournamentId");
        return [];
      }
      */
    } catch (e) {
      print("Error fetching all brackets: $e");
      return [];
    }
  }

  // Delete bracket
  Future<bool> deleteBracket(int bracketId) async {
    try {
      // For now, return true since API doesn't exist yet
      // TODO: Implement actual API call when backend is ready
      print("Successfully deleted bracket locally (API not implemented yet)");
      return true;

      // Uncomment when API is ready:
      /*
      final token = await TokenManager.getToken();
      if (token == null) throw Exception('Token is null');

      dio.options.headers['Authorization'] = 'Bearer $token';
      final response =
          await dio.delete('$baseUrl/tournament/bracket/$bracketId');

      if (response.statusCode == 200) {
        print("Successfully deleted bracket");
        return true;
      } else {
        throw Exception('Failed to delete bracket: ${response.statusCode}');
      }
      */
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

    // Calculate number of rounds needed
    int numTeams = teamNames.length;
    int numRounds =
        (numTeams - 1).bitLength; // Log base 2 of numTeams, rounded up

    // Add byes if needed to make it a power of 2
    int totalSlots = 1 << numRounds; // 2^numRounds
    int byes = totalSlots - numTeams;

    // Create first round matches
    List<String> teamsForBracket = List.from(teamNames);

    // Add byes if needed
    for (int i = 0; i < byes; i++) {
      teamsForBracket.add('BYE');
    }

    // Shuffle teams for random seeding
    teamsForBracket.shuffle();

    // Create first round
    for (int i = 0; i < teamsForBracket.length; i += 2) {
      if (i + 1 < teamsForBracket.length) {
        bracketStructure.add({
          'round': 1,
          'match_id': 'match_1_${(i ~/ 2) + 1}',
          'team1': teamsForBracket[i],
          'team2': teamsForBracket[i + 1],
          'winner': null,
          'status': 'pending',
        });
      }
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
