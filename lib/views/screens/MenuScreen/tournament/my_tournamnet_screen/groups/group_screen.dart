import 'package:cricyard/data/exceptions/app_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../Entity/team/Teams/repository/Teams_api_service.dart';
import '../../views/scheduleMatchByTur.dart';
import 'groupService.dart';

class GroupScreen extends StatefulWidget {
  final Map<String, dynamic> tournament;
  const GroupScreen({Key? key, required this.tournament}) : super(key: key);

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  int _numberOfGroups = 0;
  final TextEditingController _groupController = TextEditingController();

  final teamsApiService teamapiService = teamsApiService();
  GroupService groupApi = GroupService();
  String _currentGroup = '';
  Map<String, List<Map<String, dynamic>>> _groupTeams = {};
  List<String> groups = [];
  List<dynamic> groupsData = [];
  bool _isLoading = false;
  bool _isTeamLoading = false;

  List<Map<String, dynamic>> enrolledTeams = [];

  @override
  void initState() {
    super.initState();
    fetchGroups();
    fetchMyTeamsbyTournamentId(widget.tournament['id']);
    print("RAW-DATA--${widget.tournament}");
  }

  Future<void> fetchGroups() async {
    setState(() {
      _isLoading = true;
    });
    final data = await groupApi.fetchAllGroups(widget.tournament['id']);
    setState(() {
      groupsData = data ?? [];
      _numberOfGroups = groupsData.length;
      // Clear existing groups before adding new ones
      groups.clear();
      _groupTeams.clear();
      for (var group in groupsData) {
        final groupName = group['group_name'];
        groups.add(groupName);
        if (!_groupTeams.containsKey(groupName)) {
          _groupTeams[groupName] = [];
        }
      }
      _currentGroup = groups.isNotEmpty ? groups[0] : '';
      _fetchAllTeamsByGroups(_currentGroup);
      _isLoading = false;
    });
  }

  Future<void> _fetchAllTeamsByGroups(String groupName) async {
    setState(() {
      _isTeamLoading = true;
    });
    final data = await groupApi.fetchAllTeamsByGroups(
        widget.tournament['id'], groupName);
    // Save both team name and id as a map
    setState(() {
      _groupTeams[groupName] = data == null
          ? []
          : List<Map<String, dynamic>>.from(
              data.map((team) => {
                    'team_name': team['team_name'],
                    'team_id': team['id'] ?? team['team_id'],
                  }),
            );
      _isTeamLoading = false;
    });
  }

  // Future<void> _deleteTeamFromGroup(int teamId) async {
  //   await groupApi.deleteTeamFormGroup(teamId);
  // }

