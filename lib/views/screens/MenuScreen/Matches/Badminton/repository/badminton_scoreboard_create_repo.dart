import 'package:cricyard/data/network/network_api_service.dart';
import 'package:cricyard/resources/api_constants.dart';

class BadmintonScoreboardCreateRepository {
  final NetworkApiService _networkApiService = NetworkApiService();

  /// Get team members by team ID using the Register_team API
  Future<List<Map<String, dynamic>>> getTeamMembers(String teamId) async {
    try {
      final response = await _networkApiService.getGetApiResponse(
        ApiConstants.getAllMembers.replaceFirst('{teamId}', teamId),
      );

      if (response is List) {
        return response.map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          } else if (item is Map) {
            return Map<String, dynamic>.from(item);
          } else {
            throw Exception(
                'Invalid team member format: expected Map, got ${item.runtimeType}');
          }
        }).toList();
      } else {
        throw Exception(
            'Invalid response format: expected List, got ${response.runtimeType}');
      }
    } catch (e) {
      print('Error fetching team members: $e');
      return [];
    }
  }

  /// Create badminton scoreboard with player data
  Future<Map<String, dynamic>> createBadmintonScoreboard(
    int matchId,
    int tourId,
    String matchType,
    Map<String, dynamic> playerData,
  ) async {
    try {
      final requestData = {
        'match_id': matchId,
        'tournament_id': tourId,
        'matchType': matchType,
        ...playerData,
      };

      print('=== REPOSITORY DEBUG ===');
      print('Request Data: $requestData');
      print('Player Data: $playerData');
      print('Match Type: $matchType');
      print('========================');

      // Using the scoreboard creation endpoint
      final response = await _networkApiService.getPostApiResponse(
        '${ApiConstants.baseUrl}/api/matches/games/create',
        requestData,
      );

      if (response is Map<String, dynamic>) {
        return {'success': true, 'message': 'Scoreboard created successfully'};
        // return response;
      } else {
        return {'success': true, 'message': 'Scoreboard created successfully'};
      }
    } catch (e) {
      print('Error creating badminton scoreboard: $e');
      return {'success': false, 'message': 'Failed to create scoreboard: $e'};
    }
  }
}
