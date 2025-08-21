import 'package:flutter/material.dart';
import '../teamModel/team_model.dart';
import '../teamModel/player_model.dart';
import '../teamRepo/team_repository.dart';
import '../utils/sport_categories.dart';

enum TeamStatus { initial, loading, success, error }

class TeamViewModel extends ChangeNotifier {
  final TeamRepository _repository = TeamRepository();

  // State variables
  List<TeamModel> _myTeams = [];
  List<TeamModel> _enrolledTeams = [];
  List<PlayerModel> _teamMembers = [];

  TeamStatus _status = TeamStatus.initial;
  String _errorMessage = '';

  bool _isLoading = false;
  bool _isTeamLoading = false;

  int _selectedTeamIndex = 0;
  int _selectedEnrolledTeamIndex = 0;
  int _currentTabIndex = 0;

  String _preferredSport = 'Cricket';

  // Getters
  List<TeamModel> get myTeams => _myTeams;
  List<TeamModel> get enrolledTeams => _enrolledTeams;
  List<PlayerModel> get teamMembers => _teamMembers;

  TeamStatus get status => _status;
  String get errorMessage => _errorMessage;

  bool get isLoading => _isLoading;
  bool get isTeamLoading => _isTeamLoading;

  int get selectedTeamIndex => _selectedTeamIndex;
  int get selectedEnrolledTeamIndex => _selectedEnrolledTeamIndex;
  int get currentTabIndex => _currentTabIndex;

  String get preferredSport => _preferredSport;

  /// Initialize and fetch initial data
  Future<void> initialize() async {
    await getPreferredSport();
    await fetchMyTeams();
    await fetchEnrolledTeams();

    // After both teams are loaded, fetch team members for the current tab
    _fetchCurrentTeamMembers();
  }

  /// Get preferred sport
  Future<void> getPreferredSport() async {
    _preferredSport = await _repository.getPreferredSport();
    notifyListeners();
  }

  /// Fetch my teams
  Future<void> fetchMyTeams() async {
    try {
      _setStatus(TeamStatus.loading);
      _isTeamLoading = true;
      notifyListeners();

      final teams = await _repository.getMyTeams();
      _myTeams = teams;
      print('My teams: ${_myTeams.length}');

      _setStatus(TeamStatus.success);
    } catch (e) {
      _setStatus(TeamStatus.error);
      _errorMessage = e.toString();
    } finally {
      _isTeamLoading = false;
      notifyListeners();
    }
  }

  /// Fetch enrolled teams
  Future<void> fetchEnrolledTeams() async {
    try {
      _setStatus(TeamStatus.loading);
      _isTeamLoading = true;
      notifyListeners();

      final teams = await _repository.getEnrolledTeams();
      _enrolledTeams = teams;

      _setStatus(TeamStatus.success);
    } catch (e) {
      _setStatus(TeamStatus.error);
      _errorMessage = e.toString();
    } finally {
      _isTeamLoading = false;
      notifyListeners();
    }
  }

  /// Fetch teams by tournament ID
  Future<void> fetchTeamsByTournamentId(int tourId) async {
    try {
      _setStatus(TeamStatus.loading);
      _isTeamLoading = true;
      notifyListeners();

      final teams = await _repository.getTeamsByTournamentId(tourId);
      _myTeams = teams;

      if (_myTeams.isNotEmpty) {
        await fetchTeamMembers(
            int.tryParse(_myTeams[_selectedTeamIndex].id) ?? 0);
      }

      _setStatus(TeamStatus.success);
    } catch (e) {
      _setStatus(TeamStatus.error);
      _errorMessage = e.toString();
    } finally {
      _isTeamLoading = false;
      notifyListeners();
    }
  }

