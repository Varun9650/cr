import 'package:flutter/material.dart';
import '../../practiceRepository/PracticeMatchService.dart';
import 'dart:async';

class BadmintonScoreboardScreen extends StatefulWidget {
  final int matchId;

  const BadmintonScoreboardScreen({
    Key? key,
    required this.matchId,
  }) : super(key: key);

  @override
  State<BadmintonScoreboardScreen> createState() =>
      _BadmintonScoreboardScreenState();
}

class _BadmintonScoreboardScreenState extends State<BadmintonScoreboardScreen>
    with WidgetsBindingObserver {
  // Best of 3 sets
  static const int setsToWin = 2;
  static const int pointsToWinSet = 21;
  static const int maxPoints = 30;

  List<int> team1Points = [0, 0, 0];
  List<int> team2Points = [0, 0, 0];
  int currentSet = 0;
  int team1Sets = 0;
  int team2Sets = 0;
  bool matchOver = false;
  String? winner;
  List<_ScoreAction> history = [];
  Map<String, int> playerPoints = {}; // player name -> points
  List<_PlayerScoreAction> playerHistory = [];
  final PracticeMatchService _service = PracticeMatchService();
  bool _isSaving = false;
  String matchType = '';
  String? player1;
  String? player2;
  String? team1Name;
  String? team2Name;
  String? team1Player1;
  String? team1Player2;
  String? team2Player1;
  String? team2Player2;
  bool _isLoading = true;

  // New features
  bool isTeam1Serving = true; // Serve indicator
  Timer? _matchTimer;
  int _matchDuration = 0; // in seconds
  bool _isTimerRunning = false;
  int _currentGameTime = 0; // current game time
  bool _showIntervalNotification = false;
  String _lastAction = ''; // Track last action for undo
  int _lastActionTeam = 0;
  String _lastActionPlayer = '';
  bool _lastActionWasFault = false;
  bool _lastActionWasLet = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchMatchData();
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _matchTimer?.cancel();
    // Save data to backend before disposing without setState
    if (mounted) {
      _saveScoreToBackendSilent();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App is going to background, save data
      if (mounted) {
        _saveScoreToBackendSilent();
      }
    }
  }

  Future<void> _fetchMatchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _service.getlatestrecordBadminton(widget.matchId);
      print('Received data: $data'); // Debug print
      if (data == null) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No match data found.'),
              backgroundColor: Colors.red),
        );
        return;
      }
      // Map backend fields to local state (adjust keys as per backend response)
      setState(() {
        matchType = data['matchType'] ?? '';
        player1 = data['player1'];
        player2 = data['player2'];
        team1Name = data['team1Name'] ?? data['team1_name'] ?? 'Team 1';
        team2Name = data['team2Name'] ?? data['team2_name'] ?? 'Team 2';
        team1Player1 = data['team1Player1'];
        team1Player2 = data['team1Player2'];
        team2Player1 = data['team2Player1'];
        team2Player2 = data['team2Player2'];
        // Points and sets - handle both string and array formats
        print('team1Points type: ${data['team1Points'].runtimeType}');
        print('team1Points value: ${data['team1Points']}');
        if (data['team1Points'] != null) {
          if (data['team1Points'] is String) {
            // Parse comma-separated string
            List<String> pointsStr = data['team1Points'].split(',');
            team1Points =
                pointsStr.map((e) => int.tryParse(e.trim()) ?? 0).toList();
            // Ensure we have 3 elements
            while (team1Points.length < 3) {
              team1Points.add(0);
            }
            if (team1Points.length > 3) {
              team1Points = team1Points.take(3).toList();
            }
          } else {
            team1Points = List<int>.from(data['team1Points']);
          }
        } else {
          team1Points = [0, 0, 0];
        }

        print('team2Points type: ${data['team2Points'].runtimeType}');
        print('team2Points value: ${data['team2Points']}');
        if (data['team2Points'] != null) {
          if (data['team2Points'] is String) {
            // Parse comma-separated string
            List<String> pointsStr = data['team2Points'].split(',');
            team2Points =
                pointsStr.map((e) => int.tryParse(e.trim()) ?? 0).toList();
            // Ensure we have 3 elements
            while (team2Points.length < 3) {
              team2Points.add(0);
            }
            if (team2Points.length > 3) {
              team2Points = team2Points.take(3).toList();
            }
          } else {
            team2Points = List<int>.from(data['team2Points']);
          }
        } else {
          team2Points = [0, 0, 0];
        }
        currentSet = data['currentSet'] ?? 0;
        team1Sets = data['team1Sets'] ?? 0;
        team2Sets = data['team2Sets'] ?? 0;
        matchOver = data['matchOver'] ?? false;

        // Handle winner - convert winnerTeam number to team name
        int? winnerTeam = data['winnerTeam'];
        if (matchOver && winnerTeam != null) {
          if (winnerTeam == 1) {
            winner = team1Display;
          } else if (winnerTeam == 2) {
            winner = team2Display;
          }
        } else {
          winner = data['winner']; // Fallback to direct winner field if exists
        }
        // Player points - handle both string and map formats
        print('playerPoints from backend: ${data['playerPoints']}');
        print('playerPoints type: ${data['playerPoints']?.runtimeType}');
        if (data['playerPoints'] != null) {
          if (data['playerPoints'] is String) {
            // Parse toString() format like "{kkk: 6, kkk8: 3, kkk0: 3, jjj9: 5}"
            String playerPointsStr = data['playerPoints'];
            playerPoints = {};

            // Remove curly braces and split by comma
            if (playerPointsStr.startsWith('{') &&
                playerPointsStr.endsWith('}')) {
              playerPointsStr =
                  playerPointsStr.substring(1, playerPointsStr.length - 1);
              List<String> entries = playerPointsStr.split(',');

              for (String entry in entries) {
                entry = entry.trim();
                if (entry.contains(':')) {
                  List<String> parts = entry.split(':');
                  if (parts.length == 2) {
                    String playerName = parts[0].trim();
                    int points = int.tryParse(parts[1].trim()) ?? 0;
                    playerPoints[playerName] = points;
                    print('Parsed player: $playerName with points: $points');
                  }
                }
              }
            }
          } else if (data['playerPoints'] is Map) {
            playerPoints = Map<String, int>.from(data['playerPoints']);
            print('Loaded playerPoints from map: $playerPoints');
          } else {
            // If it's not a map, initialize empty
            playerPoints = {};
            print('playerPoints is not string or map, initializing empty');
          }
        } else {
          // Initialize player points based on current match state
          playerPoints = {};
          print('playerPoints is null, initializing based on match state');
          if (matchType.endsWith('Singles')) {
            if (player1 != null) playerPoints[player1!] = 0;
            if (player2 != null) playerPoints[player2!] = 0;
          } else {
            if (team1Player1 != null) playerPoints[team1Player1!] = 0;
            if (team1Player2 != null) playerPoints[team1Player2!] = 0;
            if (team2Player1 != null) playerPoints[team2Player1!] = 0;
            if (team2Player2 != null) playerPoints[team2Player2!] = 0;
          }
        }
        print('Final playerPoints: $playerPoints');
        _isLoading = false;
      });
    } catch (e) {
      print('error in fetching match data: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to load match data: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  String get team1Display {
    if (matchType.endsWith('Singles')) {
      return (team1Name ?? 'Team 1') + ' (${player1 ?? ''})';
    } else {
      return (team1Name ?? 'Team 1') +
          ' (${team1Player1 ?? ''}, ${team1Player2 ?? ''})';
    }
  }

  String get team2Display {
    if (matchType.endsWith('Singles')) {
      return (team2Name ?? 'Team 2') + ' (${player2 ?? ''})';
    } else {
      return (team2Name ?? 'Team 2') +
          ' (${team2Player1 ?? ''}, ${team2Player2 ?? ''})';
    }
  }

  void addPoint(int team) {
    if (matchOver) return;
    setState(() {
      if (team == 1) {
        team1Points[currentSet]++;
        history.add(_ScoreAction(team: 1, set: currentSet, action: 'point'));
      } else {
        team2Points[currentSet]++;
        history.add(_ScoreAction(team: 2, set: currentSet, action: 'point'));
      }
      _lastAction = 'point';
      _lastActionTeam = team;
      _lastActionWasFault = false;
      _lastActionWasLet = false;
      checkSetOrMatchWin();
    });
  }

  void addFault(int team) {
    if (matchOver) return;
    setState(() {
      if (team == 1) {
        team2Points[currentSet]++; // Opponent gets point
        history.add(_ScoreAction(team: 1, set: currentSet, action: 'fault'));
      } else {
        team1Points[currentSet]++; // Opponent gets point
        history.add(_ScoreAction(team: 2, set: currentSet, action: 'fault'));
      }
      _lastAction = 'fault';
      _lastActionTeam = team;
      _lastActionWasFault = true;
      _lastActionWasLet = false;
      checkSetOrMatchWin();
    });
  }

  void addLet() {
    if (matchOver) return;
    setState(() {
      // Let doesn't change score, just record it
      history.add(_ScoreAction(team: 0, set: currentSet, action: 'let'));
      _lastAction = 'let';
      _lastActionTeam = 0;
      _lastActionWasFault = false;
      _lastActionWasLet = true;
    });
  }

  void changeSides() {
    setState(() {
      // Toggle serve indicator
      isTeam1Serving = !isTeam1Serving;
      // Reset game time for new game
      _currentGameTime = 0;
    });
  }

  Future<void> _saveScoreToBackend() async {
    setState(() {
      _isSaving = true;
    });
    try {
      int winnerTeam = 0;
      if (matchOver) {
        if (team1Sets > team2Sets) {
          winnerTeam = 1;
        } else if (team2Sets > team1Sets) {
          winnerTeam = 2;
        }
      }
      Map<String, dynamic> payload = {
        'id': widget.matchId,
        'match_id': widget.matchId,
        'gameNumber': currentSet, // 0-based set number
        'matchType': matchType,
        'player1': player1,
        'player2': player2,
        'team1Name': team1Name,
        'team2Name': team2Name,
        'team1Player1': team1Player1,
        'team1Player2': team1Player2,
        'team2Player1': team2Player1,
        'team2Player2': team2Player2,
        'team1Points': team1Points.map((e) => e.toString()).join(','),
        'team2Points': team2Points.map((e) => e.toString()).join(','),
        'playerPoints': playerPoints.toString(),

        // 'playerPoints':
        //     playerPoints.entries.map((e) => '${e.key}:${e.value}').join(','),
        'currentSet': currentSet,
        'team1Sets': team1Sets,
        'team2Sets': team2Sets,
        'matchOver': matchOver,
        'completed': matchOver,
        'winnerTeam': winnerTeam,
        'preferred_sport': 'Badminton',
      };
      print('payload: $payload');
      await _service.updatePoint(widget.matchId, payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Score saved to backend!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to save score: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // Silent save without setState for dispose and lifecycle events
  Future<void> _saveScoreToBackendSilent() async {
    try {
      int winnerTeam = 0;
      if (matchOver) {
        if (team1Sets > team2Sets) {
          winnerTeam = 1;
        } else if (team2Sets > team1Sets) {
          winnerTeam = 2;
        }
      }
      Map<String, dynamic> payload = {
        'id': widget.matchId,
        'match_id': widget.matchId,
        'gameNumber': currentSet, // 0-based set number
        'matchType': matchType,
        'player1': player1,
        'player2': player2,
        'team1Name': team1Name,
        'team2Name': team2Name,
        'team1Player1': team1Player1,
        'team1Player2': team1Player2,
        'team2Player1': team2Player1,
        'team2Player2': team2Player2,
        'team1Points': team1Points.map((e) => e.toString()).join(','),
        'team2Points': team2Points.map((e) => e.toString()).join(','),
        'playerPoints': playerPoints.toString(),
        'currentSet': currentSet,
        'team1Sets': team1Sets,
        'team2Sets': team2Sets,
        'matchOver': matchOver,
        'completed': matchOver,
        'winnerTeam': winnerTeam,
        'preferred_sport': 'Badminton',
      };
      print('siltent payload: $payload');
      await _service.updatePoint(widget.matchId, payload);
    } catch (e) {
      print('Silent save failed: $e');
    }
  }

  // Call _saveScore To Backend after every point addition
  void addPlayerPoint(String player, int team) {
    if (matchOver) return;
    setState(() {
      playerPoints[player] = (playerPoints[player] ?? 0) + 1;
      if (team == 1) {
        team1Points[currentSet]++;
      } else {
        team2Points[currentSet]++;
      }
      playerHistory
          .add(_PlayerScoreAction(player: player, team: team, set: currentSet));
      history.add(_ScoreAction(team: team, set: currentSet, action: 'point'));
      checkSetOrMatchWin();
    });
    // _saveScoreToBackend();
  }

  void undo() {
    if (history.isEmpty || matchOver) return;
    setState(() {
      final last = history.removeLast();
      // Undo player-wise point if available
      if (playerHistory.isNotEmpty) {
        final lastPlayer = playerHistory.removeLast();
        if (playerPoints.containsKey(lastPlayer.player) &&
            playerPoints[lastPlayer.player]! > 0) {
          playerPoints[lastPlayer.player] =
              playerPoints[lastPlayer.player]! - 1;
        }
      }
      if (last.action == 'fault') {
        // Undo fault - opponent loses point
        if (last.team == 1 && team2Points[last.set] > 0) {
          team2Points[last.set]--;
        } else if (last.team == 2 && team1Points[last.set] > 0) {
          team1Points[last.set]--;
        }
      } else if (last.action == 'point') {
        // Undo point
        if (last.team == 1 && team1Points[last.set] > 0) {
          team1Points[last.set]--;
        } else if (last.team == 2 && team2Points[last.set] > 0) {
          team2Points[last.set]--;
        }
      }
      // Let doesn't need undo as it doesn't change score
      if (matchOver) {
        matchOver = false;
        winner = null;
      }
    });
  }

  void _startTimer() {
    _isTimerRunning = true;
    _matchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _isTimerRunning && !matchOver) {
        setState(() {
          _matchDuration++;
          _currentGameTime++;

          // Check for interval notifications (every 5 minutes)
          if (_currentGameTime % 300 == 0) {
            _showIntervalNotification = true;
            // Auto-hide after 3 seconds
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _showIntervalNotification = false;
                });
              }
            });
          }
        });
      }
    });
  }

  void _pauseTimer() {
    _isTimerRunning = false;
  }

  void _resumeTimer() {
    _isTimerRunning = true;
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void checkSetOrMatchWin() {
    int t1 = team1Points[currentSet];
    int t2 = team2Points[currentSet];
    bool setOver = false;
    if ((t1 >= pointsToWinSet || t2 >= pointsToWinSet) &&
        (t1 - t2).abs() >= 2) {
      setOver = true;
    }
    if (t1 == maxPoints || t2 == maxPoints) {
      setOver = true;
    }
    if (setOver) {
      if (t1 > t2) {
        team1Sets++;
      } else {
        team2Sets++;
      }
      if (team1Sets == setsToWin || team2Sets == setsToWin) {
        matchOver = true;
        winner = team1Sets == setsToWin ? team1Display : team2Display;
        _pauseTimer(); // Stop timer when match ends
      } else {
        // Next set - automatic game switching
        currentSet++;
        _currentGameTime = 0; // Reset game time for new set
        // Change serve indicator for new set
        isTeam1Serving = !isTeam1Serving;
      }
    }
  }

  void resetMatch() {
    setState(() {
      team1Points = [0, 0, 0];
      team2Points = [0, 0, 0];
      currentSet = 0;
      team1Sets = 0;
      team2Sets = 0;
      matchOver = false;
      winner = null;
      history.clear();
      playerHistory.clear();
      playerPoints.updateAll((key, value) => 0);

      // Reset new features
      isTeam1Serving = true;
      _matchDuration = 0;
      _currentGameTime = 0;
      _showIntervalNotification = false;
      _lastAction = '';
      _lastActionTeam = 0;
      _lastActionPlayer = '';
      _lastActionWasFault = false;
      _lastActionWasLet = false;
    });
    _resumeTimer(); // Resume timer after reset
    // Save reset data to backend
    _saveScoreToBackend();
  }

  Widget _buildScoreBoard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(team1Display,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(
                    child: Text(team2Display,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                        textAlign: TextAlign.right)),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int set = 0; set < 3; set++)
                  Expanded(
                    child: Column(
                      children: [
                        Text('Set ${set + 1}',
                            style: const TextStyle(fontSize: 10)),
                        Text(
                          '${team1Points[set]} - ${team2Points[set]}',
                          style: TextStyle(
                            fontSize: set == currentSet ? 18 : 14,
                            fontWeight: set == currentSet
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color:
                                set == currentSet ? Colors.blue : Colors.black,
                          ),
                        ),
                        if (team1Points[set] >= 21 ||
                            team2Points[set] >= 21) // Set complete condition
                          Center(
                            child: Text(
                              team1Points[set] > team2Points[set]
                                  ? '${team1Name ?? 'Team 1'} Won'
                                  : team2Points[set] > team1Points[set]
                                      ? '${team2Name ?? 'Team 2'} Won'
                                      : '',
                              style: const TextStyle(
                                  color: Colors.green, fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          const SizedBox(height: 16), // For alignment
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sets Won: $team1Sets',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(width: 16),
                Text('Sets Won: $team2Sets',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerButtons() {
    // Group players by team
    List<String> team1Players;
    List<String> team2Players;
    String team1Header;
    String team2Header;
    if (matchType.endsWith('Singles')) {
      team1Players = [player1 ?? 'Player 1'];
      team2Players = [player2 ?? 'Player 2'];
      team1Header = team1Name ?? 'Team 1';
      team2Header = team2Name ?? 'Team 2';
    } else {
      team1Players = [];
      if (team1Player1 != null && team1Player1!.isNotEmpty) {
        team1Players.add(team1Player1!);
      }
      if (team1Player2 != null && team1Player2!.isNotEmpty) {
        team1Players.add(team1Player2!);
      }
      team2Players = [];
      if (team2Player1 != null && team2Player1!.isNotEmpty) {
        team2Players.add(team2Player1!);
      }
      if (team2Player2 != null && team2Player2!.isNotEmpty) {
        team2Players.add(team2Player2!);
      }
      team1Header = team1Name ?? 'Team 1';
      team2Header = team2Name ?? 'Team 2';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 2),
          child: Text(team1Header,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.blue)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: team1Players
              .map((p) => _buildPlayerScoreButton(p, 1, Colors.blue))
              .toList(),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 2),
          child: Text(team2Header,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.red)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: team2Players
              .map((p) => _buildPlayerScoreButton(p, 2, Colors.red))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPlayerScoreButton(String player, int team, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: SizedBox(
          height: 40, // Reduced height
          child: ElevatedButton(
            onPressed: () => addPlayerPoint(player, team),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(vertical: 8), // Reduced padding
              textStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold), // Smaller font
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)), // Smaller radius
            ),
            child: Text('Add Point\n$player',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10)), // Smaller text
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerStats() {
    // Group players by team
    List<String> team1Players;
    List<String> team2Players;
    String team1Header;
    String team2Header;
    if (matchType.endsWith('Singles')) {
      team1Players = [player1 ?? 'Player 1'];
      team2Players = [player2 ?? 'Player 2'];
      team1Header = team1Name ?? 'Team 1';
      team2Header = team2Name ?? 'Team 2';
    } else {
      team1Players = [];
      if (team1Player1 != null && team1Player1!.isNotEmpty) {
        team1Players.add(team1Player1!);
      }
      if (team1Player2 != null && team1Player2!.isNotEmpty) {
        team1Players.add(team1Player2!);
      }
      team2Players = [];
      if (team2Player1 != null && team2Player1!.isNotEmpty) {
        team2Players.add(team2Player1!);
      }
      if (team2Player2 != null && team2Player2!.isNotEmpty) {
        team2Players.add(team2Player2!);
      }
      team1Header = team1Name ?? 'Team 1';
      team2Header = team2Name ?? 'Team 2';
    }
    List<Widget> stats = [];
    stats.add(Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Text(team1Header,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
    ));
    stats.addAll(team1Players.map((p) => Card(
          color: Colors.grey[50],
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(p,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 10)),
                Text('Points: ${playerPoints[p] ?? 0}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: 10)),
              ],
            ),
          ),
        )));
    stats.add(Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: Text(team2Header,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red)),
    ));
    stats.addAll(team2Players.map((p) => Card(
          color: Colors.grey[50],
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(p,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 10)),
                Text('Points: ${playerPoints[p] ?? 0}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 10)),
              ],
            ),
          ),
        )));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),
        const Text('Player-wise Points',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black87)),
        ...stats,
      ],
    );
  }

  Widget _buildActionButtons() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Quick Actions',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40, // 25% smaller than default
                    child: ElevatedButton.icon(
                      onPressed: () => addFault(1),
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text('Team 1\nFault',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: SizedBox(
                    height: 40, // 25% smaller than default
                    child: ElevatedButton.icon(
                      onPressed: addLet,
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text('Let',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: SizedBox(
                    height: 40, // 25% smaller than default
                    child: ElevatedButton.icon(
                      onPressed: () => addFault(2),
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text('Team 2\nFault',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40, // 25% smaller than default
              child: ElevatedButton.icon(
                onPressed: changeSides,
                icon: const Icon(Icons.swap_horiz, color: Colors.white),
                label: const Text('Change Sides',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Badminton Scoreboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetMatch,
            tooltip: 'Reset Match',
          ),
          IconButton(
            icon: _isSaving
                ? const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2)
                : const Icon(Icons.cloud_upload),
            onPressed: _isSaving ? null : _saveScoreToBackend,
            tooltip: 'Save to Backend',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.grey[100],
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.confirmation_number,
                                color: Colors.blue, size: 20),
                            const SizedBox(width: 6),
                            Text('Match ID: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            Text('${widget.matchId}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.sports_tennis,
                                color: Colors.deepPurple, size: 20),
                            const SizedBox(width: 6),
                            Text('Type: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            Text('${matchType}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const Text('Match Time',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.black)),
                            Text(_formatTime(_matchDuration),
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Game Time',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.black)),
                            Text(_formatTime(_currentGameTime),
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Serve',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey)),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    isTeam1Serving ? Colors.blue : Colors.red,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                isTeam1Serving ? 'Team 1' : 'Team 2',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (_showIntervalNotification)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '5-minute interval reached!',
                          style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 10),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            _buildScoreBoard(),
            const SizedBox(height: 4),
            _buildActionButtons(),
            const SizedBox(height: 4),
            if (!matchOver) _buildPlayerButtons(),
            _buildPlayerStats(),
            if (matchOver) ...[
              Center(
                child: Text(
                  'Winner: $winner',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ),
            ],
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 2.0, top: 2.0),
              child: ElevatedButton.icon(
                onPressed: undo,
                icon: const Icon(Icons.undo, size: 18),
                label: const Text('Undo', style: TextStyle(fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreAction {
  final int team;
  final int set;
  final String action;
  _ScoreAction({required this.team, required this.set, this.action = ''});
}

class _PlayerScoreAction {
  final String player;
  final int team;
  final int set;
  _PlayerScoreAction(
      {required this.player, required this.team, required this.set});
}
