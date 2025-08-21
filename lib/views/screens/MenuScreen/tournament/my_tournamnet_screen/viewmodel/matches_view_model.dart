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
  String _searchQuery = '';

  String? _errorMessage;

  // Getters
  List<Map<String, dynamic>> get matchDataById => _matchDataById;
  List<Map<String, dynamic>> get matchLive => _matchLive;
  List<Map<String, dynamic>> get filteredMatches => _filteredMatches;
  String get selectedMatchType => _selectedMatchType;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    filterMatches();
    notifyListeners();
  }

  // Initialize data
  Future<void> initializeData(int tourId, bool isEnrolled) async {
    try {
      await Future.wait([
        fetchMatchesByTourId(tourId, isEnrolled),
        // fetchMatchesLive(tourId),
      ]);
      smartPrint('Matches data refreshed successfully for tournament: $tourId');
    } catch (e) {
      smartPrintError('Error refreshing matches data: $e');
    }
  }

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
  Future<void> fetchMatchesByTourId(int tourId, bool isEnrolled) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      List<dynamic> fetchedEntities;
      print(
          "tourId in fetchMatchesByTourId: --> $tourId, isEnrolled: $isEnrolled");
      if (isEnrolled) {
        // Agar user enrolled hai, to enrolled matches fetch kro
        fetchedEntities = await _apiService.myEnrolledMatches(tourId);
      } else {
        // Agar user enrolled nahi hai, to all tournament matches fetch kro
        fetchedEntities = await _apiService.allTournamentMatches(tourId);
      }
      // for (int i = 0; i < fetchedEntities.length; i++) {
      // smartPrint('FETCH MATCHES BY ID- $tourId is  ${fetchedEntities[i]}');
      // }
      print(
          'FETCH MATCHES BY ID- $tourId is  ${fetchedEntities.length} entities');
      print('FETCH MATCHES BY ID- $tourId is  $fetchedEntities');

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

  // Refresh data (same as initialize but with better logging)
  Future<void> refreshData(int tourId, bool isEnrolled) async {
    smartPrint('Refreshing matches data for tournament: $tourId');
    await initializeData(tourId, isEnrolled);
  }

  // Filter matches based on selected type
  // void filterMatches() {
  //   if (_selectedMatchType == 'Completed') {
  //     // Priority: Match status first, then date
  //     _filteredMatches = _matchDataById.where((match) {
  //       final matchStatus = match['matchStatus']?.toString() ?? '';
  //       final matchDateTime = DateTime.parse(match['datetime_field']);
  //       final now = DateTime.now();

  //       // Check if match is completed by status (camelCaseIgnore)
  //       if (_camelCaseIgnore(matchStatus, 'completed') ||
  //           _camelCaseIgnore(matchStatus, 'finished') ||
  //           _camelCaseIgnore(matchStatus, 'ended')) {
  //         return true;
  //       }

  //       // If status doesn't indicate completion, check by date
  //       // Consider a match completed if it's more than 6 hours past its scheduled time
  //       final timeDifference = now.difference(matchDateTime);
  //       return timeDifference.inHours > 6;
  //     }).toList();
  //     print('Filtered Completed Matches: ${_filteredMatches.length}');
  //   } else if (_selectedMatchType == 'Live') {
  //     // Priority: Match status first, then date
  //     _filteredMatches = _matchDataById.where((match) {
  //       final matchStatus = match['matchStatus']?.toString() ?? '';
  //       final matchDateTime = DateTime.parse(match['datetime_field']);
  //       final now = DateTime.now();
  //       final timeDifference = now.difference(matchDateTime);

  //       // Check if match is live by status (camelCaseIgnore)
  //       if (_camelCaseIgnore(matchStatus, 'started') ||
  //           _camelCaseIgnore(matchStatus, 'inProgress') ||
  //           _camelCaseIgnore(matchStatus, 'in_progress') ||
  //           _camelCaseIgnore(matchStatus, 'live') ||
  //           _camelCaseIgnore(matchStatus, 'ongoing')) {
  //         // Even if status indicates live, double-check the time window
  //         return timeDifference.inHours >= -1 && timeDifference.inHours <= 6;
  //       }

  //       // If status doesn't indicate live, check by date (match is currently happening)
  //       // Consider match live if it started within last 1 hour and hasn't been running for more than 6 hours
  //       return timeDifference.inHours >= -1 && timeDifference.inHours <= 6;
  //     }).toList();

  //     // Also include matches from matchLive array
  //     final liveMatchesFromApi = _matchLive.where((match) {
  //       final matchStatus = match['matchStatus']?.toString() ?? '';
  //       return _camelCaseIgnore(matchStatus, 'started') ||
  //           _camelCaseIgnore(matchStatus, 'inProgress') ||
  //           _camelCaseIgnore(matchStatus, 'in_progress') ||
  //           _camelCaseIgnore(matchStatus, 'live') ||
  //           _camelCaseIgnore(matchStatus, 'ongoing');
  //     }).toList();

  //     // Combine and remove duplicates
  //     final allLiveMatches = [..._filteredMatches, ...liveMatchesFromApi];
  //     final seenIds = <String>{};
  //     _filteredMatches = allLiveMatches.where((match) {
  //       final id = match['id']?.toString() ?? '';
  //       if (seenIds.contains(id)) {
  //         return false;
  //       }
  //       seenIds.add(id);
  //       return true;
  //     }).toList();
  //     print('Filtered Live Matches: ${_filteredMatches.length}');
  //   } else {
  //     // Upcoming - Priority: Match status first, then date
  //     _filteredMatches = _matchDataById.where((match) {
  //       final matchStatus = match['matchStatus']?.toString() ?? '';
  //       final matchDateTime = DateTime.parse(match['datetime_field']);
  //       final now = DateTime.now();

  //       // First, exclude any live or completed matches by status
  //       if (_camelCaseIgnore(matchStatus, 'started') ||
  //           _camelCaseIgnore(matchStatus, 'inProgress') ||
  //           _camelCaseIgnore(matchStatus, 'in_progress') ||
  //           _camelCaseIgnore(matchStatus, 'live') ||
  //           _camelCaseIgnore(matchStatus, 'ongoing') ||
  //           _camelCaseIgnore(matchStatus, 'completed') ||
  //           _camelCaseIgnore(matchStatus, 'finished') ||
  //           _camelCaseIgnore(matchStatus, 'ended')) {
  //         return false; // Exclude live and completed matches
  //       }

  //       // Check if match is upcoming by status (camelCaseIgnore)
  //       if (_camelCaseIgnore(matchStatus, 'scheduled') ||
  //           _camelCaseIgnore(matchStatus, 'upcoming') ||
  //           _camelCaseIgnore(matchStatus, 'notStarted') ||
  //           _camelCaseIgnore(matchStatus, 'not_started') ||
  //           _camelCaseIgnore(matchStatus, 'pending')) {
  //         // Even if status indicates upcoming, double-check the date
  //         return matchDateTime.isAfter(now);
  //       }

  //       // If status doesn't indicate upcoming, check by date only
  //       return matchDateTime.isAfter(now);
  //     }).toList();

  //     // Sort upcoming matches by the remaining time
  //     _filteredMatches.sort((a, b) {
  //       final matchDateTimeA = DateTime.parse(a['datetime_field']);
  //       final matchDateTimeB = DateTime.parse(b['datetime_field']);
  //       return matchDateTimeA.compareTo(matchDateTimeB);
  //     });
  //     print('Filtered Upcoming Matches: ${_filteredMatches.length}');
  //   }
  // }

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

  // Filter matches based on selected type
  void filterMatches() {
    List<Map<String, dynamic>> typeFilteredMatches;
    if (_selectedMatchType == 'Completed') {
      // Show matches with completed status
      typeFilteredMatches = _matchDataById.where((match) {
        final matchStatus =
            match['matchStatus']?.toString().toLowerCase() ?? '';
        return matchStatus.contains('completed') ||
            matchStatus.contains('finished') ||
            matchStatus.contains('ended');
      }).toList();

      print('Filtered Completed Matches: ${typeFilteredMatches.length}');
    } else if (_selectedMatchType == 'Live') {
      // Show matches with in_progress status
      typeFilteredMatches = _matchDataById.where((match) {
        final matchStatus =
            match['matchStatus']?.toString().toLowerCase() ?? '';
        return matchStatus.contains('started') ||
            matchStatus.contains('in_progress') ||
            matchStatus.contains('inprogress') ||
            matchStatus.contains('live') ||
            matchStatus.contains('ongoing');
      }).toList();

      print('Filtered Live Matches: ${typeFilteredMatches.length}');
    } else {
      // Upcoming - Show matches with scheduled status + any uncategorized matches
      typeFilteredMatches = _matchDataById.where((match) {
        final matchStatus =
            match['matchStatus']?.toString().toLowerCase() ?? '';
        return matchStatus.contains('scheduled') ||
            matchStatus.contains('upcoming') ||
            matchStatus.contains('not_started') ||
            matchStatus.contains('notstarted') ||
            matchStatus.contains('pending') ||
            // Fallback: if status is null or doesn't match any category, treat as upcoming
            matchStatus.isEmpty ||
            (!matchStatus.contains('completed') &&
                !matchStatus.contains('finished') &&
                !matchStatus.contains('ended') &&
                !matchStatus.contains('started') &&
                !matchStatus.contains('in_progress') &&
                !matchStatus.contains('inprogress') &&
                !matchStatus.contains('live') &&
                !matchStatus.contains('ongoing'));
      }).toList();

      // Sort upcoming matches by date (earliest first)
      typeFilteredMatches.sort((a, b) {
        final matchDateTimeA = DateTime.parse(a['datetime_field']);
        final matchDateTimeB = DateTime.parse(b['datetime_field']);
        return matchDateTimeA.compareTo(matchDateTimeB);
      });

      print('Filtered Upcoming Matches: ${typeFilteredMatches.length}');
    }

    // Apply search filter if search query exists
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      _filteredMatches = typeFilteredMatches.where((match) {
        final team1Name = (match['team_1_name'] ?? '').toString().toLowerCase();
        final team2Name = (match['team_2_name'] ?? '').toString().toLowerCase();
        final tournamentName =
            (match['tournament_name'] ?? '').toString().toLowerCase();
        final location = (match['location'] ?? '').toString().toLowerCase();
        final umpireName =
            (match['umpire_name'] ?? '').toString().toLowerCase();
        final courtName = (match['court_name'] ?? '').toString().toLowerCase();
        final matchStatus =
            (match['matchStatus'] ?? '').toString().toLowerCase();
        final matchType =
            (match['match_category'] ?? '').toString().toLowerCase();

        return team1Name.contains(query) ||
            team2Name.contains(query) ||
            tournamentName.contains(query) ||
            location.contains(query) ||
            umpireName.contains(query) ||
            courtName.contains(query) ||
            matchStatus.contains(query) ||
            matchType.contains(query);
      }).toList();
    } else {
      _filteredMatches = typeFilteredMatches;
    }

    // Debug: Check if any matches are not categorized
    _debugUncategorizedMatches();
  }

  // Debug method to check for uncategorized matches
  void _debugUncategorizedMatches() {
    final allStatuses = _matchDataById
        .map((match) => match['matchStatus']?.toString() ?? 'null')
        .toSet();
    print('All match statuses found: $allStatuses');

    final categorizedCount = _filteredMatches.length;
    final totalCount = _matchDataById.length;
    print('Total matches: $totalCount, Categorized: $categorizedCount');

    if (categorizedCount < totalCount) {
      print('Warning: Some matches may not be categorized properly!');
      final uncategorized = _matchDataById.where((match) {
        final matchStatus =
            match['matchStatus']?.toString().toLowerCase() ?? '';
        return !_filteredMatches.contains(match);
      }).toList();
      print('Uncategorized matches: ${uncategorized.length}');
      for (var match in uncategorized) {
        print(
            'Uncategorized match: ID=${match['id']}, Status=${match['matchStatus']}, DateTime=${match['datetime_field']}');
      }
    }
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
