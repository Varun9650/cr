import 'package:cricyard/data/network/network_api_service.dart';
import 'package:cricyard/resources/api_constants.dart';

class BadmintonMatchRepository {
  final NetworkApiService _networkApiService = NetworkApiService();

  /// Check if badminton scoreboard exists for a match
  Future<dynamic> checkBadmintonScoreboardExists(int matchId) async {
    try {
      // Using existing match endpoint to check if match has started
      final url = '${ApiConstants.getBadLatestRecord}/$matchId';
      final response = await _networkApiService.getGetApiResponse(url);

      print(
          'BadmintonMatchRepository: Response for match $matchId is $response');
      return response;
    } catch (e) {
      print('Error checking badminton scoreboard: $e');
      return null;
    }
  }

  /// Start a badminton match
  Future<Map<String, dynamic>> startBadmintonMatch(int matchId) async {
    try {
      final response = await _networkApiService.getPostApiResponse(
        ApiConstants.createEntityStartMatch,
        {
          'match_id': matchId,
        },
      );

      return response is Map<String, dynamic> ? response : {'success': true};
    } catch (e) {
      print('Error starting badminton match: $e');
      throw Exception('Failed to start match: $e');
    }
  }

  /// Cancel a badminton match
  Future<bool> cancelBadmintonMatch(int matchId) async {
    try {
      await _networkApiService.getDeleteApiResponse(ApiConstants.cancelMatch);
      return true;
    } catch (e) {
      print('Error canceling badminton match: $e');
      return false;
    }
  }

  /// Get badminton match details
  Future<Map<String, dynamic>> getBadmintonMatchDetails(int matchId) async {
    try {
      final url = '${ApiConstants.getEntitiesMatch}?id=$matchId';
      final response = await _networkApiService.getGetApiResponse(url);

      if (response is List && response.isNotEmpty) {
        return response.first is Map<String, dynamic> ? response.first : {};
      }
      return {};
    } catch (e) {
      print('Error getting badminton match details: $e');
      return {};
    }
  }
}
