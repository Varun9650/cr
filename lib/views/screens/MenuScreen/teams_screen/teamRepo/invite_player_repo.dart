import 'package:cricyard/data/network/network_api_service.dart';
import 'package:cricyard/resources/api_constants.dart';
import 'package:dio/dio.dart';

class InvitePlayerRepository {
  final NetworkApiService _networkApiService = NetworkApiService();
  final Dio _dio = Dio();

  // Get all invited players for a team
  Future<List<Map<String, dynamic>>> getAllInvitedPlayers(String teamId) async {
    try {
      final url =
          ApiConstants.getAllInvitedPlayers.replaceFirst('{teamId}', teamId);
      final response = await _networkApiService.getGetApiResponse(url);
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch invited players: $e');
    }
  }

  // Search user by mobile number
  Future<Map<String, dynamic>> searchUserByMobile(String mobileNumber) async {
    try {
      final response = await _dio.get(
          '${ApiConstants.baseUrl}/api/getuser/mobile?mob_num=$mobileNumber');
      print(response.data);

      return Future.delayed(
        const Duration(seconds: 2),
        () => {
          'fullName': response.data['fullName'],
          'found': true, // Add the found field
        },
      );
    } catch (e) {
      print('error is $e');
      throw Exception('Failed To Get User: $e');
    }
  }

  // Send invite to player
  Future<String> sendInvite(String mobileNumber, int teamId) async {
    try {
      final url = ApiConstants.invitePlayer
          .replaceFirst('{mobNo}', mobileNumber)
          .replaceFirst('{teamId}', teamId.toString());
      print('url is $url');
      final response = await _networkApiService.getPostApiResponse(url, {});
      return response;
    } catch (e) {
      throw Exception('Failed to send invite: $e');
    }
  }
}
