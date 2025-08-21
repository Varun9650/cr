import 'package:cricyard/resources/api_constants.dart';

import '../../../data/network/network_api_service.dart';
import '../models/court_model.dart';

class CourtRepository {
  final NetworkApiService _networkApiService = NetworkApiService();
  static const String _baseUrl =
      '${ApiConstants.baseUrl}/Badminton_court/Badminton_court';

  // Get all courts
  Future<List<Court>> getAllCourts() async {
    try {
      final response = await _networkApiService.getGetApiResponse(_baseUrl);

      if (response != null) {
        final List<dynamic> data = response;
        return data.map((json) => Court.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to load courts: $e');
    }
  }

  // Add new court
  Future<Court> addCourt(Court court) async {
    try {
      final response = await _networkApiService.getPostApiResponse(
        _baseUrl,
        court.toJson(),
      );

      if (response != null) {
        print("response  ${response.toString()}");
        return Court.fromJson(response);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw Exception('Failed to add court: $e');
    }
  }

  // Update court
  Future<Court> updateCourt(Court court) async {
    try {
      final response = await _networkApiService.getPutApiResponse(
        '$_baseUrl/${court.id}',
        court.toJson(),
      );

      if (response != null) {
        return Court.fromJson(response);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw Exception('Failed to update court: $e');
    }
  }

  // Delete court
  Future<bool> deleteCourt(int id) async {
    try {
      await _networkApiService.getDeleteApiResponse('$_baseUrl/$id');
      return true;
    } catch (e) {
      throw Exception('Failed to delete court: $e');
    }
  }
}
