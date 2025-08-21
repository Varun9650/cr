import 'package:cricyard/data/network/network_api_service.dart';
import 'package:cricyard/resources/api_constants.dart';

class PointsTableService {
  final NetworkApiService _network = NetworkApiService();

  Future<List<Map<String, dynamic>>> fetchPoints({
    required int tournamentId,
    required String groupName,
  }) async {
    final String url =
        '${ApiConstants.pointTableGet}?tourId=$tournamentId&GroupName=$groupName';
    final response = await _network.getGetApiResponse(url);
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<Map<String, dynamic>?> createPoints({
    required int matchId,
    required int teamId,
    required int tournamentId,
    required int points,
    required String round,
    required String category,
  }) async {
    final body = {
      'match_id': matchId,
      'team_id': teamId,
      'tournament_id': tournamentId,
      'points': points,
      'round': round,
      'category': category,
    };
    final response =
        await _network.getPostApiResponse(ApiConstants.pointTablePost, body);
    return response;
  }

  Future<void> deletePointsByTournamentAndGroup({
    required int tournamentId,
    required String groupName,
  }) async {
    final String url =
        '${ApiConstants.pointTableDelete}?tourId=$tournamentId&GroupName=$groupName';
    await _network.getDeleteApiResponse(url);
  }
}
