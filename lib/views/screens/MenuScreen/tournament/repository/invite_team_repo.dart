import 'package:cricyard/data/network/network_api_service.dart';
import 'package:cricyard/resources/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/invite_team_model.dart';

class InviteTeamRepository {
  final NetworkApiService _networkApiService = NetworkApiService();

  // Get all teams (converted from getEntitiess)
  Future<List<InviteTeamModel>> getAllTeams() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? preferredSport = prefs.getString('preferred_sport') ?? 'Unknown';
      final response = await _networkApiService.getGetApiResponse(
          "${ApiConstants.getEntitiesTeams}?preferredSport=$preferredSport");
      print('response is $response');
      final teams = (response as List).cast<Map<String, dynamic>>();
      return teams.map((team) => InviteTeamModel.fromJson(team)).toList();
    } catch (e) {
      throw Exception('Failed to fetch teams: $e');
    }
  }

  // Get teams with pagination
  Future<List<InviteTeamModel>> getTeamsWithPagination(
      int page, int size) async {
    try {
      final response = await _networkApiService.getGetApiResponse(
          '${ApiConstants.getAllWithPaginationTeams}?page=$page&size=$size');

      final teams = (response['content'] as List).cast<Map<String, dynamic>>();
      return teams.map((team) => InviteTeamModel.fromJson(team)).toList();
    } catch (e) {
      throw Exception('Failed to fetch teams with pagination: $e');
    }
  }

  // Get my teams
  Future<List<InviteTeamModel>> getMyTeams() async {
    try {
      final response =
          await _networkApiService.getGetApiResponse(ApiConstants.getMyTeam);

      final teams = (response as List).cast<Map<String, dynamic>>();
      return teams.map((team) => InviteTeamModel.fromJson(team)).toList();
    } catch (e) {
      throw Exception('Failed to fetch my teams: $e');
    }
  }

  // Get enrolled teams
  Future<List<InviteTeamModel>> getEnrolledTeams() async {
    try {
      final response = await _networkApiService
          .getGetApiResponse(ApiConstants.getEnrolledTeam);

      final teams = (response as List).cast<Map<String, dynamic>>();
      return teams.map((team) => InviteTeamModel.fromJson(team)).toList();
    } catch (e) {
      throw Exception('Failed to fetch enrolled teams: $e');
    }
  }

  // Get teams by tournament ID
  Future<List<InviteTeamModel>> getTeamsByTournamentId(int tourId) async {
    try {
      final url = ApiConstants.getMyTeamByTourId
          .replaceFirst('{tourId}', tourId.toString());
      final response = await _networkApiService.getGetApiResponse(url);

      final teams = (response as List).cast<Map<String, dynamic>>();
      return teams.map((team) => InviteTeamModel.fromJson(team)).toList();
    } catch (e) {
      throw Exception('Failed to fetch teams by tournament ID: $e');
    }
  }

  // Get all team members
  Future<List<Map<String, dynamic>>> getAllTeamMembers(int teamId) async {
    try {
      final url = ApiConstants.getAllMembers
          .replaceFirst('{teamId}', teamId.toString());
      final response = await _networkApiService.getGetApiResponse(url);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch team members: $e');
    }
  }

  // Invite team to tournament (converted from inviteTeam)
  Future<InviteTeamResponse> inviteTeam(int tournamentId, int teamId) async {
    try {
      final url = ApiConstants.inviteTeam
          .replaceFirst('{tournamentId}', tournamentId.toString())
          .replaceFirst('{teamId}', teamId.toString());

      print('url is $url');
      final response = await _networkApiService.getPostApiResponse(url, {});

      // Handle string response from API
      if (response is String) {
        return InviteTeamResponse.fromString(response);
      } else if (response is Map<String, dynamic>) {
        return InviteTeamResponse.fromJson(response);
      } else {
        return InviteTeamResponse(
          message: 'Invitation sent successfully!',
          success: true,
        );
      }
    } catch (e) {
      throw Exception('Failed to invite team: $e');
    }
  }

  // Create team
  Future<Map<String, dynamic>> createTeam(Map<String, dynamic> teamData) async {
    try {
      final response = await _networkApiService.getPostApiResponse(
          ApiConstants.createEntityTeams, teamData);
      return response;
    } catch (e) {
      throw Exception('Failed to create team: $e');
    }
  }

  // Update team
  Future<void> updateTeam(int teamId, Map<String, dynamic> teamData) async {
    try {
      final url = ApiConstants.updateEntityTeams
          .replaceFirst('{entityId}', teamId.toString());
      await _networkApiService.getPutApiResponse(url, teamData);
    } catch (e) {
      throw Exception('Failed to update team: $e');
    }
  }

  // Delete team
  Future<void> deleteTeam(int teamId) async {
    try {
      final url = ApiConstants.deleteEntityTeams
          .replaceFirst('{entityId}', teamId.toString());
      await _networkApiService.getDeleteApiResponse(url);
    } catch (e) {
      throw Exception('Failed to delete team: $e');
    }
  }
}
