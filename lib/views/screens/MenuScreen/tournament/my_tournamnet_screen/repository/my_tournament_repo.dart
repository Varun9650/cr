import 'package:cricyard/data/network/network_api_service.dart';
import 'package:cricyard/resources/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyTournamentRepository {
  final NetworkApiService _networkApiService = NetworkApiService();

  // Get my tournaments (created by user)
  Future<List<Map<String, dynamic>>> getMyTournaments() async {
    try {
      // Get preferred sport from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? preferredSport = prefs.getString('preferred_sport') ?? 'Unknown';
      final response = await _networkApiService.getGetApiResponse(
          "${ApiConstants.getMyTournament}?preferred_sport=$preferredSport");
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch my tournaments: $e');
    }
  }

  // Get tournaments by user ID (enrolled tournaments)
  Future<List<Map<String, dynamic>>> getTournamentsByUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? preferredSport = prefs.getString('preferred_sport') ?? 'Unknown';

      final response = await _networkApiService.getGetApiResponse(
          '${ApiConstants.getAllByUserId}?preferredSport=$preferredSport');
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch tournaments by user ID: $e');
    }
  }

  // Get all tournaments with pagination
  Future<List<Map<String, dynamic>>> getAllTournamentsWithPagination(
      int page, int size) async {
    try {
      final response = await _networkApiService.getGetApiResponse(
          '${ApiConstants.getAllWithPaginationMyTournament}?page=$page&size=$size');
      return (response['content'] as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch tournaments with pagination: $e');
    }
  }

  // Get all tournaments
  Future<List<Map<String, dynamic>>> getAllTournaments() async {
    try {
      final response = await _networkApiService
          .getGetApiResponse(ApiConstants.getEntitiesMyTournament);
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch all tournaments: $e');
    }
  }

  // Get enrolled tournaments
  Future<List<Map<String, dynamic>>> getEnrolledTournaments() async {
    try {
      final response = await _networkApiService
          .getGetApiResponse(ApiConstants.getEnrolledTournament);
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch enrolled tournaments: $e');
    }
  }

  // Create tournament
  Future<Map<String, dynamic>> createTournament(
      Map<String, dynamic> tournamentData) async {
    try {
      final response = await _networkApiService.getPostApiResponse(
          ApiConstants.createEntityMyTournament, tournamentData);
      return response;
    } catch (e) {
      throw Exception('Failed to create tournament: $e');
    }
  }

  // Update tournament
  Future<void> updateTournament(
      int tournamentId, Map<String, dynamic> tournamentData) async {
    try {
      final url = ApiConstants.updateEntityMyTournament
          .replaceFirst('{entityId}', tournamentId.toString());
      await _networkApiService.getPutApiResponse(url, tournamentData);
    } catch (e) {
      throw Exception('Failed to update tournament: $e');
    }
  }

  // Delete tournament
  Future<void> deleteTournament(int tournamentId) async {
    try {
      final url = ApiConstants.deleteEntityMyTournament
          .replaceFirst('{entityId}', tournamentId.toString());
      await _networkApiService.getDeleteApiResponse(url);
    } catch (e) {
      throw Exception('Failed to delete tournament: $e');
    }
  }

  // Register for tournament
  Future<Map<String, dynamic>> registerForTournament(
      Map<String, dynamic> registrationData) async {
    try {
      final response = await _networkApiService.getPostApiResponse(
          ApiConstants.registerTournament, registrationData);
      return response;
    } catch (e) {
      throw Exception('Failed to register for tournament: $e');
    }
  }
}
