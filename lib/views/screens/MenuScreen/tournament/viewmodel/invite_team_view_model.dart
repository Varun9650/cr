import 'package:flutter/material.dart';
import '../repository/invite_team_repo.dart';
import '../model/invite_team_model.dart';

class InviteTeamViewModel extends ChangeNotifier {
  final InviteTeamRepository _repository = InviteTeamRepository();

  // State variables
  List<InviteTeamModel> _teams = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<bool> _isInvitingList = [];
  int _tournamentId = 0;

  // Getters
  List<InviteTeamModel> get teams => _teams;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<bool> get isInvitingList => _isInvitingList;
  int get tournamentId => _tournamentId;

  // Set tournament ID
  void setTournamentId(int tournamentId) {
    _tournamentId = tournamentId;
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Fetch all teams
  Future<void> fetchAllTeams() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final teams = await _repository.getAllTeams();
      print('available teams are $teams');
      _teams = teams;
      _isInvitingList = List<bool>.filled(teams.length, false);

      debugPrint("Fetched ${teams.length} teams");
      for (int i = 0; i < teams.length; i++) {
        debugPrint("Team $i: ${teams[i].teamName}");
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch teams: $e';
      debugPrint("Error fetching teams: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch teams with pagination
  Future<List<InviteTeamModel>> fetchTeamsWithPagination(
      int page, int size) async {
    try {
      final teams = await _repository.getTeamsWithPagination(page, size);
      return teams;
    } catch (e) {
      _errorMessage = 'Failed to fetch teams with pagination: $e';
      notifyListeners();
      throw Exception('Failed to fetch teams with pagination: $e');
    }
  }

  // Fetch my teams
  Future<List<InviteTeamModel>> fetchMyTeams() async {
    try {
      final teams = await _repository.getMyTeams();
      return teams;
    } catch (e) {
      _errorMessage = 'Failed to fetch my teams: $e';
      notifyListeners();
      throw Exception('Failed to fetch my teams: $e');
    }
  }

  // Fetch enrolled teams
  Future<List<InviteTeamModel>> fetchEnrolledTeams() async {
    try {
      final teams = await _repository.getEnrolledTeams();
      return teams;
    } catch (e) {
      _errorMessage = 'Failed to fetch enrolled teams: $e';
      notifyListeners();
      throw Exception('Failed to fetch enrolled teams: $e');
    }
  }

  // Fetch teams by tournament ID
  Future<List<InviteTeamModel>> fetchTeamsByTournamentId(int tourId) async {
    try {
      final teams = await _repository.getTeamsByTournamentId(tourId);
      return teams;
    } catch (e) {
      _errorMessage = 'Failed to fetch teams by tournament ID: $e';
      notifyListeners();
      throw Exception('Failed to fetch teams by tournament ID: $e');
    }
  }

  // Fetch team members
  Future<List<Map<String, dynamic>>> fetchTeamMembers(int teamId) async {
    try {
      final members = await _repository.getAllTeamMembers(teamId);
      return members;
    } catch (e) {
      _errorMessage = 'Failed to fetch team members: $e';
      notifyListeners();
      throw Exception('Failed to fetch team members: $e');
    }
  }

  // Invite team to tournament
  Future<InviteTeamResponse> inviteTeam(int teamId) async {
    try {
      // Find team index for loading state
      final teamIndex = _teams.indexWhere((team) => team.id == teamId);
      if (teamIndex != -1) {
        _isInvitingList[teamIndex] = true;
        notifyListeners();
      }

      final response = await _repository.inviteTeam(_tournamentId, teamId);

      // Update team invitation status if successful
      if (response.success) {
        _teams = _teams.map((team) {
          if (team.id == teamId) {
            return team.copyWith(invited: true);
          }
          return team;
        }).toList();
      }

      debugPrint("Invite response: ${response.message}");
      return response;
    } catch (e) {
      _errorMessage = 'Failed to invite team: $e';
      debugPrint("Error inviting team: $e");
      throw Exception('Failed to invite team: $e');
    } finally {
      // Reset loading state for all teams
      _isInvitingList = List<bool>.filled(_teams.length, false);
      notifyListeners();
    }
  }

  // Create team
  Future<Map<String, dynamic>> createTeam(Map<String, dynamic> teamData) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _repository.createTeam(teamData);

      // Refresh teams list after creation
      await fetchAllTeams();

      return response;
    } catch (e) {
      _errorMessage = 'Failed to create team: $e';
      notifyListeners();
      throw Exception('Failed to create team: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update team
  Future<void> updateTeam(int teamId, Map<String, dynamic> teamData) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _repository.updateTeam(teamId, teamData);

      // Refresh teams list after update
      await fetchAllTeams();
    } catch (e) {
      _errorMessage = 'Failed to update team: $e';
      notifyListeners();
      throw Exception('Failed to update team: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete team
  Future<void> deleteTeam(int teamId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _repository.deleteTeam(teamId);

      // Refresh teams list after deletion
      await fetchAllTeams();
    } catch (e) {
      _errorMessage = 'Failed to delete team: $e';
      notifyListeners();
      throw Exception('Failed to delete team: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Initialize data
  Future<void> initializeData(int tournamentId) async {
    _tournamentId = tournamentId;
    await fetchAllTeams();
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchAllTeams();
  }

  // Get team by ID
  InviteTeamModel? getTeamById(int id) {
    try {
      return _teams.firstWhere((team) => team.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get team name safely
  String getTeamName(InviteTeamModel team) {
    return team.teamName ?? 'Unknown Team';
  }

  // Check if team is invited
  bool isTeamInvited(int teamId) {
    final team = getTeamById(teamId);
    return team?.invited ?? false;
  }

  // Get inviting state for specific team
  bool isInviting(int teamId) {
    final teamIndex = _teams.indexWhere((team) => team.id == teamId);
    if (teamIndex != -1 && teamIndex < _isInvitingList.length) {
      return _isInvitingList[teamIndex];
    }
    return false;
  }

  // Set inviting state for specific team
  void setInvitingState(int teamId, bool isInviting) {
    final teamIndex = _teams.indexWhere((team) => team.id == teamId);
    if (teamIndex != -1 && teamIndex < _isInvitingList.length) {
      _isInvitingList[teamIndex] = isInviting;
      notifyListeners();
    }
  }
}
