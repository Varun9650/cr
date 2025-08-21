import 'package:cricyard/data/network/network_api_service.dart';
import 'package:cricyard/resources/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

class MyTournamentRepository {
  final NetworkApiService _networkApiService = NetworkApiService();

  // Get all entities
  Future<List<Map<String, dynamic>>> getEntities() async {
    try {
      final response = await _networkApiService.getGetApiResponse(
        ApiConstants.getEntitiesMyTournament,
      );
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to get all entities: $e');
    }
  }

  // Get all entities with pagination
  Future<List<Map<String, dynamic>>> getAllWithPagination(
      int page, int size) async {
    try {
      final response = await _networkApiService.getGetApiResponse(
        '${ApiConstants.getAllWithPaginationMyTournament}?page=$page&size=$size',
      );
      return (response['content'] as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to get entities with pagination: $e');
    }
  }

  // Create entity
  Future<Map<String, dynamic>> createEntity(Map<String, dynamic> entity) async {
    try {
      final response = await _networkApiService.getPostApiResponse(
        ApiConstants.createEntityMyTournament,
        entity,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to create entity: $e');
    }
  }

  // Upload logo image
  Future<void> uploadLogoImage(String ref, String refTableName,
      String selectedFilePath, Uint8List imageBytes) async {
    try {
      String apiUrl = "${ApiConstants.uploadLogoImage}/$ref/$refTableName";

      final mimeType = _lookupMimeType(selectedFilePath);
      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          imageBytes,
          filename: selectedFilePath.split('/').last,
          contentType: MediaType.parse(mimeType),
        ),
      });

      await _networkApiService.getPostApiResponse(apiUrl, formData);
    } catch (error) {
      throw Exception('Error occurred during file upload: $error');
    }
  }

  // Update entity
  Future<void> updateEntity(int entityId, Map<String, dynamic> entity) async {
    try {
      final url = ApiConstants.updateEntityMyTournament
          .replaceFirst('{entityId}', entityId.toString());
      await _networkApiService.getPutApiResponse(url, entity);
    } catch (e) {
      throw Exception('Failed to update entity: $e');
    }
  }

  // Delete entity
  Future<void> deleteEntity(int entityId) async {
    try {
      final url = ApiConstants.deleteEntityMyTournament
          .replaceFirst('{entityId}', entityId.toString());
      await _networkApiService.getDeleteApiResponse(url);
    } catch (e) {
      throw Exception('Failed to delete entity: $e');
    }
  }

  // Get tournament names
  Future<List<Map<String, dynamic>>> getTournamentName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? preferredSport = prefs.getString('preferred_sport') ?? 'Unknown';

      final response = await _networkApiService.getGetApiResponse(
        '${ApiConstants.getTournamentName}?preferredSport=$preferredSport',
      );
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to get tournament names: $e');
    }
  }

  // Helper method for MIME type lookup
  String _lookupMimeType(String filePath) {
    final ext = filePath.split('.').last;
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}
