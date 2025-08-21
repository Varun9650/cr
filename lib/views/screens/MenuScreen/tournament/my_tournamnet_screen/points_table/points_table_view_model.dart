import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../bracket/bracket_view_model.dart';
import '../groups/groupService.dart';
import '../bracket/bracket_service.dart';
import 'points_table_service.dart';

class PointsTableViewModel extends ChangeNotifier {
  final GroupService _groupService = GroupService();
  final BracketService _bracketService = BracketService();
  final PointsTableService _pointsService = PointsTableService();

  bool _loading = false;
  String? _error;
  int _tournamentId = 0;
  List<String> _groups = [];
  String? _selectedGroup;
  List<String> _rounds = [];
  String? _selectedRound;
  List<Map<String, dynamic>> _entries = [];
  List<Map<String, dynamic>> _allEntriesForGroup = [];

  // Aggregated standings
  final Map<int, _TeamStanding> _teamIdToStanding = {};
  int _thresholdPoints = 0;
  final Set<int> _selectedTeamIds = {};

  bool get isLoading => _loading;
  String? get error => _error;
  List<String> get groups => _groups;
  String? get selectedGroup => _selectedGroup;
  List<String> get rounds => _rounds;
  String? get selectedRound => _selectedRound;
  List<String> get viewRounds => ['All', ..._rounds];
  List<Map<String, dynamic>> get entries => _entries;

  int get thresholdPoints => _thresholdPoints;
  List<_TeamStanding> get standings => _teamIdToStanding.values.toList()
    ..sort((a, b) => b.points.compareTo(a.points));
  List<_TeamStanding> get filteredStandings =>
      standings.where((s) => s.points >= _thresholdPoints).toList();

  Set<int> get selectedTeamIds => _selectedTeamIds;

