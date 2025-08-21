import 'package:cricyard/core/utils/smart_print.dart';
import 'package:cricyard/data/network/network_api_service.dart';
import 'package:cricyard/resources/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../BadmintonCourt/models/court_model.dart';
import '../../../BadmintonCourt/repositories/court_repository.dart';
import '../../../UmpireManagement/models/umpire_model.dart';
import '../../../UmpireManagement/repositories/umpire_repository.dart';
import '../../../add_tournament/My_Tournament/repository/My_Tournament_api_service.dart';
import '../../../team/Teams/repository/Teams_api_service.dart';
import '../repository/Match_api_service.dart';

class MatchProvider with ChangeNotifier {
  final MatchApiService apiService = MatchApiService();
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final CourtRepository _courtRepository = CourtRepository();
  final UmpireRepository _umpireRepository = UmpireRepository();
  // MatchModel match = MatchModel.fromRawJson(response);

  Map<String, dynamic> entity = {};

  void updateField(String key, dynamic value) {
    entity[key] = value;
    notifyListeners();
  }

  Future<void> updateEntity([Map<String, dynamic>? entityData]) async {
    // API call to update entity
    final dataToUpdate = entityData ?? entity;
    print('entity: $dataToUpdate and id: ${dataToUpdate['id']}');
    await apiService.updateEntity(dataToUpdate['id'], dataToUpdate);
  }

  stt.SpeechToText _speech = stt.SpeechToText();

  List<Map<String, dynamic>> _entities = [];
  List<Map<String, dynamic>> _filteredEntities = [];
  List<Map<String, dynamic>> _searchEntities = [];

  bool _showCardView = true;
  bool _isLoading = false;

  int _currentPage = 0;
  int _pageSize = 10;

  List<Map<String, dynamic>> get entities => _filteredEntities;
  bool get isLoading => _isLoading;
  bool get showCardView => _showCardView;

  MatchProvider() {
    scrollController.addListener(_scrollListener);
    fetchEntities();
    fetchWithoutPaging();
  }

  Future<void> fetchWithoutPaging() async {
    try {
      final fetchedEntities = await apiService.getEntities();
      _searchEntities = fetchedEntities;
      notifyListeners();
    } catch (e) {
      throw Exception("Failed to fetch entities: $e");
    }
  }

