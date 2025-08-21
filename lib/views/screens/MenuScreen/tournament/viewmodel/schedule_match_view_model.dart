import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cricyard/core/utils/smart_print.dart';
import '../repository/schedule_match_repository.dart';
import '../model/schedule_match_model.dart';
import '../../../../../Entity/BadmintonCourt/models/court_model.dart';
import '../../../../../Entity/BadmintonCourt/repositories/court_repository.dart';
import '../../../../../Entity/UmpireManagement/models/umpire_model.dart';
import '../../../../../Entity/UmpireManagement/repositories/umpire_repository.dart';

class ScheduleMatchViewModel extends ChangeNotifier {
  final ScheduleMatchRepository _repository = ScheduleMatchRepository();
  final CourtRepository _courtRepository = CourtRepository();
  final UmpireRepository _umpireRepository = UmpireRepository();

  // State variables
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  // Form data
  ScheduleMatchModel? _formData;
  List<Map<String, dynamic>> _teams = [];
  List<Court> _courts = [];
  List<Umpire> _umpires = [];

  // UI state
  String _selectedTeam1Name = '';
  String _selectedTeam2Name = '';
  String _selectedBadmintonMatchType = "Men's Doubles";
  bool _isActive = false;
  bool _isBadmintonSport = false;
  String _preferredSport = '';
  DateTime _selectedDateTime = DateTime.now();
  String _matchCategory = '';
  String _selectedCourtId = '';
  String _selectedCourtName = '';
  String _selectedUmpireId = '';
  String _selectedUmpireName = '';

  // Getters
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<Map<String, dynamic>> get teams => _teams;
  List<Court> get courts => _courts;
  List<Umpire> get umpires => _umpires;
  String get selectedTeam1Name => _selectedTeam1Name;
  String get selectedTeam2Name => _selectedTeam2Name;
  String get selectedBadmintonMatchType => _selectedBadmintonMatchType;
  bool get isActive => _isActive;
  bool get isBadmintonSport => _isBadmintonSport;
  String get preferredSport => _preferredSport;
  DateTime get selectedDateTime => _selectedDateTime;
  String get matchCategory => _matchCategory;
  String get selectedCourtId => _selectedCourtId;
  String get selectedCourtName => _selectedCourtName;
  String get selectedUmpireId => _selectedUmpireId;
  String get selectedUmpireName => _selectedUmpireName;

  // Badminton match types
  final List<String> badmintonMatchTypes = [
    "Men's Doubles",
    "Women's Doubles",
    "Mixed Doubles",
    // "Men's Singles",
    // "Women's Singles",
  ];

  // Initialize data
  Future<void> initializeData(int tournamentId, {String? groupName}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Set match category from group name
      if (groupName != null && groupName.isNotEmpty) {
        _matchCategory = groupName;
        smartPrint('Match category set to: $_matchCategory');
      }

      // Load teams
      await loadTeams(tournamentId, groupName: groupName);

      // Load courts
      await loadCourts();

      // Load umpires by tournament ID
      await loadUmpiresByTournamentId(tournamentId);

      // Check preferred sport
      await checkPreferredSport();

      // Initialize form data
      _formData = ScheduleMatchModel(
        tournamentId: tournamentId,
        match_category: _matchCategory,
      );

      smartPrint('Schedule match data initialized successfully');
    } catch (e) {
      _errorMessage = 'Failed to initialize data: $e';
      smartPrint('Error initializing data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load teams by tournament ID and group name
  Future<void> loadTeams(int tournamentId, {String? groupName}) async {
    try {
      smartPrint(
          'Loading teams for tournament ID: $tournamentId, group: $groupName');

      if (groupName != null && groupName.isNotEmpty) {
        // Load teams by tournament and group
        _teams =
            await _repository.getTeamsByTourAndGrpName(tournamentId, groupName);
        smartPrint('Loaded ${_teams.length} teams from group: $groupName');
      } else {
        // Load all teams by tournament
        _teams = await _repository.getTeamsByTournamentId(tournamentId);
        smartPrint('Loaded ${_teams.length} teams from all groups');
      }

      smartPrint('Teams data: $_teams');

      // Check if teams have the expected structure
      if (_teams.isNotEmpty) {
        smartPrint('First team structure: ${_teams.first.keys}');
        smartPrint('First team data: ${_teams.first}');
      } else {
        smartPrint('No teams found in the response');
      }
    } catch (e) {
      _errorMessage = 'Failed to load teams: $e';
      smartPrint('Error loading teams: $e');
      rethrow;
    }
  }

  // Load courts
  Future<void> loadCourts() async {
    try {
      _courts = await _courtRepository.getAllCourts();
      smartPrint('Loaded ${_courts.length} courts');
    } catch (e) {
      _errorMessage = 'Failed to load courts: $e';
      smartPrint('Error loading courts: $e');
    }
  }

  // Load umpires by tournament ID
  Future<void> loadUmpiresByTournamentId(int tournamentId) async {
    try {
      _umpires = await _umpireRepository.getUmpiresByTournamentId(tournamentId);
      smartPrint(
          'Loaded ${_umpires.length} umpires for tournament: $tournamentId');
    } catch (e) {
      _errorMessage = 'Failed to load umpires: $e';
      smartPrint('Error loading umpires: $e');
    }
  }

  // Check preferred sport
  Future<void> checkPreferredSport() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _preferredSport = prefs.getString('preferred_sport') ?? 'Unknown';
      _isBadmintonSport = _preferredSport == 'Badminton';
      smartPrint(
          'Preferred sport: $_preferredSport, isBadminton: $_isBadmintonSport');
    } catch (e) {
      smartPrint('Error checking preferred sport: $e');
      _preferredSport = 'Badminton';
      _isBadmintonSport = true;
    }
  }

