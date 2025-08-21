import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../points_table/points_table_service.dart';
import '../points_table/points_table_view_model.dart';
import 'bracket_view_model.dart';
import '../groups/groupService.dart';
import 'widgets/bracket_match_widget.dart';
import 'widgets/bracket_overviewScreen.dart';

class BracketScreen extends StatefulWidget {
  final Map<String, dynamic> tournament;
  const BracketScreen({Key? key, required this.tournament}) : super(key: key);

  @override
  _BracketScreenState createState() => _BracketScreenState();
}

class _BracketScreenState extends State<BracketScreen>
    with WidgetsBindingObserver {
  final GroupService _groupService = GroupService();
  final PointsTableService _pointsService = PointsTableService();

  List<Map<String, dynamic>> _groupsData = [];
  List<String> _groupNames = [];
  String _selectedGroup = '';
  Map<String, List<String>> _groupTeams = {};
  final Map<String, int> _teamNameToId = {};
  bool _isAutoSaving = false;
  bool _isLocked = true; //

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _fetchGroups();
    // Set hook to intercept winner selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<BracketViewModel>(context, listen: false);
      vm.onWinnerSelectedHook = (matchId, winnerTeam, loserTeam) {
        _onWinnerSelected(matchId, winnerTeam);
      };
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _attemptAutoSave(reason: 'lifecycle:${state.name}');
    }
  }

  @override
  void dispose() {
    // Try to save before disposing
    _attemptAutoSave(reason: 'dispose');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void deactivate() {
    _attemptAutoSave(reason: 'deactivate');
    super.deactivate();
  }

  Future<void> _attemptAutoSave({String reason = 'unspecified'}) async {
    if (_isAutoSaving) return;
    _isAutoSaving = true;
    try {
      final vm = Provider.of<BracketViewModel>(context, listen: false);
      if (vm.currentBracket != null) {
        await vm.saveCurrentBracket(
          widget.tournament['id'],
          widget.tournament['preferred_sport'],
        );
      }
    } catch (_) {
    } finally {
      _isAutoSaving = false;
    }
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

      print("Fetched teams for group $groupName: $data");
      if (data != null) {
        setState(() {
          _groupTeams[groupName] =
              List<String>.from(data.map((team) => team['team_name']));
          // Build name->id mapping
          _teamNameToId.clear();
          for (final t in data) {
            try {
              final name = t['team_name']?.toString();
              final idRaw = t['team_id'];
              if (name != null && idRaw != null) {
                final id = int.tryParse(idRaw.toString());
                if (id != null) _teamNameToId[name] = id;
              }
            } catch (_) {}
          }
        });
        // Push mapping into bracket VM so it uses correct team IDs
        try {
          final vm = Provider.of<BracketViewModel>(context, listen: false);
          vm.setTeamIdMapping(Map<String, int>.from(_teamNameToId));
        } catch (_) {}
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
        return WillPopScope(
          onWillPop: () async {
            await _attemptAutoSave(reason: 'back');
            return true;
          },
          child: Scaffold(
            backgroundColor: Colors.grey[200],
            body: SingleChildScrollView(
              child: Column(
                children: [
                  _buildGroupSelector(viewModel),
                  const SizedBox(height: 5),
                  _buildBracketContent(viewModel),
                ],
              ),
            ),
            floatingActionButton: _buildFloatingActionButton(viewModel),
          ),
        );
      },
    );
  }

  Widget _buildGroupSelector(BracketViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            'Select Category for Draw',
            style: GoogleFonts.getFont('Poppins',
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          if (_groupNames.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
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
                    _attemptAutoSave(reason: 'groupChange');
                    setState(() {
                      _selectedGroup = newValue;
                    });
                    viewModel.setSelectedGroup(newValue);
                    // viewModel.fetchBracketForGroup(
                    //     widget.tournament['id'], newValue);
                    viewModel.filterTeamsBySearch('');
                    _fetchTeamsForGroup(newValue);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamSearchBar(BracketViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) {
            // Filter teams based on search query
            viewModel.filterTeamsBySearch(value);
          },
          decoration: InputDecoration(
            hintText: 'Search teams...',
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[600],
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
          ),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
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
    final selectedRound = viewModel.selectedRound;

    return Column(
      key: ValueKey(
          'bracket-${viewModel.currentBracket?['id']}-${viewModel.selectedGroup}-${viewModel.selectedRound}'),
      children: [
        // Round selector at the top
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                totalRounds,
                (index) {
                  final round = index + 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: viewModel.selectedRound == round
                            ? Colors.blue
                            : Colors.grey[300],
                        foregroundColor: viewModel.selectedRound == round
                            ? Colors.white
                            : Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                      ),
                      onPressed: () {
                        viewModel.setSelectedRound(round);
                      },
                      child: Text('Round $round'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Shuffle button and search bar in same row
        if (viewModel.currentBracket != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.shuffle, size: 14),
                  label: const Text('Shuffle', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 36),
                  ),
                  onPressed: _isLocked
                      ? null
                      : () {
                          viewModel.shuffleRoundTeams(viewModel.selectedRound);
                        },
                ),
                const SizedBox(width: 5),
                Expanded(child: _buildTeamSearchBar(viewModel)),
                const SizedBox(width: 5),
                TextButton.icon(
                  onPressed: () =>
                      _showAvailableTeamsDialog(context, availableTeams),
                  icon: const Icon(Icons.group, size: 16),
                  label: const Text('Teams', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 36),
                  ),
                ),
                const SizedBox(width: 5),
                IconButton(
                  tooltip: 'View Full Bracket',
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BracketOverviewScreen(),
                      ),
                    );
                  },
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                ),
                const SizedBox(width: 5),
                // Lock/Unlock button
                IconButton(
                  icon: Icon(
                    _isLocked ? Icons.lock : Icons.lock_open,
                    color: _isLocked ? Colors.orange : Colors.green,
                    size: 18,
                  ),
                  tooltip: _isLocked
                      ? 'Unlock to allow shuffling'
                      : 'Lock to prevent shuffling',
                  onPressed: () {
                    setState(() {
                      _isLocked = !_isLocked;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isLocked
                              ? 'Draw is now locked'
                              : 'Draw is now unlocked',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor:
                            _isLocked ? Colors.orange : Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                ),
              ],
            ),
          ),

        // Bracket content below search bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: _buildRoundColumn(
              selectedRound,
              viewModel.getMatchesForRound(selectedRound),
              viewModel,
              availableTeams,
              context,
            ),
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
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GestureDetector(
          //   onTap: () => viewModel.setSelectedRound(round),
          //   child: Row(
          //     children: [
          //       // Round header without shuffle button
          //       Container(
          //         padding:
          //             const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //         decoration: BoxDecoration(
          //           color: isSelectedRound
          //               ? const Color(0xFF264653)
          //               : Colors.grey[600],
          //           borderRadius: BorderRadius.circular(20),
          //           boxShadow: isSelectedRound
          //               ? [
          //                   BoxShadow(
          //                     color: Colors.black.withOpacity(0.08),
          //                     blurRadius: 4,
          //                     offset: const Offset(0, 2),
          //                   ),
          //                 ]
          //               : [],
          //         ),
          //         child: Text(
          //           'Round $round',
          //           style: const TextStyle(
          //             color: Colors.white,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 4),
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
          heroTag: 'scheduleFab',
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Schedule Matches'),
                content: const Text(
                    'Are you sure you want to schedule all matches?',
                    style: TextStyle(color: Colors.green)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Yes, Schedule'),
                  ),
                ],
              ),
            );

            if (confirmed != true) return;

            // First save (with required params), then schedule
            final saved = await viewModel.saveCurrentBracket(
              widget.tournament['id'],
              widget.tournament['preferred_sport'],
            );
            if (!saved) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Failed to save bracket: ${viewModel.errorMessage}'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final ok = await viewModel.scheduleAllMatches();
            if (ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Matches scheduled successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Failed to schedule matches: ${viewModel.errorMessage}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          backgroundColor: Colors.orange,
          child: const Icon(Icons.event_available, color: Colors.white),
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
    // final isSingleTeam = _isSingleTeamMatch(matchId);
    // final points = isSingleTeam ? 1 : 2;

    // Points rules:
    // - Winner: 2 points
    // - If only one team present (BYE): 2 points as well
    final isSingleTeam = _isSingleTeamMatch(matchId);
    final points = isSingleTeam ? 2 : 2;

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
              title: const Text('Delete Draw'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(viewModel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.blue),
              title: const Text('Reset Draw'),
              onTap: () {
                Navigator.pop(context);
                _showResetConfirmation(viewModel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.green),
              title: const Text('Share Draw'),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this bracket?'),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Warning: This action will:\nâ¢ Permanently delete ALL points for this tournament group from the Points Table\nâ¢ Cannot be undone',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // final success = await viewModel
              //     .deleteBracket(viewModel.currentBracket!['id']);
              // if (success) {
              //   try {
              //     final ptVm =
              //         Provider.of<PointsTableViewModel>(context, listen: false);
              //     await PointsTableService().deletePointsByTournamentAndGroup(
              //         tournamentId: widget.tournament['id'],
              //         groupName: viewModel.selectedGroup);
              //     ptVm.init(widget.tournament['id']);
              //   } catch (_) {}
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     const SnackBar(
              //         content: Text('Bracket deleted successfully!')),

              try {
                // 1) First delete all points for this tournament/group
                final ptVm =
                    Provider.of<PointsTableViewModel>(context, listen: false);
                await PointsTableService().deletePointsByTournamentAndGroup(
                    tournamentId: widget.tournament['id'],
                    groupName: viewModel.selectedGroup);
                ptVm.init(widget.tournament['id']);

                // 2) Then delete the bracket
                final success = await viewModel
                    .deleteBracket(viewModel.currentBracket!['id']);

                if (success) {
                  // 3) Clear the current bracket state and save empty state
                  viewModel
                      .clearBracketState(widget.tournament['preferred_sport']);

                  // 4) Refresh the UI to show no bracket view
                  setState(() {});

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Bracket deleted successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Failed to delete bracket: ${viewModel.errorMessage}'),
                        backgroundColor: Colors.red),
                  );
                }
              } catch (e) {
                print('Error during bracket deletion: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error deleting bracket: $e'),
                      backgroundColor: Colors.red),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to reset all match results?'),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Warning: This action will also permanently delete ALL points for this tournament group from the Points Table.',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              () async {
                try {
                  final ptVm =
                      Provider.of<PointsTableViewModel>(context, listen: false);
                  final vm =
                      Provider.of<BracketViewModel>(context, listen: false);

                  // 1) Delete all points for this tournament/group
                  await PointsTableService().deletePointsByTournamentAndGroup(
                      tournamentId: widget.tournament['id'],
                      groupName: vm.selectedGroup);
                  ptVm.init(widget.tournament['id']);

                  // 2) Delete existing bracket if present
                  if (vm.currentBracket != null) {
                    await vm.deleteBracket(vm.currentBracket!['id']);
                  }

                  // 3) Build team list for the group (use cached or fetch)
                  List<String> teamNames = _groupTeams[_selectedGroup] ?? [];
                  if (teamNames.isEmpty) {
                    try {
                      final data = await _groupService.fetchAllTeamsByGroups(
                          widget.tournament['id'], _selectedGroup);
                      if (data != null) {
                        teamNames = List<String>.from(data
                            .map((t) => (t['team_name'] ?? '').toString())
                            .where((s) => s.isNotEmpty));
                      }
                    } catch (_) {}
                  }

                  // 4) Create a fresh bracket for this group with same structure logic
                  final created = await vm.createBracketForGroup(
                      widget.tournament['id'], _selectedGroup, teamNames);

                  if (created) {
                    // Reload and show Round 1
                    await vm.fetchBracketForGroup(
                        widget.tournament['id'], _selectedGroup);
                    vm.setSelectedRound(1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Bracket reset successfully!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Failed to recreate bracket after reset.')),
                    );
                  }
                } catch (_) {}
              }();
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
