import 'package:flutter/material.dart';
import '../teamRepo/invite_player_repo.dart';

class InvitePlayerViewModel extends ChangeNotifier {
  final InvitePlayerRepository _repository = InvitePlayerRepository();

  // State variables
  List<Map<String, dynamic>> _invitedPlayers = [];
  Map<String, dynamic> _searchedUser = {};
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isInviting = false;
  List<bool> _isReInvitingList = [];
  String? _errorMessage;
  bool _isInvited = false;

  // Getters
  List<Map<String, dynamic>> get invitedPlayers => _invitedPlayers;
  Map<String, dynamic> get searchedUser => _searchedUser;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isInviting => _isInviting;
  List<bool> get isReInvitingList => _isReInvitingList;
  String? get errorMessage => _errorMessage;
  bool get isInvited => _isInvited;

  // Initialize data
  Future<void> initializeData(String teamId) async {
    await fetchInvitedPlayers(teamId);
  }

  // Fetch invited players
  Future<void> fetchInvitedPlayers(String teamId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final data = await _repository.getAllInvitedPlayers(teamId);
      _invitedPlayers = data;
      _isReInvitingList = List<bool>.filled(data.length, false);
    } catch (e) {
      _errorMessage = e.toString();
      _invitedPlayers = [];
      _isReInvitingList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search user by mobile number
  Future<void> searchUser(String mobileNumber) async {
    try {
      _isSearching = true;
      _errorMessage = null;
      notifyListeners();

      final user = await _repository.searchUserByMobile(mobileNumber);
      print('user is $user');
      _searchedUser = user;
    } catch (e) {
      _errorMessage = e.toString();
      _searchedUser = {};
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  // Send invite
  Future<String> sendInvite(String mobileNumber, int teamId) async {
    try {
      _isInviting = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _repository.sendInvite(mobileNumber, teamId);

      if (response == 'Invitation  Sent') {
        _isInvited = true;
        // Refresh the invited players list
        await fetchInvitedPlayers(teamId.toString());
      } else if (response == 'Invitation Already Sent') {
        _isInvited = true;
      }

      return response;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isInviting = false;
      notifyListeners();
    }
  }

  // Re-invite player
  Future<void> reInvitePlayer(
      int index, String mobileNumber, int teamId) async {
    if (index >= _isReInvitingList.length) return;

    try {
      _isReInvitingList[index] = true;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 2));
      await sendInvite(mobileNumber, teamId);
    } finally {
      if (index < _isReInvitingList.length) {
        _isReInvitingList[index] = false;
        notifyListeners();
      }
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset search
  void resetSearch() {
    _searchedUser = {};
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
