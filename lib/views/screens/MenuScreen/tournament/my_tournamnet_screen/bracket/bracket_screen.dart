import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../points_table/points_table_service.dart';
import '../points_table/points_table_view_model.dart';
import 'bracket_view_model.dart';
import '../groups/groupService.dart';
import 'widgets/bracket_match_widget.dart';

class BracketScreen extends StatefulWidget {
  final Map<String, dynamic> tournament;
  const BracketScreen({Key? key, required this.tournament}) : super(key: key);

  @override
  _BracketScreenState createState() => _BracketScreenState();
}

class _BracketScreenState extends State<BracketScreen> {
  final GroupService _groupService = GroupService();
  final PointsTableService _pointsService = PointsTableService();

  List<Map<String, dynamic>> _groupsData = [];
  List<String> _groupNames = [];
  String _selectedGroup = '';
  Map<String, List<String>> _groupTeams = {};
  final Map<String, int> _teamNameToId = {};
  @override
  void initState() {
    super.initState();

    _fetchGroups();
    // Set hook to intercept winner selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<BracketViewModel>(context, listen: false);
      vm.onWinnerSelectedHook = (matchId, winnerTeam, loserTeam) {
        _onWinnerSelected(matchId, winnerTeam);
      };
    });
  }

  // This method will be called after groups are fetched
  void _onGroupsFetched() {
    if (_groupNames.isNotEmpty && _selectedGroup.isNotEmpty) {
      // Fetch teams and bracket for the selected group
      _fetchTeamsForGroup(_selectedGroup);
    }
  }

  Future<void> _fetchGroups() async {
    try {
      final data = await _groupService.fetchAllGroups(widget.tournament['id']);
      if (data != null) {
        setState(() {
          _groupsData = List<Map<String, dynamic>>.from(data);
          _groupNames = _groupsData
              .map((group) => group['group_name'].toString())
              .toList();
          if (_groupNames.isNotEmpty) {
            _selectedGroup = _groupNames[0];
          }
        });

        // After groups are set, fetch teams and bracket
        if (_groupNames.isNotEmpty) {
          _onGroupsFetched();
        }
      }
    } catch (e) {
      print("Error fetching groups: $e");
    }
  }

  Future<void> _fetchTeamsForGroup(String groupName) async {
    try {
      final data = await _groupService.fetchAllTeamsByGroups(
          widget.tournament['id'], groupName);
      if (data != null) {
        setState(() {
          _groupTeams[groupName] =
              List<String>.from(data.map((team) => team['team_name']));
          // Build name->id mapping
          _teamNameToId.clear();
          for (final t in data) {
            try {
              final name = t['team_name']?.toString();
              final idRaw = t['id'] ?? t['team_id'];
              if (name != null && idRaw != null) {
                final id = int.tryParse(idRaw.toString());
                if (id != null) _teamNameToId[name] = id;
              }
            } catch (_) {}
          }
        });
      }
      // else {
      //   // Add demo teams if no data found (for testing)
      //   setState(() {
      //     _groupTeams[groupName] = [
      //       'Mumbai Indians',
      //       'Chennai Super Kings',
      //       'Royal Challengers',
      //       'Kolkata Knight Riders',
      //       'Delhi Capitals',
      //       'Punjab Kings',
      //       'Rajasthan Royals',
      //       'Sunrisers Hyderabad',
      //     ];
      //   });
      // }

      // Fetch existing bracket for this group
      final viewModel = Provider.of<BracketViewModel>(context, listen: false);
      await viewModel.fetchBracketForGroup(widget.tournament['id'], groupName);

      // Check if bracket was found
      if (viewModel.currentBracket != null) {
        print("Existing bracket found for group: $groupName");
      } else {
        print("No existing bracket found for group: $groupName");
      }
    } catch (e) {
      print("Error fetching teams for group: $e");
      // Add demo teams on error (for testing)
      // setState(() {
      //   _groupTeams[groupName] = [
      //     'Mumbai Indians',
      //     'Chennai Super Kings',
      //     'Royal Challengers',
      //     'Kolkata Knight Riders',
      //     'Delhi Capitals',
      //     'Punjab Kings',
      //     'Rajasthan Royals',
      //     'Sunrisers Hyderabad',
      //   ];
      // });

      // Fetch existing bracket for this group even on error
      final viewModel = Provider.of<BracketViewModel>(context, listen: false);
      await viewModel.fetchBracketForGroup(widget.tournament['id'], groupName);

      // Check if bracket was found
      if (viewModel.currentBracket != null) {
        print("Existing bracket found for group: $groupName");
      } else {
        print("No existing bracket found for group: $groupName");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BracketViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.grey[200],
          body: Column(
            children: [
              _buildGroupSelector(viewModel),
              const SizedBox(height: 20),
              Expanded(
                child: _buildBracketContent(viewModel),
              ),
            ],
          ),
          floatingActionButton: _buildFloatingActionButton(viewModel),
        );
      },
    );
  }

  Widget _buildGroupSelector(BracketViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Select Group for Bracket',
            style: GoogleFonts.getFont('Poppins',
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (_groupNames.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButton<String>(
                value: _selectedGroup.isNotEmpty ? _selectedGroup : null,
                hint: const Text('Select a group'),
                isExpanded: true,
                underline: Container(),
                items: _groupNames.map((String groupName) {
                  return DropdownMenuItem<String>(
                    value: groupName,
                    child: Text(groupName),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedGroup = newValue;
                    });
                    viewModel.setSelectedGroup(newValue);
                    viewModel.fetchBracketForGroup(
                        widget.tournament['id'], newValue);
                    _fetchTeamsForGroup(newValue);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBracketContent(BracketViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading bracket...'),
          ],
        ),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error: ${viewModel.errorMessage}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.refreshData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    print("Current bracket: ${viewModel.currentBracket}");
    print("Bracket structure: ${viewModel.bracketStructure.length} matches");

    if (viewModel.currentBracket == null) {
      print("No current bracket, showing no bracket view");
      return _buildNoBracketView(viewModel);
    }

    print("Current bracket found, showing bracket view");
    return _buildBracketView(viewModel);
  }

  Widget _buildNoBracketView(BracketViewModel viewModel) {
    final teams = _groupTeams[_selectedGroup] ?? [];

    if (teams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Teams in Group',
              style: GoogleFonts.getFont('Poppins',
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Please add teams to this group first',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Go to Groups tab to add teams',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_cricket,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Bracket Created',
            style: GoogleFonts.getFont('Poppins',
                fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a tournament bracket for ${teams.length} teams',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Teams will be automatically shuffled for fair competition',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _createBracket(viewModel, teams),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF264653),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text(
              'Create Bracket',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBracketView(BracketViewModel viewModel) {
    final totalRounds = viewModel.getTotalRounds();
    final availableTeams = viewModel.getAvailableTeamsForSelectedRound();

    return Stack(
      children: [
// show all rounds
        // Row(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Expanded(
        //       child: SingleChildScrollView(
        //         scrollDirection: Axis.horizontal,
        //         child: SingleChildScrollView(
        //           child: Padding(
        //             padding: const EdgeInsets.all(16),
        //             child: Row(
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: List.generate(totalRounds, (roundIndex) {
        //                 final round = roundIndex + 1;
        //                 final matches = viewModel.getMatchesForRound(round);
        //                 return _buildRoundColumn(
        //                     round, matches, viewModel, availableTeams, context);
        //               }),
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),

// Add this above your bracket view

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  totalRounds,
                  (index) {
                    final round = index + 1;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: viewModel.selectedRound == round
                              ? Colors.blue
                              : Colors.grey[300],
                          foregroundColor: viewModel.selectedRound == round
                              ? Colors.white
                              : Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            viewModel.setSelectedRound(round);
                          });
                        },
                        child: Text('Round $round'),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Builder(
                      builder: (context) {
                        final selectedRound = viewModel.selectedRound;
                        final matches =
                            viewModel.getMatchesForRound(selectedRound);
                        return _buildRoundColumn(selectedRound, matches,
                            viewModel, availableTeams, context);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Floating button for available teams
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton.extended(
            heroTag: 'availableTeamsFAB',
            backgroundColor: Colors.blueGrey,
            icon: const Icon(Icons.group),
            label: const Text('Available Teams'),
            onPressed: () => _showAvailableTeamsDialog(context, availableTeams),
          ),
        ),
      ],
    );
  }

  Widget _buildRoundColumn(
      int round,
      List<Map<String, dynamic>> matches,
      BracketViewModel viewModel,
      List<String> availableTeams,
      BuildContext context) {
    bool allCompleted = matches.every((m) => m['status'] == 'completed');
    final isSelectedRound = viewModel.selectedRound == round;

    return Container(
      margin: const EdgeInsets.only(right: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => viewModel.setSelectedRound(round),
            child: Row(
              children: [
                // Container(
                //   padding:
                //       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //   decoration: BoxDecoration(
                //     color: isSelectedRound
                //         ? const Color(0xFF264653)
                //         : Colors.grey[600],
                //     borderRadius: BorderRadius.circular(20),
                //     boxShadow: isSelectedRound
                //         ? [
                //             BoxShadow(
                //               color: Colors.black.withOpacity(0.08),
                //               blurRadius: 4,
                //               offset: const Offset(0, 2),
                //             ),
                //           ]
                //         : [],
                //   ),
                //   child: Text(
                //     'Round $round',
                //     style: const TextStyle(
                //       color: Colors.white,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
                if (!allCompleted && isSelectedRound)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.shuffle, size: 16),
                      label: const Text('Shuffle Teams',
                          style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                      ),
                      onPressed: () {
                        viewModel.shuffleRoundTeams(round);
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...matches
              .map((match) => BracketMatchWidget(
                    match: match,
                    onWinnerSelected: (matchId, winner, loser) =>
                        _selectWinner(matchId, winner, loser, viewModel),

                    // onStatusChanged: (matchId, status) =>
                    //     viewModel.updateMatchStatus(matchId, status),

                    onStatusChanged: (matchId, status) async {
                      viewModel.updateMatchStatus(matchId, status);
                      final normalized = status.toString().toLowerCase();
                      if (normalized == 'draw' || normalized == 'tie') {
                        await _awardTiePoints(matchId);
                      }
                    },
                    onRemoveTeam: isSelectedRound
                        ? (matchId, teamSlot) =>
                            viewModel.removeTeamFromMatch(matchId, teamSlot)
                        : null,
                    onAddTeam: isSelectedRound
                        ? (matchId, teamSlot) => _showAddTeamDialog(
                            context, viewModel, round, matchId, teamSlot)
                        : null,
                    availableTeams: availableTeams,
                  ))
              .toList(),
        ],
      ),
    );
  }

  void _showAddTeamDialog(BuildContext context, BracketViewModel viewModel,
      int round, String matchId, String teamSlot) {
    final availableTeams = viewModel.getAvailableTeamsForRound(round);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Team'),
        content: SizedBox(
          width: 200,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableTeams.length,
            itemBuilder: (context, idx) {
              final team = availableTeams[idx];
              return ListTile(
                title: Text(team),
                onTap: () {
                  Navigator.pop(context);
                  viewModel.addTeamToMatch(matchId, teamSlot, team);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BracketViewModel viewModel) {
    if (viewModel.currentBracket == null) return const SizedBox.shrink();

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: () => _showBracketOptions(viewModel),
          backgroundColor: const Color(0xFF264653),
          child: const Icon(Icons.more_vert, color: Colors.white),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: () async {
            final success = await viewModel.saveCurrentBracket(
              widget.tournament['id'],
              widget.tournament['preferred_sport'],
            );
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bracket saved successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Failed to save bracket: ${viewModel.errorMessage}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.save, color: Colors.white),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: () => viewModel.refreshData(),
          backgroundColor: Colors.blue,
          child: const Icon(Icons.refresh, color: Colors.white),
        ),
      ],
    );
  }

  void _createBracket(BracketViewModel viewModel, List<String> teams) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await viewModel.createBracketForGroup(
        widget.tournament['id'], _selectedGroup, teams);

    // Hide loading dialog
    Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Bracket created successfully for ${teams.length} teams!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create bracket: ${viewModel.errorMessage}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _selectWinner(String matchId, String winner, String loser,
      BracketViewModel viewModel) async {
    final success = await viewModel.updateMatchResult(matchId, winner, loser);

// before point table
    // if (success) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('$winner wins!'),
    //       backgroundColor: Colors.green,
    //     ),
    //   );
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Failed to update result: ${viewModel.errorMessage}'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    // }

    // if (success) {
    //   await _onWinnerSelected(matchId, winner);
    // } else

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update result: ${viewModel.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _onWinnerSelected(String matchId, String winnerTeam) async {
    final round =
        Provider.of<BracketViewModel>(context, listen: false).selectedRound;
    final int tournamentId = widget.tournament['id'];
    final groupName = _selectedGroup;

    // Points rules:
    // - Winner: 2 points
    // - If only one team present: 1 point
    final isSingleTeam = _isSingleTeamMatch(matchId);
    final points = isSingleTeam ? 1 : 2;

    // Pass fixed match id 10 as requested
    const int matchNumericId = 10;
    // Prefer real team id from bracket model if available
    final bracketVm = Provider.of<BracketViewModel>(context, listen: false);
    int teamId = _teamNameToId[winnerTeam] ??
        bracketVm.teamIdByName(winnerTeam) ??
        _generateTeamIdFromName(winnerTeam);

    await _pointsService.createPoints(
      matchId: matchNumericId,
      teamId: teamId,
      tournamentId: tournamentId,
      points: points,
      round: 'Round $round',
      category: groupName,
    );

    // Refresh points table
    final ptVm = Provider.of<PointsTableViewModel>(context, listen: false);
    ptVm.setGroup(groupName);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$winnerTeam awarded $points point(s).'),
        backgroundColor: Colors.green,
      ),
    );
  }

  int _generateTeamIdFromName(String name) {
    // Fallback if team id mapping is not available
    return name.hashCode;
  }

  bool _isSingleTeamMatch(String matchId) {
    final vm = Provider.of<BracketViewModel>(context, listen: false);
    final match = vm.bracketStructure.firstWhere(
      (m) => m['match_id'] == matchId,
      orElse: () => {},
    );
    final team1 = match['team1'];
    final team2 = match['team2'];
    bool isNullOrBye(dynamic t) =>
        t == null || t.toString().trim().isEmpty || t == 'BYE';
    return (isNullOrBye(team1) && !isNullOrBye(team2)) ||
        (!isNullOrBye(team1) && isNullOrBye(team2));
  }

  Future<void> _awardTiePoints(String matchId) async {
    final vm = Provider.of<BracketViewModel>(context, listen: false);
    final int tournamentId = widget.tournament['id'];
    final groupName = _selectedGroup;
    final round = vm.selectedRound;
    const int matchNumericId = 10;

    final match = vm.bracketStructure.firstWhere(
      (m) => m['match_id'] == matchId,
      orElse: () => {},
    );
    final teamNames = <String>[];
    if (match.isNotEmpty) {
      if (match['team1'] != null && match['team1'] != 'BYE')
        teamNames.add(match['team1']);
      if (match['team2'] != null && match['team2'] != 'BYE')
        teamNames.add(match['team2']);
    }

    for (final name in teamNames) {
      final teamId = _teamNameToId[name] ??
          vm.teamIdByName(name) ??
          _generateTeamIdFromName(name);

      await _pointsService.createPoints(
        matchId: matchNumericId,
        teamId: teamId,
        tournamentId: tournamentId,
        points: 1,
        round: 'Round $round',
        category: groupName,
      );
    }

    final ptVm = Provider.of<PointsTableViewModel>(context, listen: false);
    ptVm.setGroup(groupName);

    if (teamNames.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Both teams awarded 1 point for tie/draw.'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _showBracketOptions(BracketViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Bracket'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(viewModel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.blue),
              title: const Text('Reset Bracket'),
              onTap: () {
                Navigator.pop(context);
                _showResetConfirmation(viewModel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.green),
              title: const Text('Share Bracket'),
              onTap: () {
                Navigator.pop(context);
                _shareBracket(viewModel);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BracketViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bracket'),
        content: const Text('Are you sure you want to delete this bracket?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await viewModel
                  .deleteBracket(viewModel.currentBracket!['id']);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Bracket deleted successfully!')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BracketViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Bracket'),
        content:
            const Text('Are you sure you want to reset all match results?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement reset functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bracket reset successfully!')),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _shareBracket(BracketViewModel viewModel) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _showAvailableTeamsDialog(
      BuildContext context, List<String> availableTeams) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Available Teams'),
        content: SizedBox(
          width: 220,
          child: availableTeams.isEmpty
              ? const Text('No teams available',
                  style: TextStyle(color: Colors.grey))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableTeams.length,
                  itemBuilder: (context, idx) {
                    final team = availableTeams[idx];
                    return ListTile(
                      title: Text(team),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

// below is before points
  // void _showBracketOptions(BracketViewModel viewModel) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) => Container(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           ListTile(
  //             leading: const Icon(Icons.delete, color: Colors.red),
  //             title: const Text('Delete Bracket'),
  //             onTap: () {
  //               Navigator.pop(context);
  //               _showDeleteConfirmation(viewModel);
  //             },
  //           ),
  //           ListTile(
  //             leading: const Icon(Icons.refresh, color: Colors.blue),
  //             title: const Text('Reset Bracket'),
  //             onTap: () {
  //               Navigator.pop(context);
  //               _showResetConfirmation(viewModel);
  //             },
  //           ),
  //           ListTile(
  //             leading: const Icon(Icons.share, color: Colors.green),
  //             title: const Text('Share Bracket'),
  //             onTap: () {
  //               Navigator.pop(context);
  //               _shareBracket(viewModel);
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // void _showDeleteConfirmation(BracketViewModel viewModel) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Delete Bracket'),
  //       content: const Text('Are you sure you want to delete this bracket?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () async {
  //             Navigator.pop(context);
  //             final success = await viewModel
  //                 .deleteBracket(viewModel.currentBracket!['id']);
  //             if (success) {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 const SnackBar(
  //                     content: Text('Bracket deleted successfully!')),
  //               );
  //             }
  //           },
  //           child: const Text('Delete', style: TextStyle(color: Colors.red)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void _showResetConfirmation(BracketViewModel viewModel) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Reset Bracket'),
  //       content:
  //           const Text('Are you sure you want to reset all match results?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             // Implement reset functionality
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(content: Text('Bracket reset successfully!')),
  //             );
  //           },
  //           child: const Text('Reset', style: TextStyle(color: Colors.orange)),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // void _shareBracket(BracketViewModel viewModel) {
  //   // Implement share functionality
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Share functionality coming soon!')),
  //   );
  // }

  // void _showAvailableTeamsDialog(
  //     BuildContext context, List<String> availableTeams) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Available Teams'),
  //       content: SizedBox(
  //         width: 220,
  //         child: availableTeams.isEmpty
  //             ? const Text('No teams available',
  //                 style: TextStyle(color: Colors.grey))
  //             : ListView.builder(
  //                 shrinkWrap: true,
  //                 itemCount: availableTeams.length,
  //                 itemBuilder: (context, idx) {
  //                   final team = availableTeams[idx];
  //                   return ListTile(
  //                     title: Text(team),
  //                   );
  //                 },
  //               ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Close'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
