import 'package:cricyard/core/utils/smart_print.dart';
import 'package:cricyard/data/network/network_api_service.dart';
import 'package:cricyard/resources/api_constants.dart';

class ScheduleMatchRepository {
  final NetworkApiService _networkApiService = NetworkApiService();

  // Get teams by tournament ID
  Future<List<Map<String, dynamic>>> getTeamsByTournamentId(
      int tournamentId) async {
    try {
      smartPrint('Fetching teams for tournament ID: $tournamentId');

      final response = await _networkApiService.getGetApiResponse(
        '/teams/getMyTeamByTourId/$tournamentId',
      );

      if (response != null && response is List) {
        smartPrint('Teams fetched successfully: ${response.length} teams');
        return List<Map<String, dynamic>>.from(response);
      } else {
        smartPrint('No teams found or invalid response format');
        return [];
      }
    } catch (e) {
      smartPrint('Error fetching teams: $e');
      throw Exception('Failed to fetch teams: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTeamsByTourAndGrpName(
      int tournamentId, String grpName) async {
    try {
      smartPrint('Fetching teams for tournament ID: $tournamentId');

      final response = await _networkApiService.getGetApiResponse(
        '${ApiConstants.getTeamsByTourAndGrpName}?tourId=$tournamentId&GroupName=$grpName',
      );

      if (response != null && response is List) {
        smartPrint('Teams fetched successfully: ${response.length} teams');
        return List<Map<String, dynamic>>.from(response);
      } else {
        smartPrint('No teams found or invalid response format');
        return [];
      }
    } catch (e) {
      smartPrint('Error fetching teams: $e');
      throw Exception('Failed to fetch teams: $e');
    }
  }

  // Create match entity
  Future<Map<String, dynamic>> createMatchEntity(
      Map<String, dynamic> matchData) async {
    try {
      smartPrint('Creating match with data: $matchData');

      final response = await _networkApiService.getPostApiResponse(
        ApiConstants.getEntitiesMatch,
        matchData,
      );

      if (response != null) {
        smartPrint('Match created successfully');
        return response;
      } else {
        throw Exception('Failed to create match: No response received');
      }
    } catch (e) {
      smartPrint('Error creating match: $e');
      throw Exception('Failed to create match: $e');
    }
  }

  // Get preferred sport from SharedPreferences
  Future<String> getPreferredSport() async {
    try {
      // This would typically come from SharedPreferences
      // For now, returning a default value
      return 'Badminton';
    } catch (e) {
      smartPrint('Error getting preferred sport: $e');
      return 'Badminton'; // Default fallback
    }
  }
}
