import 'package:cricyard/resources/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/network/network_api_service.dart';
import '../models/umpire_model.dart';

class UmpireRepository {
  final NetworkApiService _networkApiService = NetworkApiService();
  static const String _baseUrl =
      '${ApiConstants.baseUrl}/Umpireselection/Umpireselection';

  // Get all umpires
  Future<List<Umpire>> getAllUmpires() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? preferredSport = prefs.getString('preferred_sport') ?? 'Unknown';

      final response = await _networkApiService
          .getGetApiResponse('$_baseUrl?preferredSport=$preferredSport');

      if (response != null) {
        final List<dynamic> data = response;
        return data.map((json) => Umpire.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to load umpires: $e');
    }
  }

  // Add new umpire
  Future<Umpire> addUmpire(Umpire umpire) async {
    try {
      final response = await _networkApiService.getPostApiResponse(
        _baseUrl,
        umpire.toJson(),
      );

      if (response != null) {
        return Umpire.fromJson(response);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // Update umpire
  Future<Umpire> updateUmpire(Umpire umpire) async {
    try {
      final response = await _networkApiService.getPutApiResponse(
        '$_baseUrl/${umpire.id}',
        umpire.toJson(),
      );

      if (response != null) {
        return Umpire.fromJson(response);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw Exception('Failed to update umpire: $e');
    }
  }

  // Delete umpire
  Future<bool> deleteUmpire(int id) async {
    try {
      final response =
          await _networkApiService.getDeleteApiResponse('$_baseUrl/$id');
      print('Response: $response');
      if (response['msg'] == 'Deleted') {
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to delete umpire: $e');
    }
  }

  // Get all users for dropdown
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _networkApiService
          .getGetApiResponse(ApiConstants.getUsersForRoleMgmt);
      if (response != null) {
        final users = (response as List).cast<Map<String, dynamic>>();
        return users;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  // Get all tournaments for dropdown
  Future<List<Map<String, dynamic>>> getAllTournaments() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final preferredSport = prefs.getString('preferred_sport');
      final response = await _networkApiService.getGetApiResponse(
          '${ApiConstants.getMyTournament}?preferred_sport=$preferredSport');

      if (response != null) {
        final List<dynamic> data = response;
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to load tournaments: $e');
    }
  }

  // Get umpires by tournament ID
  Future<List<Umpire>> getUmpiresByTournamentId(int tournamentId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final preferredSport = prefs.getString('preferred_sport');
      final response = await _networkApiService.getGetApiResponse(
          '$_baseUrl/tournament?tournament_id=$tournamentId&&preferredSport=$preferredSport');

      if (response != null) {
        final List<dynamic> data = response;
        return data.map((json) => Umpire.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to load umpires for tournament: $e');
    }
  }
}