  List<String> get advanceRounds {
    if (_rounds.isEmpty) return [];
    final sel = _selectedRound;
    if (sel == null || sel == 'All') return List<String>.from(_rounds);
    final selNum = int.tryParse(sel.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return _rounds.where((r) {
      final rn = int.tryParse(r.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return rn > selNum;
    }).toList();
  }

  void init(int tournamentId) {
    if (_tournamentId == tournamentId && _groups.isNotEmpty) return;
    _tournamentId = tournamentId;
    fetchGroupsAndRounds();
  }

  Future<void> fetchGroupsAndRounds() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final groupsData = await _groupService.fetchAllGroups(_tournamentId);
      _groups = (groupsData ?? [])
          .map((g) => (g as Map)['group_name'].toString())
          .cast<String>()
          .toList();
      _selectedGroup = _groups.isNotEmpty ? _groups.first : null;

      await _fetchPointsAllRounds();
    } catch (e) {
      _error = '$e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchPointsAllRounds() async {
    if (_selectedGroup == null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _allEntriesForGroup = await _pointsService.fetchPoints(
        tournamentId: _tournamentId,
        groupName: _selectedGroup!,
      );
      print('all entries  $_allEntriesForGroup'); // Debugging output
      _rounds = await _buildRoundsFromBracket();
      _selectedRound = _rounds.isNotEmpty ? _rounds.first : null;
      _filterEntriesForSelectedRound();
      _recomputeStandings();
      _selectedTeamIds.clear();
    } catch (e) {
      _error = '$e';
      _allEntriesForGroup = [];
      _entries = [];
      _teamIdToStanding.clear();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<List<String>> _buildRoundsFromBracket() async {
    try {
      final bracket =
          await _bracketService.getBracket(_tournamentId, _selectedGroup!);
      print('Bracket data: $bracket'); // Debugging output
      final total = (bracket?['total_round'] is int)
          ? bracket!['total_round'] as int
          : int.tryParse('${bracket?['total_round']}') ?? 0;
      print('Total rounds from bracket: $total');
      if (total <= 0) {
        // Fallback to entries-based rounds
        return _extractRoundsFromEntries(_allEntriesForGroup);
      }
      return List.generate(total, (i) => 'Round ${i + 1}');
    } catch (_) {
      return _extractRoundsFromEntries(_allEntriesForGroup);
    }
  }

  List<String> _extractRoundsFromEntries(List<Map<String, dynamic>> data) {
    final rounds = data
        .map((e) => e['round'])
        .where((r) => r != null)
        .map((r) => r.toString())
        .toSet()
        .toList();
    rounds.sort((a, b) {
      final ai = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final bi = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return ai.compareTo(bi);
    });
    return rounds.map((r) => r.startsWith('Round') ? r : 'Round $r').toList();
  }

  void setGroup(String group) {
    _selectedGroup = group;
    notifyListeners();
    _fetchPointsAllRounds();
  }

  void setRound(String round) {
    _selectedRound = round;
    notifyListeners();
    _filterEntriesForSelectedRound();

    _recomputeStandings();
  }

  void setThreshold(int points) {
    _thresholdPoints = points;
    notifyListeners();
  }

  void toggleTeamSelection(int teamId) {
    if (_selectedTeamIds.contains(teamId)) {
      _selectedTeamIds.remove(teamId);
    } else {
      _selectedTeamIds.add(teamId);
    }
    notifyListeners();
  }

  void selectAllFiltered() {
    _selectedTeamIds
      ..clear()
      ..addAll(filteredStandings.map((s) => s.teamId));
    notifyListeners();
  }

  void clearSelection() {
    _selectedTeamIds.clear();
    notifyListeners();
  }

  // Refresh points table data when tab is opened
  Future<void> refreshData() async {
    if (_selectedGroup != null) {
      await _fetchPointsAllRounds();
    }
  }

  Future<int> advanceSelectedToRound(
      BuildContext context, int targetRound) async {
    final names = filteredStandings
        .where((s) => _selectedTeamIds.contains(s.teamId))
        .map((s) => s.teamName)
        .toList();
    final selectedList = filteredStandings
        .where((s) => _selectedTeamIds.contains(s.teamId))
        .toList();
    final vm = Provider.of<BracketViewModel>(context, listen: false);
    // Ensure bracket is loaded for current group before assigning
    if ((vm.currentBracket == null) ||
        vm.selectedGroup != (_selectedGroup ?? '')) {
      await vm.fetchBracketForGroup(_tournamentId, _selectedGroup ?? '');
      vm.setSelectedGroup(_selectedGroup ?? '');
    }
    // Guard: require an existing bracket structure to update
    if (vm.currentBracket == null || vm.bracketStructure.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No bracket found for this group. Please create a bracket first in the Bracket tab.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return 0;
    }
    final assigned = await vm.assignTeamsToRound(targetRound, names);
    //  Insert 0-point entries for teams actually assigned
    final int count =
        assigned < selectedList.length ? assigned : selectedList.length;
    for (int i = 0; i < count; i++) {
      final s = selectedList[i];
      try {
        await _pointsService.createPoints(
          matchId: 10,
          teamId: s.teamId,
          tournamentId: _tournamentId,
          points: 0,
          round: 'Round $targetRound',
          category: _selectedGroup ?? '',
        );
      } catch (_) {}
    }
    // Immediately refresh bracket and points table views to reflect changes
    int nextRoundToShow = targetRound;

    try {
      await vm.fetchBracketForGroup(_tournamentId, _selectedGroup ?? '');
      // vm.setSelectedRound(targetRound);
      final total = vm.getTotalRounds();
      nextRoundToShow = targetRound < total ? targetRound + 1 : targetRound;
      vm.setSelectedRound(nextRoundToShow);
    } catch (_) {}

    try {
      await _fetchPointsAllRounds();
      // _selectedRound = 'Round $targetRound';
      _selectedRound = 'Round $nextRoundToShow';

      _filterEntriesForSelectedRound();
      _recomputeStandings();
      notifyListeners();
    } catch (_) {}
    return assigned;
  }

  void _filterEntriesForSelectedRound() {
    print('Filtering entries for round $_selectedRound');
    if (_selectedRound == null) {
      _entries = List.from(_allEntriesForGroup);
      return;
    }
    // final roundNum = _selectedRound!.replaceAll('Round ', '');
    _entries = _allEntriesForGroup.where((e) {
      final r = e['round'];
      return r != null && r.toString() == _selectedRound;
    }).toList();
  }

  // Kept for potential fallback if bracket-defined rounds are needed
  Future<List<String>> _deriveRoundsFromBracket(String? group) async {
    if (group == null) return [];
    try {
      final bracket = await _bracketService.getBracket(_tournamentId, group);
      if (bracket == null) return [];
      List<dynamic> structure = [];
      try {
        final decoded = bracket['model'] is String
            ? _tryDecode(bracket['model'])
            : bracket['model'];
        structure = (decoded?['structure'] ?? []) as List<dynamic>;
      } catch (_) {}
      final roundNums = structure
          .map((m) => (m as Map)['round'])
          .where((r) => r != null)
          .map((r) => int.tryParse(r.toString()) ?? 0)
          .where((r) => r > 0)
          .toSet()
          .toList()
        ..sort();
      return roundNums.map((n) => 'Round $n').toList();
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic>? _tryDecode(String raw) {
    try {
      return raw.isNotEmpty ? (jsonDecode(raw) as Map<String, dynamic>) : null;
    } catch (_) {
      return null;
    }
  }

  String readString(Map<String, dynamic> map, List<String> keys,
      {String fallback = '-'}) {
    for (final k in keys) {
      if (map.containsKey(k) &&
          map[k] != null &&
          map[k].toString().isNotEmpty) {
        return map[k].toString();
      }
    }
    return fallback;
  }

  void _recomputeStandings() {
    _teamIdToStanding.clear();
    print('Recomputing standings for $_entries');
    for (final e in _entries) {
      final idRaw = e['team_id'];
      final name = (e['team_name'] ?? e['team'] ?? '').toString();
      final points = int.tryParse((e['points'] ?? '0').toString()) ?? 0;
      if (idRaw == null) continue;
      final id = int.tryParse(idRaw.toString());
      if (id == null) continue;
      final st = _teamIdToStanding.putIfAbsent(
          id, () => _TeamStanding(teamId: id, teamName: name, points: 0));
      st.points += points;
    }
    print('Computed standings: $_teamIdToStanding');
  }

  double readDouble(Map<String, dynamic> map, List<String> keys,
      {double fallback = 0}) {
    for (final k in keys) {
      final v = map[k];
      if (v == null) continue;
      final parsed = double.tryParse(v.toString());
      if (parsed != null) return parsed;
    }
    return fallback;
  }
}

class _TeamStanding {
  final int teamId;
  final String teamName;
  int points;
  _TeamStanding(
      {required this.teamId, required this.teamName, required this.points});
}