  Future<void> createGroups(List<String> groupNames) async {
    setState(() {
      _isLoading = true;
    });

    // Get the list of currently existing group names
    final existingGroupNames =
        groupsData.map((group) => group['group_name']).toList();

    // Filter out the new group names that are already created
    List<String> newGroupNames = groupNames
        .where((groupName) => !existingGroupNames.contains(groupName))
        .toList();

    if (newGroupNames.isNotEmpty) {
      // Only make the API call if there are new groups to be created
      await groupApi.createGroup(widget.tournament['id'], newGroupNames);
      await fetchGroups(); // Refresh the UI with the newly created groups
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> addTeamsToGroup(int teamId, String groupName) async {
    setState(() {
      _isTeamLoading = true;
    });

    try {
      final response = await groupApi.addTeamsToGr(
          widget.tournament['id'], teamId, groupName);

      // Optional: Success check (agar aapka API kuch response deta hai)
      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? 'Something went wrong')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Team added successfully')),
        );
      }
    } catch (error) {
      print("Error adding team to group: $error");
      String errorMessage = '$error';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage, style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(top: 20.0, left: 10.0, right: 10.0),
        ),
      );
    } finally {
      setState(() {
        _isTeamLoading = false;
      });
    }
  }

  Future<void> fetchMyTeamsbyTournamentId(int tId) async {
    try {
      final List<Map<String, dynamic>> myteam =
          await teamapiService.getMyTeamByTourId(tId);
      setState(() {
        enrolledTeams = myteam; // Store the fetched data
      });
      // print("Response of teams by id : $myteam");
    } catch (e) {
      print("Error fetching myteam: $e");
    }
  }

  // ************ IMPLEMENT DELETING GROUP API ************* //
  Future<void> deleteGroup(int groupId) async {
    setState(() {
      _isLoading = true;
    });
    print("Id--$groupId");
    await groupApi.deleteGroup(groupId).then(
          (value) => fetchGroups(),
        );
    setState(() {
      _isLoading = false;
    });
  }

  void _showGroupInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter number of groups"),
          content: TextField(
            controller: _groupController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Number of groups"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("OK"),
              onPressed: () async {
                Navigator.pop(context);
                int newGroupsCount = int.tryParse(_groupController.text) ?? 0;

                // Get the highest letter currently used in the existing groups
                int highestLetterCode = groups.isNotEmpty
                    ? groups
                        .map((e) => e.codeUnitAt(e.length - 1))
                        .reduce((a, b) => a > b ? a : b)
                    : 64; // 64 is the code for 'A' - 1

                // Generate new group names starting from the next letter
                List<String> groupNames = List.generate(
                    newGroupsCount,
                    (i) =>
                        'Group${String.fromCharCode(highestLetterCode + 1 + i)}');

                await createGroups(groupNames);
              },
            ),
          ],
        );
      },
    );
    // Manual group creation using new API
    Future<void> createManualGroup(String groupName) async {
      setState(() {
        _isLoading = true;
      });
      try {
        await groupApi.createManualGroup(widget.tournament['id'], groupName);
        await fetchGroups();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create group: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Show dialog to edit group name
  void _showEditGroupDialog(int groupId, String oldName) {
    final TextEditingController editController =
        TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Group Name'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(hintText: 'Enter new group name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              String newName = editController.text.trim();
              if (newName.isEmpty || newName == oldName) {
                Navigator.pop(context);
                return;
              }
              Navigator.pop(context);
              await _editGroupName(groupId, newName);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Call API to update group name
  Future<void> _editGroupName(int groupId, String newName) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await groupApi.editGroupName(groupId, newName);
      await fetchGroups();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group name updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update group name: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _createGroupButton(String groupName) {
    final group = groupsData.firstWhere(
      (group) => group['group_name'] == groupName,
      orElse: () => {},
    );
    final groupId = group['id'];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentGroup = groupName;
                _fetchAllTeamsByGroups(groupName);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentGroup == groupName
                  ? const Color(0xFF264653)
                  : Colors.grey[300],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                groupName,
                style: TextStyle(
                  color:
                      _currentGroup == groupName ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          // Edit group name button
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            tooltip: 'Edit Group Name',
            onPressed: () {
              _showEditGroupDialog(groupId, groupName);
            },
          ),
          // Delete group button
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              // Find the group ID for the selected group name
              final group = groupsData.firstWhere(
                (group) => group['group_name'] == groupName,
                orElse: () => {},
              );
              final groupId = group['id'];

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Delete Group: $groupName"),
                  content: const Text(
                    "Are you sure you want to delete this group?",
                    style: TextStyle(color: Colors.black),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _deleteGroup(groupId, groupName);
                      },
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupButtons() {
    return groupsData
        .map((group) => _createGroupButton(group['group_name']))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : groups.isEmpty
              ? Column(
                  children: [
                    if (_numberOfGroups == 0) ...[
                      Center(child: _createGrWidget()),
                    ] else ...[
                      Column(
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: _buildGroupButtons(),
                            ),
                          ),
                          const SizedBox(height: 30),
                          _isTeamLoading
                              ? const CircularProgressIndicator()
                              : _groupWidgetWithTeams(grName: _currentGroup),
                        ],
                      ),
                    ],
                  ],
                )
              : Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildGroupButtons(),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _groupWidgetWithTeams(grName: _currentGroup),
                  ],
                ),
      floatingActionButton: groupsData.isEmpty
          ? Container()
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Manual group creation button (new)
                SizedBox(
                  height: 40,
                  width: 130,
                  child: FloatingActionButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.deepOrange,
                    onPressed: _showManualGroupDialog,
                    child: const Text("Add Category Manually",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),

                // Auto group creation button (existing)
                SizedBox(
                  height: 40,
                  width: 130,
                  child: FloatingActionButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor: const Color(0xFF264653),
                    onPressed: _showGroupInputDialog,
                    child: const Text("Add More Category",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  height: 40,
                  width: 130,
                  child: FloatingActionButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor: const Color(0xFF264653),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScheduleMatchByTur(
                            tourId: widget.tournament['id'],
                            groupName:
                                _currentGroup.isNotEmpty ? _currentGroup : null,
                          ),
                        ),
                      );
                    },
                    child: const Text("Schedule Match",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
    );
  }