  Future<void> fetchEntities() async {
    try {
      _isLoading = true;
      notifyListeners();

      final fetchedEntities =
          await apiService.getAllWithPagination(_currentPage, _pageSize);
      _entities.addAll(fetchedEntities);
      _filteredEntities = _entities.toList();
      _currentPage++;
      notifyListeners();
    } catch (e) {
      throw Exception("Failed to fetch entities: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteEntity(Map<String, dynamic> entity) async {
    try {
      await apiService.deleteEntity(entity['id']);
      _entities.remove(entity);
      _filteredEntities = _entities.toList();
      notifyListeners();
    } catch (e) {
      throw Exception("Failed to delete entity: $e");
    }
  }

  void searchEntities(String keyword) {
    _filteredEntities = _searchEntities
        .where((entity) =>
            entity['team_1']
                .toString()
                .toLowerCase()
                .contains(keyword.toLowerCase()) ||
            entity['team_2']
                .toString()
                .toLowerCase()
                .contains(keyword.toLowerCase()) ||
            entity['location']
                .toString()
                .toLowerCase()
                .contains(keyword.toLowerCase()) ||
            entity['date_field']
                .toString()
                .toLowerCase()
                .contains(keyword.toLowerCase()) ||
            entity['datetime_field']
                .toString()
                .toLowerCase()
                .contains(keyword.toLowerCase()) ||
            entity['name']
                .toString()
                .toLowerCase()
                .contains(keyword.toLowerCase()) ||
            entity['description']
                .toString()
                .toLowerCase()
                .contains(keyword.toLowerCase()) ||
            entity['active']
                .toString()
                .toLowerCase()
                .contains(keyword.toLowerCase()) ||
            entity['user_id']
                .toString()
                .toLowerCase()
                .contains(keyword.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void startListening() async {
    if (!_speech.isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {},
        onError: (error) {},
      );

      if (available) {
        _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              searchController.text = result.recognizedWords;
              searchEntities(result.recognizedWords);
            }
          },
        );
      }
    }
  }

  void stopListening() {
    if (_speech.isListening) {
      _speech.stop();
    }
  }

  void toggleViewMode() {
    _showCardView = !_showCardView;
    notifyListeners();
  }

  final teamsApiService teamApiService = teamsApiService();
  final MyTournamentApiService tournamentApiService = MyTournamentApiService();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  DateTime selectedDate = DateTime.now();
  DateTime selectedDateTime = DateTime.now();
  bool isActive = false;

  List<Map<String, dynamic>> tournamentNameItems = [];
  String? selectedTournamentName;

  List<Map<String, dynamic>> teamNameItems = [];

  final Map<String, dynamic> formData = {};

  // Team loading functionality
  List<Map<String, dynamic>> _teams = [];
  String _selectedTeam1Name = '';
  String _selectedTeam2Name = '';
  String _selectedTeam1Id = '';
  String _selectedTeam2Id = '';
  final NetworkApiService _networkApiService = NetworkApiService();
  // Court and Umpire functionality
  List<Court> _courts = [];
  List<Umpire> _umpires = [];
  String _selectedCourtId = '';
  String _selectedCourtName = '';
  String _selectedUmpireId = '';
  String _selectedUmpireName = '';
  // Getters for teams
  List<Map<String, dynamic>> get teams => _teams;
  String get selectedTeam1Name => _selectedTeam1Name;
  String get selectedTeam2Name => _selectedTeam2Name;
  String get selectedTeam1Id => _selectedTeam1Id;
  String get selectedTeam2Id => _selectedTeam2Id;

  // Getters for courts and umpires
  List<Court> get courts => _courts;
  List<Umpire> get umpires => _umpires;
  String get selectedCourtId => _selectedCourtId;
  String get selectedCourtName => _selectedCourtName;
  String get selectedUmpireId => _selectedUmpireId;
  String get selectedUmpireName => _selectedUmpireName;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      notifyListeners();
    }
  }

  Future<void> selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      );

      if (pickedTime != null) {
        selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        notifyListeners();
      }
    }
  }

  Future<void> loadTournamentNameItems() async {
    try {
      // final token = await TokenManager.getToken();
      final selectTdata = await tournamentApiService.getTournamentName();

      if (selectTdata != null && selectTdata.isNotEmpty) {
        tournamentNameItems = selectTdata;
      } else {
        tournamentNameItems = [];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load tournament names: $e');
    }
  }

  Future<void> loadTeamNameItems() async {
    try {
      final selectTdata = await teamApiService.getMyTeam();

      if (selectTdata != null && selectTdata.isNotEmpty) {
        teamNameItems = selectTdata;
      } else {
        teamNameItems = [];
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load teams: $e');
    }
  }

  // Load teams by tournament ID and group name
  Future<void> loadTeamsByTourAndGroup(
      int tournamentId, String groupName) async {
    try {
      smartPrint(
          'Loading teams for tournament ID: $tournamentId, group: $groupName');

      final response = await _networkApiService.getGetApiResponse(
        '${ApiConstants.getTeamsByTourAndGrpName}?tourId=$tournamentId&GroupName=$groupName',
      );

      if (response != null && response is List) {
        _teams = List<Map<String, dynamic>>.from(response);
        smartPrint('Loaded ${_teams.length} teams from group: $groupName');
      } else {
        _teams = [];
        smartPrint('No teams found or invalid response format');
      }
      notifyListeners();
    } catch (e) {
      smartPrint('Error loading teams: $e');
      _teams = [];
      notifyListeners();
    }
  }

  // Set team 1
  void setTeam1(String teamId, String teamName) {
    _selectedTeam1Id = teamId;
    _selectedTeam1Name = teamName;
    smartPrint('Team 1 selected: $teamName');
    notifyListeners();
  }

  // Set team 2
  void setTeam2(String teamId, String teamName) {
    _selectedTeam2Id = teamId;
    _selectedTeam2Name = teamName;
    smartPrint('Team 2 selected: $teamName');
    notifyListeners();
  }

  void toggleIsActive(bool value) {
    isActive = value;
    notifyListeners();
  }

  void updateFormData(String key, dynamic value) {
    formData[key] = value;
    notifyListeners();
  }

  // Load courts
  Future<void> loadCourts() async {
    try {
      _courts = await _courtRepository.getAllCourts();
      print('Loaded ${_courts.length} courts');
    } catch (e) {
      print('Error loading courts: $e');
    }
  }

  // Load umpires by tournament ID
  Future<void> loadUmpiresByTournamentId(int tournamentId) async {
    try {
      _umpires = await _umpireRepository.getUmpiresByTournamentId(tournamentId);
      smartPrint(
          'Loaded ${_umpires.length} umpires for tournament: $tournamentId');
    } catch (e) {
      smartPrint('Error loading umpires: $e');
    }
  }

  // Set court
  void setCourt(String courtId, String courtName) {
    _selectedCourtId = courtId;
    _selectedCourtName = courtName;
    smartPrint('Court selected: $courtName');
    notifyListeners();
  }

  // Set umpire
  void setUmpire(String umpireId, String umpireName) {
    _selectedUmpireId = umpireId;
    _selectedUmpireName = umpireName;
    smartPrint('Umpire selected: $umpireName');
    notifyListeners();
  }

  void _scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      fetchEntities();
    }
  }
}