  /// Fetch team members
  Future<void> fetchTeamMembers(int teamId) async {
    // Don't fetch if teamId is 0 or invalid
    if (teamId <= 0) {
      print('Skipping team member fetch for invalid team ID: $teamId');
      _teamMembers = [];
      notifyListeners();
      return;
    }

    try {
      print('Fetching team members for team ID: $teamId');
      _isLoading = true;
      notifyListeners();

      final members = await _repository.getAllMembers(teamId);
      _teamMembers = members;
      print('Fetched ${_teamMembers.length} team members');

      // Debug: Print team member details
      for (int i = 0; i < _teamMembers.length; i++) {
        print(
            'Member $i: ${_teamMembers[i].playerName} (${_teamMembers[i].playerTag})');
      }
    } catch (e) {
      print('Error fetching team members: $e');
      _setStatus(TeamStatus.error);
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select team
  void selectTeam(int index, bool isEnrolled) {
    if (isEnrolled) {
      _selectedEnrolledTeamIndex = index;
      if (_enrolledTeams.isNotEmpty) {
        final teamId = int.tryParse(_enrolledTeams[index].teamId);
        print('Selected Enrolled Team ID: $teamId');
        if (teamId != null && teamId > 0) {
          fetchTeamMembers(teamId);
        } else {
          print(
              'Invalid team ID for enrolled team: ${_enrolledTeams[index].teamId}');
          _teamMembers = [];
          notifyListeners();
        }
      }
    } else {
      _selectedTeamIndex = index;
      if (_myTeams.isNotEmpty && index < _myTeams.length) {
        final teamId = int.tryParse(_myTeams[index].id);
        if (teamId != null && teamId > 0) {
          fetchTeamMembers(teamId);
        } else {
          print('Invalid team ID for created team: ${_myTeams[index].id}');
          _teamMembers = [];
          notifyListeners();
        }
      }
    }
    notifyListeners();
  }

  /// Set current tab
  void setCurrentTab(int tabIndex) {
    _currentTabIndex = tabIndex;
    // Fetch team members for the current team when switching tabs
    _fetchCurrentTeamMembers();
    notifyListeners();
  }

  /// Fetch team members for the currently selected team
  void _fetchCurrentTeamMembers() {
    print('Fetching teams : $_myTeams');
    if (_currentTabIndex == 0) {
      // Created teams tab
      if (_myTeams.isNotEmpty && _selectedTeamIndex < _myTeams.length) {
        final teamId = int.tryParse(_myTeams[_selectedTeamIndex].id);
        if (teamId != null && teamId > 0) {
          fetchTeamMembers(teamId);
        } else {
          print(
              'Invalid team ID for created team: ${_myTeams[_selectedTeamIndex].id}');
          _teamMembers = [];
          notifyListeners();
        }
      } else {
        _teamMembers = [];
        notifyListeners();
      }
    } else {
      // Enrolled teams tab
      if (_enrolledTeams.isNotEmpty &&
          _selectedEnrolledTeamIndex < _enrolledTeams.length) {
        final teamId =
            int.tryParse(_enrolledTeams[_selectedEnrolledTeamIndex].id);
        if (teamId != null && teamId > 0) {
          fetchTeamMembers(teamId);
        } else {
          print(
              'Invalid team ID for enrolled team: ${_enrolledTeams[_selectedEnrolledTeamIndex].id}');
          _teamMembers = [];
          notifyListeners();
        }
      } else {
        _teamMembers = [];
        notifyListeners();
      }
    }
  }

  /// Assign role to player
  Future<void> assignRole(int playerIndex, String role) async {
    try {
      // Remove the specified role from the previous player, if any
      for (int i = 0; i < _teamMembers.length; i++) {
        if (_teamMembers[i].playerTag == role) {
          _teamMembers[i] = _teamMembers[i].copyWith(playerTag: '');
          final playerId = int.tryParse(_teamMembers[i].id) ?? 0;
          if (playerId > 0) {
            await _repository.updatePlayerTag(
                playerTag: '', playerId: playerId);
          }
          break;
        }
      }

      // Assign the new role to the selected player
      _teamMembers[playerIndex] =
          _teamMembers[playerIndex].copyWith(playerTag: role);
      final playerId = int.tryParse(_teamMembers[playerIndex].id) ?? 0;
      if (playerId > 0) {
        await _repository.updatePlayerTag(playerTag: role, playerId: playerId);
      }

      notifyListeners();
    } catch (e) {
      _setStatus(TeamStatus.error);
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await fetchMyTeams();
    await fetchEnrolledTeams();

    // After refreshing teams, fetch team members for the current tab
    _fetchCurrentTeamMembers();
  }

  /// Clear error
  void clearError() {
    _setStatus(TeamStatus.success);
    _errorMessage = '';
    notifyListeners();
  }

  /// Get current team
  TeamModel? getCurrentTeam() {
    if (_currentTabIndex == 0) {
      return _myTeams.isNotEmpty ? _myTeams[_selectedTeamIndex] : null;
    } else {
      return _enrolledTeams.isNotEmpty
          ? _enrolledTeams[_selectedEnrolledTeamIndex]
          : null;
    }
  }

  /// Get team members by category
  List<PlayerModel> getPlayersByCategory(String category) {
    final categories = SportCategories.getCategories(_preferredSport);
    final maxPlayers = SportCategories.getCategoryMaxPlayers(_preferredSport);

    int startIndex = 0;
    for (String cat in categories) {
      if (cat == category) {
        final maxCount = maxPlayers[category] ?? 0;
        return _teamMembers.skip(startIndex).take(maxCount).toList();
      }
      startIndex += maxPlayers[cat] ?? 0;
    }
    return [];
  }

  /// Get all categories for current sport
  List<String> getCategories() {
    return SportCategories.getCategories(_preferredSport);
  }

  /// Get roles for current sport
  List<String> getRoles() {
    return SportCategories.getRoles(_preferredSport);
  }

  /// Get role codes for current sport
  Map<String, String> getRoleCodes() {
    return SportCategories.getRoleCodes(_preferredSport);
  }

  /// Get role icons for current sport
  Map<String, IconData> getRoleIcons() {
    return SportCategories.getRoleIcons(_preferredSport);
  }

  /// Get role colors for current sport
  Map<String, Color> getRoleColors() {
    return SportCategories.getRoleColors(_preferredSport);
  }

  /// Private method to set status
  void _setStatus(TeamStatus status) {
    _status = status;
    if (status == TeamStatus.error) {
      _errorMessage =
          _errorMessage.isEmpty ? 'An error occurred' : _errorMessage;
    }
  }

  /// Dispose resources
  @override
  void dispose() {
    super.dispose();
  }
}
