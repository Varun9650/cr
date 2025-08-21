import 'package:flutter/material.dart';

import '../repository/my_tournament_repo.dart';

class MyTournamentViewModel extends ChangeNotifier {
  final MyTournamentRepository _repository = MyTournamentRepository();

  // State variables
  List<Map<String, dynamic>> _myTournaments = [];
  List<Map<String, dynamic>> _enrolledTournaments = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedTabIndex = 0;

  // Getters
  List<Map<String, dynamic>> get myTournaments => _myTournaments;
  List<Map<String, dynamic>> get enrolledTournaments => _enrolledTournaments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedTabIndex => _selectedTabIndex;

  // Set selected tab index
  void setSelectedTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Fetch my tournaments (created by user)
  Future<void> fetchMyTournaments() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final tournaments = await _repository.getMyTournaments();
      _myTournaments = tournaments;

      debugPrint("Fetched ${tournaments.length} my tournaments");
      for (int i = 0; i < tournaments.length; i++) {
        debugPrint("Tournament $i: ${tournaments[i]}");
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch my tournaments: $e';
      debugPrint("Error fetching my tournaments: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch tournaments by user ID (enrolled tournaments)
  Future<void> fetchEnrolledTournaments() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final tournaments = await _repository.getTournamentsByUserId();

      final uniqueTournaments = <Map<String, dynamic>>[];
      final seenIds =
          <dynamic>{}; // could be int or String depending on your ID type

      for (var t in tournaments) {
        if (!seenIds.contains(t['tournament_id'])) {
          uniqueTournaments.add(t);
          seenIds.add(t['tournament_id']);
        }
      }

      _enrolledTournaments = uniqueTournaments;

      // _enrolledTournaments = tournaments;

      debugPrint("Fetched ${tournaments.length} enrolled tournaments");
      // for (int i = 0; i < tournaments.length; i++) {
      //   debugPrint("Enrolled Tournament $i: ${tournaments[i]}");
      // }
    } catch (e) {
      _errorMessage = 'Failed to fetch enrolled tournaments: $e';
      debugPrint("Error fetching enrolled tournaments: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch all tournaments with pagination
  Future<List<Map<String, dynamic>>> fetchAllTournamentsWithPagination(
      int page, int size) async {
    try {
      final tournaments =
          await _repository.getAllTournamentsWithPagination(page, size);
      return tournaments;
    } catch (e) {
      _errorMessage = 'Failed to fetch tournaments with pagination: $e';
      notifyListeners();
      throw Exception('Failed to fetch tournaments with pagination: $e');
    }
  }

  // Fetch all tournaments
  Future<List<Map<String, dynamic>>> fetchAllTournaments() async {
    try {
      final tournaments = await _repository.getAllTournaments();
      return tournaments;
    } catch (e) {
      _errorMessage = 'Failed to fetch all tournaments: $e';
      notifyListeners();
      throw Exception('Failed to fetch all tournaments: $e');
    }
  }

  // Fetch enrolled tournaments (alternative method)
  Future<List<Map<String, dynamic>>> fetchEnrolledTournamentsList() async {
    try {
      final tournaments = await _repository.getEnrolledTournaments();
      return tournaments;
    } catch (e) {
      _errorMessage = 'Failed to fetch enrolled tournaments: $e';
      notifyListeners();
      throw Exception('Failed to fetch enrolled tournaments: $e');
    }
  }

  // Create tournament
  Future<Map<String, dynamic>> createTournament(
      Map<String, dynamic> tournamentData) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _repository.createTournament(tournamentData);

      // Refresh the tournaments list after creation
      await fetchMyTournaments();

      return response;
    } catch (e) {
      _errorMessage = 'Failed to create tournament: $e';
      notifyListeners();
      throw Exception('Failed to create tournament: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update tournament
  Future<void> updateTournament(
      int tournamentId, Map<String, dynamic> tournamentData) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _repository.updateTournament(tournamentId, tournamentData);

      // Refresh the tournaments list after update
      await fetchMyTournaments();
    } catch (e) {
      _errorMessage = 'Failed to update tournament: $e';
      notifyListeners();
      throw Exception('Failed to update tournament: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete tournament
  Future<void> deleteTournament(int tournamentId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _repository.deleteTournament(tournamentId);

      // Refresh the tournaments list after deletion
      await fetchMyTournaments();
    } catch (e) {
      _errorMessage = 'Failed to delete tournament: $e';
      notifyListeners();
      throw Exception('Failed to delete tournament: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register for tournament
  Future<Map<String, dynamic>> registerForTournament(
      Map<String, dynamic> registrationData) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response =
          await _repository.registerForTournament(registrationData);

      // Refresh the enrolled tournaments list after registration
      await fetchEnrolledTournaments();

      return response;
    } catch (e) {
      _errorMessage = 'Failed to register for tournament: $e';
      notifyListeners();
      throw Exception('Failed to register for tournament: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Initialize data
  Future<void> initializeData() async {
    await Future.wait([
      fetchMyTournaments(),
      fetchEnrolledTournaments(),
    ]);
  }

  // Refresh all data
  Future<void> refreshData() async {
    await initializeData();
  }

  // Get tournament by ID from my tournaments
  Map<String, dynamic>? getMyTournamentById(int id) {
    try {
      return _myTournaments.firstWhere((tournament) => tournament['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Get tournament by ID from enrolled tournaments
  Map<String, dynamic>? getEnrolledTournamentById(int id) {
    try {
      return _enrolledTournaments
          .firstWhere((tournament) => tournament['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Get tournament name safely
  String getTournamentName(Map<String, dynamic> tournament) {
    return tournament['tournament_name']?.toString() ?? 'Unnamed Tournament';
  }

  // Check if tournament exists in my tournaments
  bool isMyTournament(int tournamentId) {
    return _myTournaments.any((tournament) => tournament['id'] == tournamentId);
  }

  // Check if tournament exists in enrolled tournaments
  bool isEnrolledTournament(int tournamentId) {
    return _enrolledTournaments
        .any((tournament) => tournament['id'] == tournamentId);
  }
}
