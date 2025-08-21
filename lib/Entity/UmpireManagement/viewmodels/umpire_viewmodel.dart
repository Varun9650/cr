import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/umpire_model.dart';
import '../repositories/umpire_repository.dart';

class UmpireViewModel extends ChangeNotifier {
  final UmpireRepository _umpireRepository = UmpireRepository();

  List<Umpire> _umpires = [];
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _tournaments = [];
  bool _isLoading = false;
  // String _error = '';

  String _listError = '';
  String _addError = '';
  String _updateError = '';
  String get listError => _listError;
  String get addError => _addError;
  String get updateError => _updateError;
  Umpire? _selectedUmpire;

  // Getters
  List<Umpire> get umpires => _umpires;
  List<Map<String, dynamic>> get users => _users;
  List<Map<String, dynamic>> get tournaments => _tournaments;
  bool get isLoading => _isLoading;
  // String get error => _error;
  Umpire? get selectedUmpire => _selectedUmpire;

  // Set selected umpire
  void setSelectedUmpire(Umpire? umpire) {
    _selectedUmpire = umpire;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _listError = '';
    _addError = '';
    _updateError = '';
    // _error = '';
    notifyListeners();
  }

  // Load all umpires
  Future<void> loadUmpires() async {
    _isLoading = true;
    // _error = '';
    _listError = '';
    notifyListeners();

    try {
      _umpires = await _umpireRepository.getAllUmpires();
      print('Umpires loaded: $_umpires');
    } catch (e) {
      _listError = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load users for dropdown
  Future<void> loadUsers() async {
    try {
      _users = await _umpireRepository.getAllUsers();
      notifyListeners();
    } catch (e) {
      _addError = e.toString();
      notifyListeners();
    }
  }

  // Load tournaments for dropdown
  Future<void> loadTournaments() async {
    try {
      _tournaments = await _umpireRepository.getAllTournaments();
      // print('Tournaments loaded: $_tournaments');
      notifyListeners();
    } catch (e) {
      _addError = e.toString();
      notifyListeners();
    }
  }

  // Add new umpire
  Future<bool> addUmpire(int userId, String userTag, int tournamentId) async {
    _isLoading = true;
    _addError = '';
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    String? preferredSport = prefs.getString('preferred_sport') ?? 'Unknown';

    try {
      final newUmpire = Umpire(
        userId: userId,
        userTag: userTag,
        tournamentId: tournamentId,
        preferredSport: preferredSport,
      );

      final addedUmpire = await _umpireRepository.addUmpire(newUmpire);
      _umpires.add(addedUmpire);
      return true;
    } catch (e) {
      _addError = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update umpire
  Future<bool> updateUmpire(
      int id, int userId, String userTag, int tournamentId) async {
    _isLoading = true;
    _updateError = '';
    notifyListeners();

    try {
      final updatedUmpire = Umpire(
        id: id,
        userId: userId,
        userTag: userTag,
        tournamentId: tournamentId,
      );

      final result = await _umpireRepository.updateUmpire(updatedUmpire);

      // Update the umpire in the list
      final index = _umpires.indexWhere((umpire) => umpire.id == id);
      if (index != -1) {
        _umpires[index] = result;
      }

      return true;
    } catch (e) {
      _updateError = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete umpire
  Future<bool> deleteUmpire(int id) async {
    _isLoading = true;
    _listError = '';
    notifyListeners();

    try {
      final success = await _umpireRepository.deleteUmpire(id);
      print('Umpire deleted: $success');
      if (success) {
        _umpires.removeWhere((umpire) => umpire.id == id);
      }
      return success;
    } catch (e) {
      _listError = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get user name by ID
  String getUserNameById(int userId) {
    final user = _users.firstWhere(
      (user) => user['id'] == userId,
      orElse: () => {'id': 0, 'name': 'Unknown User', 'email': ''},
    );
    return user['name'] ?? 'Unknown User';
  }

  // Get tournament name by ID
  String getTournamentNameById(int tournamentId) {
    final tournament = _tournaments.firstWhere(
      (tournament) => tournament['id'] == tournamentId,
      orElse: () => {
        'id': 0,
        'name': 'Unknown Tournament',
        'description': '',
        'status': ''
      },
    );
    return tournament['name'] ?? 'Unknown Tournament';
  }

  // Initialize data
  Future<void> initializeData() async {
    await Future.wait([
      loadUmpires(),
      loadUsers(),
      loadTournaments(),
    ]);
  }
}
