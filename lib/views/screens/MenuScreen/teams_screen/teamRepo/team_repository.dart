import 'package:cricyard/data/network/network_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../teamAppUrls/team_app_url.dart';
import '../teamModel/team_model.dart';
import '../teamModel/player_model.dart';

class TeamRepository {
  final NetworkApiService _networkApiService = NetworkApiService();

  /// Get my teams
  Future<List<TeamModel>> getMyTeams() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? preferredSport = prefs.getString('preferred_sport') ?? 'Cricket';

      final response = await _networkApiService.getGetApiResponse(
        "${TeamAppUrl.getMyTeam}?preferredSport=$preferredSport",
      );

      if (response is List) {
        final entities = response.cast<Map<String, dynamic>>();
        // print('My Teams: $entities');
        return entities.map((json) => TeamModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Invalid response format: expected List, got ${response.runtimeType}');
      }
    } catch (e) {
      throw Exception('Failed to get my teams: $e');
    }
  }

  /// Get enrolled teams
  Future<List<TeamModel>> getEnrolledTeams() async {
    try {
      final response = await _networkApiService.getGetApiResponse(
        TeamAppUrl.getEnrolledTeam,
      );

      if (response is List) {
        final entities = response.cast<Map<String, dynamic>>();
        // print('enrolled : $entities');

        return entities.map((json) => TeamModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Invalid response format: expected List, got ${response.runtimeType}');
      }
    } catch (e) {
      throw Exception('Failed to get enrolled teams: $e');
    }
  }

  /// Get teams by tournament ID
  Future<List<TeamModel>> getTeamsByTournamentId(int tourId) async {
    try {
      final url = TeamAppUrl.getMyTeamByTourId
          .replaceFirst('{tourId}', tourId.toString());
      final response = await _networkApiService.getGetApiResponse(url);

      if (response is List) {
        final entities = response.cast<Map<String, dynamic>>();
        return entities.map((json) => TeamModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Invalid response format: expected List, got ${response.runtimeType}');
      }
    } catch (e) {
      throw Exception('Failed to get teams by tournament ID: $e');
    }
  }

  /// Get all team members
  Future<List<PlayerModel>> getAllMembers(int teamId) async {
    try {
      final url =
          TeamAppUrl.getAllMembers.replaceFirst('{teamId}', teamId.toString());
      final response = await _networkApiService.getGetApiResponse(url);

      if (response is List) {
        final entities = response.cast<Map<String, dynamic>>();
        return entities.map((json) => PlayerModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Invalid response format: expected List, got ${response.runtimeType}');
      }
    } catch (e) {
      throw Exception('Failed to get team members: $e');
    }
  }

  /// Update player tag
  Future<void> updatePlayerTag(
      {required String playerTag, required int playerId}) async {
    try {
      final url = TeamAppUrl.updateTag
          .replaceFirst('{playerTag}', playerTag)
          .replaceFirst('{id}', playerId.toString());

      await _networkApiService.getPutApiResponse(url, {});
    } catch (e) {
      throw Exception('Failed to update player tag: $e');
    }
  }

  /// Get preferred sport
  Future<String> getPreferredSport() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('preferred_sport') ?? 'Badminton';
  }
}
