import 'package:cricyard/data/network/network_api_service.dart';
import 'package:cricyard/data/network/base_network_service.dart';
import '/resources/api_constants.dart';

class PickupManagementApiService {
  final String baseUrl = ApiConstants.baseUrl;
  BaseNetworkService networkService = NetworkApiService();

  Future<List<Map<String, dynamic>>> getEntities() async {
    try {
      final response = await networkService
          .getGetApiResponse(ApiConstants.getEntitiesPickupManagement);
      final entities = (response as List).cast<Map<String, dynamic>>();
      return entities;
    } catch (e) {
      throw Exception('Failed to get all entities: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllWithPagination(
      int page, int size) async {
    try {
      final response = await networkService.getGetApiResponse(
          '${ApiConstants.getAllWithPaginationPickupManagement}?page=$page&size=$size');
      final entities =
          (response['content'] as List).cast<Map<String, dynamic>>();
      return entities;
    } catch (e) {
      throw Exception('Failed to get all with pagination: $e');
    }
  }

  Future<Map<String, dynamic>> createEntity(Map<String, dynamic> entity) async {
    try {
      final response = await networkService.getPostApiResponse(
          ApiConstants.createEntityPickupManagement, entity);
      return response;
    } catch (e) {
      throw Exception('Failed to create entity: $e');
    }
  }

  Future<void> updateEntity(int entityId, Map<String, dynamic> entity) async {
    try {
      await networkService.getPutApiResponse(
          ApiConstants.updateEntityPickupManagement
              .replaceFirst('{entityId}', entityId.toString()),
          entity);
    } catch (e) {
      throw Exception('Failed to update entity: $e');
    }
  }

  Future<void> deleteEntity(int entityId) async {
    try {
      await networkService.getDeleteApiResponse(ApiConstants
          .deleteEntityPickupManagement
          .replaceFirst('{entityId}', entityId.toString()));
    } catch (e) {
      throw Exception('Failed to delete entity: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await networkService
          .getGetApiResponse(ApiConstants.getUsersForPickup);
      final users = (response as List).cast<Map<String, dynamic>>();
      return users;
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  Future<void> updatePickupStatus(
      int entityId, Map<String, dynamic> statusData) async {
    try {
      await networkService.getPutApiResponse(
          ApiConstants.updatePickupStatus
              .replaceFirst('{entityId}', entityId.toString()),
          statusData);
    } catch (e) {
      throw Exception('Failed to update pickup status: $e');
    }
  }

  Future<Map<String, dynamic>> getEntityById(int entityId) async {
    try {
      final response = await networkService.getGetApiResponse(
          '${ApiConstants.getEntitiesPickupManagement}/$entityId');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get entity by ID: $e');
    }
  }

  // Upload document API
  Future<Map<String, dynamic>> uploadDocument(
      String ref, String tableName, dynamic file) async {
    try {
      final response = await networkService.uploadFile(
        ApiConstants.uploadDocument
            .replaceFirst('{ref}', ref)
            .replaceFirst('{table_name}', tableName),
        file,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  // Get documents by ref and table name
  Future<List<Map<String, dynamic>>> getDocumentsByRef(
      String ref, String tableName) async {
    try {
      final response = await networkService.getGetApiResponse(
        ApiConstants.getDocumentsByRef
            .replaceFirst('{ref}', ref)
            .replaceFirst('{ref_tablename}', tableName),
      );

      if (response is List) {
        return response.map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          } else if (item is Map) {
            return Map<String, dynamic>.from(item);
          } else {
            throw Exception(
                'Invalid document format: expected Map, got ${item.runtimeType}');
          }
        }).toList();
      } else {
        throw Exception(
            'Invalid response format: expected List, got ${response.runtimeType}');
      }
    } catch (e) {
      throw Exception('Failed to get documents: $e');
    }
  }
}
