import 'package:cricyard/data/network/network_api_service.dart';
import 'package:cricyard/resources/api_constants.dart';

class UserRoleService {
  final NetworkApiService _net = NetworkApiService();

  Future<List<Map<String, dynamic>>> fetchAllRoles() async {
    final res = await _net.getGetApiResponse(ApiConstants.getEntitiesRole);
    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    final res = await _net.getGetApiResponse(ApiConstants.getUsersForRoleMgmt);
    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<List<String>> fetchUserRoles(int userId) async {
    final res =
        await _net.getGetApiResponse('${ApiConstants.getUserRoles}/$userId');
    return (res as List).map((e) => e.toString()).toList();
  }

  Future<void> updateUserRoles(int userId, List<String> roles) async {
    print('Updated roles for user $userId: $roles');

    final body = {
      'user_id': userId,
      'roles': roles,
    };
    await _net.getPostApiResponse(ApiConstants.updateUserRoles, body);
  }
}
