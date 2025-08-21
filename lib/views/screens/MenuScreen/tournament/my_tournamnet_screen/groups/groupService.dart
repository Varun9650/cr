import 'package:dio/dio.dart';

import '/resources/api_constants.dart';
import '../../../../../../data/network/base_network_service.dart';
import '../../../../../../data/network/network_api_service.dart';
import '../../../../../../providers/token_manager.dart';

class GroupService {
  final String baseUrl = ApiConstants.baseUrl;
  final Dio dio = Dio();
  BaseNetworkService networkService = NetworkApiService();

//add teams to specific group
  Future<dynamic> addTeamsToGr(int tourId, int teamId, String grName) async {
    print("ADDED TEAM-ID-$teamId, TOURID-$tourId,GR-NAME--$grName");
    try {
      Map<String, dynamic> group = {};
      group['tournament_id'] = tourId;
      group['team_id'] = teamId;
      group['group_name'] = grName;

      final response = await networkService.getPostApiResponse(
          '$baseUrl/tournament/TeamGroup', group);
      return response;
    } catch (e) {
      throw Exception(e);
    }
  }

  // delete team
  Future<void> deleteTeamFormGroup(int teamId) async {
    print("RECEIVED-ID-$teamId");
    try {
      final token = await TokenManager.getToken();
      print('token is $token');
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
        final res = await dio.delete(
          '$baseUrl/tournament/TeamGroup/$teamId',
        );
        if (res.statusCode == 200) {
          print("Successful deleting team ");
        }
      } else {
        throw Exception('Token is null');
      }
    } catch (e) {
      throw Exception('Failed to delete teams in  group: $e');
    }
  }

  // delete group
  Future<void> deleteGroup(int groupId) async {
    print("RECEIVED-ID-$groupId");
    try {
      final token = await TokenManager.getToken();
      print('token is $token');
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
        final res = await dio.delete(
          '$baseUrl/tournament/Group_name/$groupId',
        );
        if (res.statusCode == 200) {
          print("Successful deleting group");
        }
      } else {
        throw Exception('Token is null');
      }
    } catch (e) {
      throw Exception('Failed to delete  group: $e');
    }
  }

// create group
  Future<void> createGroup(int tourId, List<String> groupName) async {
    print("Data received is $tourId , gr names--$groupName");
    try {
      Map<String, dynamic> group = {};
      group['tournament_id'] = tourId;
      group['grouplist'] = groupName;

      print("Group--$group");

      final token = await TokenManager.getToken();
      print('token is $token');
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
        await dio.post('$baseUrl/tournament/Group_name/Add', data: group);
      } else {
        throw Exception('Token is null');
      }
    } catch (e) {
      throw Exception('Failed to send all created group list: $e');
    }
  }

  // create manual group (single group)
  Future<dynamic> createManualGroup(int tourId, String groupName) async {
    print("Manual group create: $tourId, $groupName");
    try {
      Map<String, dynamic> group = {};
      group['tournament_id'] = tourId;
      group['group_name'] = groupName;

      final response = await networkService.getPostApiResponse(
          '$baseUrl/tournament/Group_name', group);
      return response;
    } catch (e) {
      throw Exception('Failed to create manual group: $e');
    }
  }

  // Edit group name
  Future<dynamic> editGroupName(int groupId, String newName) async {
    print("Edit group: $groupId, $newName");
    try {
      Map<String, dynamic> data = {'group_name': newName};

      final response = await networkService.getPutApiResponse(
          '$baseUrl/tournament/Group_name/$groupId', data);

      return response;
    } catch (e) {
      throw Exception('Failed to edit group: $e');
    }
  }

// fetch all groups
  Future<List?> fetchAllGroups(int tournamentId) async {
    final token = await TokenManager.getToken();
    try {
      dio.options.headers['Authorization'] = 'Bearer $token';
      final res =
          await dio.get('$baseUrl/tournament/Group_name/myGroup/$tournamentId');
      List<dynamic> data = res.data;
      if (res.statusCode == 200) {
        print("Successfully get the groups");
        print("Groups--${res.data}");
        return data;
      } else {
        print("error ${res.statusCode}");
      }
    } catch (e) {
      print("Error fetching all groups $e");
    }
    return null;
  }

// get all teams in groups
  Future<List?> fetchAllTeamsByGroups(int tournamentId, String grName) async {
    final token = await TokenManager.getToken();
    try {
      dio.options.headers['Authorization'] = 'Bearer $token';
      final res = await dio.get(
          '$baseUrl/tournament/TeamGroup/group?tourId=$tournamentId&GroupName=$grName');
      List<dynamic> data = res.data;
      if (res.statusCode == 200) {
        print("Successfully get the teams by groups");
        // print("teams byu groups--${res.data}");
        return data;
      } else {
        print("error ${res.statusCode}");
      }
    } catch (e) {
      print("Error fetching all teams by  groups $e");
    }
    return null;
  }
}
