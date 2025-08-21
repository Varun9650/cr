import 'package:flutter/material.dart';
import '../models/court_model.dart';
import '../repositories/court_repository.dart';

class CourtViewModel extends ChangeNotifier {
  final CourtRepository _courtRepository = CourtRepository();
  List<Court> _courts = [];
  bool _isLoading = false;
  String _error = '';
  Court? _selectedCourt;

  // Getters
  List<Court> get courts => _courts;
  bool get isLoading => _isLoading;
  String get error => _error;
  Court? get selectedCourt => _selectedCourt;

  // Set selected court
  void setSelectedCourt(Court? court) {
    _selectedCourt = court;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Load all courts
  Future<void> loadCourts() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _courts = await _courtRepository.getAllCourts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new court
  Future<bool> addCourt(String courtName, String description, bool active,
      {int? tournamentId, int? umpireId, String? category}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final newCourt = Court(
        courtName: courtName,
        description: description,
        active: active,
        tournamentId: tournamentId,
        umpireId: umpireId,
        category: category,
      );

      final addedCourt = await _courtRepository.addCourt(newCourt);
      _courts.add(addedCourt);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update court
  Future<bool> updateCourt(
      int id, String courtName, String description, bool active,
      {int? tournamentId, int? umpireId, String? category}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final updatedCourt = Court(
        id: id,
        courtName: courtName,
        description: description,
        active: active,
        tournamentId: tournamentId,
        umpireId: umpireId,
        category: category,
      );

      final result = await _courtRepository.updateCourt(updatedCourt);

      // Update the court in the list
      final index = _courts.indexWhere((court) => court.id == id);
      if (index != -1) {
        _courts[index] = result;
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete court
  Future<bool> deleteCourt(int id) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final success = await _courtRepository.deleteCourt(id);
      if (success) {
        _courts.removeWhere((court) => court.id == id);
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle court active status
  Future<bool> toggleCourtStatus(int id) async {
    final court = _courts.firstWhere((court) => court.id == id);
    return await updateCourt(
      id,
      court.courtName,
      court.description,
      !court.active,
      tournamentId: court.tournamentId,
      umpireId: court.umpireId,
      category: court.category,
    );
  }
}
