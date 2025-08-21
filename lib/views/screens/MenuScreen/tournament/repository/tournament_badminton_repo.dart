import 'package:cricyard/data/network/network_api_service.dart';
import 'package:cricyard/resources/api_constants.dart';
import '../model/tournament_badminton_model.dart';

class TournamentBadmintonRepository {
  final NetworkApiService _networkApiService = NetworkApiService();

  // Get latest badminton match record by match ID
  Future<TournamentBadmintonModel?> getLatestBadmintonRecord(
      int matchId) async {
    try {
      final response = await _networkApiService.getGetApiResponse(
          '${ApiConstants.baseUrl}/api/matches/games/latest/$matchId');
      if (response != null) {
        return TournamentBadmintonModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Failed to get latest badminton record: $e');
      return null;
    }
  }

  // Update score for badminton match
  Future<Map<String, dynamic>> updateBadmintonScore(
      int matchId, Map<String, dynamic> scoreData) async {
    try {
      final response = await _networkApiService.getPostApiResponse(
          '${ApiConstants.baseUrl}/api/matches/point/$matchId', scoreData);
      return response;
    } catch (e) {
      throw Exception('Failed to update badminton score: $e');
    }
  }

  // Create new badminton match
  Future<Map<String, dynamic>> createBadmintonMatch(
      Map<String, dynamic> matchData) async {
    try {
      final response = await _networkApiService.getPostApiResponse(
          '${ApiConstants.baseUrl}/api/matches/create', matchData);
      return response;
    } catch (e) {
      throw Exception('Failed to create badminton match: $e');
    }
  }

  // Get all badminton matches for a tournament
  Future<List<TournamentBadmintonModel>> getTournamentBadmintonMatches(
      int tournamentId) async {
    try {
      final response = await _networkApiService.getGetApiResponse(
          '${ApiConstants.baseUrl}/api/matches/tournament/$tournamentId?sport=badminton');

      final matches = (response as List).cast<Map<String, dynamic>>();
      return matches
          .map((match) => TournamentBadmintonModel.fromJson(match))
          .toList();
    } catch (e) {
      throw Exception('Failed to get tournament badminton matches: $e');
    }
  }

  // Get match details by match ID
  Future<TournamentBadmintonModel?> getMatchDetails(int matchId) async {
    try {
      final response = await _networkApiService
          .getGetApiResponse('${ApiConstants.baseUrl}/api/matches/$matchId');

      if (response != null) {
        return TournamentBadmintonModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Failed to get match details: $e');
      return null;
    }
  }

  // Update match status
  Future<Map<String, dynamic>> updateMatchStatus(
      int matchId, Map<String, dynamic> statusData) async {
    try {
      final response = await _networkApiService.getPutApiResponse(
          '${ApiConstants.baseUrl}/api/matches/$matchId/status', statusData);
      return response;
    } catch (e) {
      throw Exception('Failed to update match status: $e');
    }
  }

  // Get player career stats for badminton
  Future<Map<String, dynamic>> getPlayerCareerStats(
      int matchId, int inning, String playerName) async {
    try {
      final response = await _networkApiService.getGetApiResponse(
          '${ApiConstants.baseUrl}/token/practice/playercareer/career/$matchId/$inning?playerName=$playerName&preferredSport=badminton');
      return response;
    } catch (e) {
      print('Failed to get player career stats: $e');
      return {'message': 'Failed to get player career stats: $e'};
    }
  }

  // Get all balls/actions of a match
  Future<List<dynamic>> getAllMatchActions(int matchId) async {
    try {
      final response = await _networkApiService.getGetApiResponse(
          '${ApiConstants.baseUrl}/token/Practice/score/ballstatus/$matchId?preferredSport=badminton');

      if (response is List) {
        return response;
      }
      return [];
    } catch (e) {
      print('Failed to get match actions: $e');
      return [];
    }
  }

  // Save match history
  Future<Map<String, dynamic>> saveMatchHistory(
      int matchId, List<ScoreAction> history) async {
    try {
      final historyData = history.map((action) => action.toJson()).toList();
      final response = await _networkApiService.getPostApiResponse(
          '${ApiConstants.baseUrl}/api/matches/$matchId/history',
          {'history': historyData});
      return response;
    } catch (e) {
      throw Exception('Failed to save match history: $e');
    }
  }

  // Get match statistics
  Future<Map<String, dynamic>> getMatchStatistics(int matchId) async {
    try {
      final response = await _networkApiService.getGetApiResponse(
          '${ApiConstants.baseUrl}/api/matches/$matchId/statistics');
      return response;
    } catch (e) {
      print('Failed to get match statistics: $e');
      return {};
    }
  }

  // End match
  Future<Map<String, dynamic>> endMatch(
      int matchId, Map<String, dynamic> endData) async {
    try {
      final response = await _networkApiService.getPutApiResponse(
          '${ApiConstants.baseUrl}/api/matches/$matchId/end', endData);
      return response;
    } catch (e) {
      throw Exception('Failed to end match: $e');
    }
  }

  // Pause match
  Future<Map<String, dynamic>> pauseMatch(int matchId) async {
    try {
      final response = await _networkApiService.getPutApiResponse(
          '${ApiConstants.baseUrl}/api/matches/$matchId/pause', {});
      return response;
    } catch (e) {
      throw Exception('Failed to pause match: $e');
    }
  }

  // Resume match
  Future<Map<String, dynamic>> resumeMatch(int matchId) async {
    try {
      final response = await _networkApiService.getPutApiResponse(
          '${ApiConstants.baseUrl}/api/matches/$matchId/resume', {});
      return response;
    } catch (e) {
      throw Exception('Failed to resume match: $e');
    }
  }
}
