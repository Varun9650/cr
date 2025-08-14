import 'package:flutter/material.dart';
import 'package:cricyard/core/utils/smart_print.dart';
import '../../../../../../Entity/matches/Match/repository/Match_api_service.dart';

class MatchesViewModel extends ChangeNotifier {
  final MatchApiService _apiService = MatchApiService();

  // State variables
  List<Map<String, dynamic>> _matchDataById = [];
  List<Map<String, dynamic>> _matchLive = [];
  List<Map<String, dynamic>> _filteredMatches = [];
  String _selectedMatchType = 'Upcoming';
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Map<String, dynamic>> get matchDataById => _matchDataById;
  List<Map<String, dynamic>> get matchLive => _matchLive;
  List<Map<String, dynamic>> get filteredMatches => _filteredMatches;
  String get selectedMatchType => _selectedMatchType;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Set selected match type
  void setSelectedMatchType(String matchType) {
    _selectedMatchType = matchType;
    filterMatches();
    notifyListeners();
  }

  // Fetch matches by tournament ID
  Future<void> fetchMatchesById(int tourId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final fetchedEntities = await _apiService.myMatches(tourId);
      for (int i = 0; i < fetchedEntities.length; i++) {
        // smartPrint('FETCH MATCHES BY ID- $tourId is  ${fetchedEntities[i]}');
      }

      _matchDataById = List<Map<String, dynamic>>.from(fetchedEntities);
      filterMatches();
    } catch (e) {
      _errorMessage = 'Failed to fetch Match: $e';
      smartPrintError('Failed to fetch Match: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch live matches by tournament ID
  Future<void> fetchMatchesLive(int tourId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      smartPrint("tourId in fetchMatchesLive: --> $tourId");
      final fetchedEntities = await _apiService.liveMatchesByTourId(tourId);
      smartPrint('FETCH LIVE MATCHES BY ID -$tourId is  $fetchedEntities');

      _matchLive = List<Map<String, dynamic>>.from(fetchedEntities);
      filterMatches();
    } catch (e) {
      _errorMessage = 'Failed to fetch Live Match: $e';
      smartPrintError("Error is ===>$e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Initialize data
  Future<void> initializeData(int tourId) async {
    try {
      await Future.wait([
        fetchMatchesById(tourId),
        fetchMatchesLive(tourId),
      ]);
      smartPrint('Matches data refreshed successfully for tournament: $tourId');
    } catch (e) {
      smartPrintError('Error refreshing matches data: $e');
    }
  }

  // Refresh data (same as initialize but with better logging)
  Future<void> refreshData(int tourId) async {
    smartPrint('Refreshing matches data for tournament: $tourId');
    await initializeData(tourId);
  }

  // Filter matches based on selected type
  void filterMatches() {
    if (_selectedMatchType == 'Completed') {
      // Priority: Match status first, then date
      _filteredMatches = _matchDataById.where((match) {
        final matchStatus = match['matchStatus']?.toString() ?? '';
        final matchDateTime = DateTime.parse(match['datetime_field']);
        final now = DateTime.now();

        // Check if match is completed by status (camelCaseIgnore)
        if (_camelCaseIgnore(matchStatus, 'completed') ||
            _camelCaseIgnore(matchStatus, 'finished') ||
            _camelCaseIgnore(matchStatus, 'ended')) {
          return true;
        }

        // If status doesn't indicate completion, check by date
        // Consider a match completed if it's more than 6 hours past its scheduled time
        final timeDifference = now.difference(matchDateTime);
        return timeDifference.inHours > 6;
      }).toList();
    } else if (_selectedMatchType == 'Live') {
      // Priority: Match status first, then date
      _filteredMatches = _matchDataById.where((match) {
        final matchStatus = match['matchStatus']?.toString() ?? '';
        final matchDateTime = DateTime.parse(match['datetime_field']);
        final now = DateTime.now();
        final timeDifference = now.difference(matchDateTime);

        // Check if match is live by status (camelCaseIgnore)
        if (_camelCaseIgnore(matchStatus, 'started') ||
            _camelCaseIgnore(matchStatus, 'inProgress') ||
            _camelCaseIgnore(matchStatus, 'in_progress') ||
            _camelCaseIgnore(matchStatus, 'live') ||
            _camelCaseIgnore(matchStatus, 'ongoing')) {
          // Even if status indicates live, double-check the time window
          return timeDifference.inHours >= -1 && timeDifference.inHours <= 6;
        }

        // If status doesn't indicate live, check by date (match is currently happening)
        // Consider match live if it started within last 1 hour and hasn't been running for more than 6 hours
        return timeDifference.inHours >= -1 && timeDifference.inHours <= 6;
      }).toList();

      // Also include matches from matchLive array
      final liveMatchesFromApi = _matchLive.where((match) {
        final matchStatus = match['matchStatus']?.toString() ?? '';
        return _camelCaseIgnore(matchStatus, 'started') ||
            _camelCaseIgnore(matchStatus, 'inProgress') ||
            _camelCaseIgnore(matchStatus, 'in_progress') ||
            _camelCaseIgnore(matchStatus, 'live') ||
            _camelCaseIgnore(matchStatus, 'ongoing');
      }).toList();

      // Combine and remove duplicates
      final allLiveMatches = [..._filteredMatches, ...liveMatchesFromApi];
      final seenIds = <String>{};
      _filteredMatches = allLiveMatches.where((match) {
        final id = match['id']?.toString() ?? '';
        if (seenIds.contains(id)) {
          return false;
        }
        seenIds.add(id);
        return true;
      }).toList();
    } else {
      // Upcoming - Priority: Match status first, then date
      _filteredMatches = _matchDataById.where((match) {
        final matchStatus = match['matchStatus']?.toString() ?? '';
        final matchDateTime = DateTime.parse(match['datetime_field']);
        final now = DateTime.now();

        // First, exclude any live or completed matches by status
        if (_camelCaseIgnore(matchStatus, 'started') ||
            _camelCaseIgnore(matchStatus, 'inProgress') ||
            _camelCaseIgnore(matchStatus, 'in_progress') ||
            _camelCaseIgnore(matchStatus, 'live') ||
            _camelCaseIgnore(matchStatus, 'ongoing') ||
            _camelCaseIgnore(matchStatus, 'completed') ||
            _camelCaseIgnore(matchStatus, 'finished') ||
            _camelCaseIgnore(matchStatus, 'ended')) {
          return false; // Exclude live and completed matches
        }

        // Check if match is upcoming by status (camelCaseIgnore)
        if (_camelCaseIgnore(matchStatus, 'scheduled') ||
            _camelCaseIgnore(matchStatus, 'upcoming') ||
            _camelCaseIgnore(matchStatus, 'notStarted') ||
            _camelCaseIgnore(matchStatus, 'not_started') ||
            _camelCaseIgnore(matchStatus, 'pending')) {
          // Even if status indicates upcoming, double-check the date
          return matchDateTime.isAfter(now);
        }

        // If status doesn't indicate upcoming, check by date only
        return matchDateTime.isAfter(now);
      }).toList();

      // Sort upcoming matches by the remaining time
      _filteredMatches.sort((a, b) {
        final matchDateTimeA = DateTime.parse(a['datetime_field']);
        final matchDateTimeB = DateTime.parse(b['datetime_field']);
        return matchDateTimeA.compareTo(matchDateTimeB);
      });
    }
  }

  // Helper method for camelCaseIgnore matching
  bool _camelCaseIgnore(String text, String pattern) {
    if (text.isEmpty || pattern.isEmpty) return false;

    // Convert both to lowercase for comparison
    final lowerText = text.toLowerCase();
    final lowerPattern = pattern.toLowerCase();

    // Check for exact match
    if (lowerText == lowerPattern) return true;

    // Check for contains match
    if (lowerText.contains(lowerPattern)) return true;

    // Check for camelCase variations
    final camelCasePattern = pattern.replaceAllMapped(
        RegExp(r'[A-Z]'), (match) => '${match.group(0)?.toLowerCase()}');
    if (lowerText.contains(camelCasePattern.toLowerCase())) return true;

    // Check for snake_case variations
    final snakeCasePattern = pattern.replaceAllMapped(
        RegExp(r'[A-Z]'), (match) => '_${match.group(0)?.toLowerCase()}');
    if (lowerText.contains(snakeCasePattern.toLowerCase())) return true;

    return false;
  }

  // Get match status for navigation
  bool getStatus(String status) {
    if (status == 'Started' ||
        status == 'IN_PROGRESS' ||
        status == 'In_progress') {
      return true;
    } else {
      return false;
    }
  }
}
