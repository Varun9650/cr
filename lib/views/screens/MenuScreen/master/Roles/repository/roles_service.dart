import 'package:cricyard/data/network/network_api_service.dart';
import 'package:cricyard/resources/api_constants.dart';

class RolesService {
  final NetworkApiService _net = NetworkApiService();

  Future<List<Map<String, dynamic>>> fetchRoles() async {
    final res = await _net.getGetApiResponse(ApiConstants.getEntitiesRole);
    return (res as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createRole(Map<String, dynamic> role) async {
    return await _net.getPostApiResponse(ApiConstants.createEntityRole, role);
  }

  Future<Map<String, dynamic>> updateRole(
      int id, Map<String, dynamic> role) async {
    return await _net.getPutApiResponse(
        '${ApiConstants.updateEntityRole}/$id', role);
  }

  Future<void> deleteRole(int id) async {
    await _net.getDeleteApiResponse('${ApiConstants.deleteEntityRole}/$id');
  }

  Future<List<Map<String, dynamic>>> fetchMenus() async {
    final res = await _net.getGetApiResponse(ApiConstants.getMenusForRoles);
    return (res as List)
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
  }
}