  // Set team 1
  void setTeam1(String teamId, String teamName) {
    _selectedTeam1Name = teamName;
    _formData = _formData?.copyWith(
      team1Id: teamId,
      team1Name: teamName,
    );
    smartPrint('Team 1 selected: $teamName');
    notifyListeners();
  }

  // Set team 2
  void setTeam2(String teamId, String teamName) {
    _selectedTeam2Name = teamName;
    _formData = _formData?.copyWith(
      team2Id: teamId,
      team2Name: teamName,
    );
    smartPrint('Team 2 selected: $teamName');
    notifyListeners();
  }

  // Set date time
  void setDateTime(DateTime dateTime) {
    _selectedDateTime = dateTime;
    _formData = _formData?.copyWith(
      datetimeField: _formatDateTime(dateTime),
    );
    smartPrint('DateTime selected: $dateTime');
    notifyListeners();
  }

  // Set location
  void setLocation(String location) {
    _formData = _formData?.copyWith(location: location);
    smartPrint('Location set: $location');
  }

  // Set description
  void setDescription(String description) {
    _formData = _formData?.copyWith(description: description);
    smartPrint('Description set: $description');
  }

  // Set active status
  void setActive(bool isActive) {
    _isActive = isActive;
    _formData = _formData?.copyWith(isActive: isActive);
    smartPrint('Active status set: $isActive');
    notifyListeners();
  }

  // Set badminton match type
  void setBadmintonMatchType(String matchType) {
    _selectedBadmintonMatchType = matchType;
    _formData = _formData?.copyWith(matchType: _getMatchTypeEnum(matchType));
    smartPrint('Badminton match type set: $matchType');
    notifyListeners();
  }

  // Set court
  void setCourt(String courtId, String courtName) {
    _selectedCourtId = courtId;
    _selectedCourtName = courtName;
    _formData = _formData?.copyWith(
      courtId: courtId,
      courtName: courtName,
    );
    smartPrint('Court selected: $courtName');
    notifyListeners();
  }

  // Set umpire
  void setUmpire(String umpireId, String umpireName) {
    _selectedUmpireId = umpireId;
    _selectedUmpireName = umpireName;
    _formData = _formData?.copyWith(
      umpireId: umpireId,
      umpireName: umpireName,
    );
    smartPrint('Umpire selected: $umpireName');
    notifyListeners();
  }

  // Set match category
  void setMatchCategory(String category) {
    _matchCategory = category;
    _formData = _formData?.copyWith(match_category: category);
    smartPrint('Match category set: $_matchCategory');
    notifyListeners();
  }

  // Validation methods
  String? validateTeam1() {
    if (_selectedTeam1Name.isEmpty) {
      return 'Please select Team 1';
    }
    return null;
  }

  String? validateTeam2() {
    if (_selectedTeam2Name.isEmpty) {
      return 'Please select Team 2';
    }
    if (_selectedTeam1Name == _selectedTeam2Name) {
      return 'Team 1 and Team 2 cannot be the same';
    }
    return null;
  }

  String? validateDateTime() {
    if (_formData?.datetimeField == null || _formData!.datetimeField!.isEmpty) {
      return 'Please select match date and time';
    }
    return null;
  }

  String? validateLocation() {
    if (_formData?.location == null || _formData!.location!.trim().isEmpty) {
      return 'Please enter match location';
    }
    return null;
  }

  String? validateDescription() {
    if (_formData?.description == null ||
        _formData!.description!.trim().isEmpty) {
      return 'Please enter match description';
    }
    return null;
  }

  bool validateForm() {
    bool isValid = true;

    if (validateTeam1() != null) {
      _errorMessage = validateTeam1();
      isValid = false;
    } else if (validateTeam2() != null) {
      _errorMessage = validateTeam2();
      isValid = false;
    } else if (validateDateTime() != null) {
      _errorMessage = validateDateTime();
      isValid = false;
    } else if (validateLocation() != null) {
      _errorMessage = validateLocation();
      isValid = false;
    } else if (validateDescription() != null) {
      _errorMessage = validateDescription();
      isValid = false;
    }

    if (!isValid) {
      notifyListeners();
    }

    return isValid;
  }

  // Create match
  Future<bool> createMatch() async {
    try {
      if (!validateForm()) {
        return false;
      }

      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
      notifyListeners();

      // Prepare final form data

      final finalFormData = _formData?.copyWith(
        preferred_sport: _preferredSport,
        matchType: _getMatchTypeEnum(_selectedBadmintonMatchType),
        match_category: _matchCategory,
      );

      print('Creating match with data: ${finalFormData?.toJson()}');
      print('Match category being sent: $_matchCategory');

      smartPrint('Match category being sent: $_matchCategory');

      final response =
          await _repository.createMatchEntity(finalFormData!.toJson());

      _successMessage = 'Match scheduled successfully!';
      print('Match created successfully');

      smartPrint('Match created successfully');

      return true;
    } catch (e) {
      _errorMessage = 'Failed to create match: $e';
      smartPrint('Error creating match: $e');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Clear messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // Helper methods
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getMatchTypeEnum(String selected) {
    switch (selected) {
      // case "Men's Singles":
      //   return "MENS_SINGLES";
      // case "Women's Singles":
      //   return "WOMENS_SINGLES";
      case "Men's Doubles":
        return "MENS_DOUBLES";
      case "Women's Doubles":
        return "WOMENS_DOUBLES";
      case "Mixed Doubles":
        return "MIXED_DOUBLES";
      default:
        return selected;
    }
  }
}