// Manual group creation dialog and logic
  void _showManualGroupDialog() {
    TextEditingController manualGroupController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Group Name"),
          content: TextField(
            controller: manualGroupController,
            decoration: const InputDecoration(hintText: "Group Name"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Add"),
              onPressed: () async {
                String groupName = manualGroupController.text.trim();
                if (groupName.isNotEmpty) {
                  Navigator.pop(context);
                  await createManualGroup(groupName);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> createManualGroup(String groupName) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await groupApi.createManualGroup(widget.tournament['id'], groupName);
      await fetchGroups();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create group: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _createGrWidget() {
    return Center(
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 80,
        child: InkWell(
          onTap: _showGroupInputDialog,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.groups, size: 30, color: Colors.black),
              Text(
                "Create a Group",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _groupWidgetWithTeams({required String grName}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_groupTeams.containsKey(grName))
            _isTeamLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: _groupTeams[grName]!
                        .map((team) => ListTile(
                              leading: const CircleAvatar(),
                              title: Text(
                                team['team_name'] ?? '',
                                style: GoogleFonts.getFont('Poppins',
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  print('grou team $_groupTeams');
                                  print(" enrolledTeam--$enrolledTeams");
                                  print('team name $team');
                                  // Find the team ID for the selected team name
                                  final enrolledteamId = team['team_id'];
                                  // enrolledTeams.firstWhere(
                                  //   (enrolledTeam) =>
                                  //       enrolledTeam['team_name'] ==
                                  //       team['team_name'],
                                  //   orElse: () => {},
                                  // )['id'];
                                  print("Teamid--$enrolledteamId");
                                  // Confirmation dialog before deleting
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(
                                          "Delete Team: ${team['team_name']}"),
                                      content: const Text(
                                        "Are you sure you want to delete this team from the group?",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            await deleteTeam(enrolledteamId,
                                                team['team_name'], grName);
                                          },
                                          child: const Text("Delete"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Schedule Match Button for this group
              FloatingActionButton(
                backgroundColor: Colors.green,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScheduleMatchByTur(
                        tourId: widget.tournament['id'],
                        groupName: grName,
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.schedule, color: Colors.white),
              ),
              const SizedBox(width: 10),
              // Add Team Button
              FloatingActionButton(
                backgroundColor: const Color(0xFF264653),
                onPressed: () {
                  _addTeamToGroup(grName);
                },
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addTeamToGroup(String groupName) {
    // Create a set of all teams already added to any group
    Set<String> addedTeams = {};
    _groupTeams.forEach((group, teams) {
      addedTeams.addAll(teams.map((team) => team['team_name'] as String));
    });

    // Filter the enrolledTeams to exclude those already added to any group
    List<Map<String, dynamic>> availableTeams = enrolledTeams.where((team) {
      return !addedTeams.contains(team['team_name']);
    }).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Check if availableTeams is null or empty
        if (availableTeams.isEmpty) {
          return AlertDialog(
            title: const Text("No teams available"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          );
        }

        return AlertDialog(
          title: const Text("Select Team"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: availableTeams.map<Widget>((team) {
                return ListTile(
                  title: Text(
                    team['team_name'] ?? '',
                    style: const TextStyle(color: Colors.black),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    if (!_groupTeams[groupName]!.contains(team['team_name'])) {
                      await addTeamsToGroup(team['team_id'], groupName);
                      setState(() {
                        // Append the new team to the existing list of teams for the group
                        _groupTeams[groupName]?.add(team['team_name'] ?? '');
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        // Display message at top of screen
                        SnackBar(
                          content: Text(
                              "Team ${team['team_name']} is already added to $groupName"),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.only(
                              top: 20.0), // Position from the top
                        ),
                      );
                    }
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> deleteTeam(
      int entityId, String teamName, String groupName) async {
    try {
      await groupApi.deleteTeamFormGroup(entityId);
      // After deletion, refresh the teams for this group from backend
      await _fetchAllTeamsByGroups(groupName);
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to delete Team: $e'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _deleteGroup(int groupId, String groupName) async {
    try {
      await groupApi.deleteGroup(groupId);
      setState(() {
        // Remove the group from the list based on the name
        groups.remove(groupName);
        _groupTeams.remove(groupName);

        // If the deleted group was the current group, reset _currentGroup
        if (_currentGroup == groupName || _currentGroup != groupName) {
          if (_currentGroup.isNotEmpty) {
            _fetchAllTeamsByGroups(_currentGroup);
            fetchGroups();
          }
        }
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to delete Group: $e',
                style: const TextStyle(color: Colors.black)),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
