// Production-Level Tournament Badminton Scoreboard
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../viewmodel/tournament_badminton_view_model.dart';
import 'tournament_badminton_scorecard_screen.dart';

class TournamentBadmintonScoreboardScreen extends StatefulWidget {
  final int matchId;

  const TournamentBadmintonScoreboardScreen({
    Key? key,
    required this.matchId,
  }) : super(key: key);

  @override
  State<TournamentBadmintonScoreboardScreen> createState() =>
      _TournamentBadmintonScoreboardScreenState();
}

class _TournamentBadmintonScoreboardScreenState
    extends State<TournamentBadmintonScoreboardScreen>
    with WidgetsBindingObserver {
  Timer? _autoSaveTimer;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    print(
        'Initializing Tournament Badminton Scoreboard for Match ID: ${widget.matchId}');

    // Start periodic auto-save (every 30 seconds) only when screen is active
    _startAutoSaveTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize match data through ViewModel - only once
    if (!_isInitialized) {
      final provider =
          Provider.of<TournamentBadmintonViewModel>(context, listen: false);
      provider.initializeMatch(widget.matchId);
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _stopAutoSaveTimer(); // Properly stop and clean up timer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Only handle lifecycle if this screen is still mounted and active
    if (!mounted) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      // App is going to background or being closed, save data silently and stop timer
      _autoSaveData();
      _stopAutoSaveTimer(); // Stop timer when app goes to background
      print('App going to background - Timer stopped and data saved');
    } else if (state == AppLifecycleState.resumed) {
      // App is coming back to foreground, restart timer only if still on this screen
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        _startAutoSaveTimer();
        print('App resumed - Timer restarted');
      } else {
        print('App resumed but not on current screen - Timer not restarted');
      }
    }
  }

  // Start auto-save timer
  void _startAutoSaveTimer() {
    _stopAutoSaveTimer(); // Stop any existing timer first

    // Only start timer if screen is mounted and active
    if (!mounted) {
      print('Timer not started - Screen not mounted');
      return;
    }

    // Check if route is current after a frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
          // Check if screen is still active before auto-saving
          if (mounted && ModalRoute.of(context)?.isCurrent == true) {
            _autoSaveData();
          } else {
            print('Timer callback - Screen not active, stopping timer');
            _stopAutoSaveTimer();
          }
        });
        print('Auto-save timer started');
      } else {
        print('Timer not started - Screen not active');
      }
    });
  }

  // Stop auto-save timer
  void _stopAutoSaveTimer() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  // Auto-save method
  void _autoSaveData() {
    // Only auto-save if screen is mounted and active
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) {
      print('Auto-save skipped - Screen not active');
      return;
    }

    try {
      final provider =
          Provider.of<TournamentBadmintonViewModel>(context, listen: false);
      provider.saveMatchHistory();
      print('Auto-save completed successfully');
    } catch (e) {
      print('Auto-save failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TournamentBadmintonViewModel>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: const Color(0xFF1A1A1A),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    'Loading Match Data...',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          appBar: _buildAppBar(provider),
          body: _buildBody(provider),
        );
      },
    );
  }

  Widget _buildAppBarTimerStatus(TournamentBadmintonViewModel provider) {
    Color statusColor;
    String statusText;

    if (provider.isPaused) {
      statusColor = Colors.orange;
      statusText = 'PAUSED';
    } else if (provider.isTimerRunning) {
      statusColor = Colors.green;
      statusText = 'RUNNING';
    } else {
      statusColor = Colors.grey;
      statusText = 'STOPPED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.5), width: 1),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(TournamentBadmintonViewModel provider) {
    return AppBar(
      backgroundColor: const Color(0xFF264653),
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tournament Badminton',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            'ID: ${widget.matchId} | ${provider.matchData?.matchType ?? "Unknown"}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey[300],
            ),
          ),
          _buildAppBarTimerStatus(provider),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          _autoSaveData();
          Navigator.pop(context);
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.undo, color: Colors.white),
          onPressed: provider.history.isEmpty ? null : () => _undo(provider),
          tooltip: 'Undo Last Action',
        ),
        IconButton(
          icon: provider.isPaused
              ? const Icon(Icons.play_arrow, color: Colors.white)
              : const Icon(Icons.pause, color: Colors.white),
          onPressed: provider.matchOver
              ? null
              : () => provider.isPaused
                  ? _resumeMatch(provider)
                  : _pauseMatch(provider),
          tooltip: provider.isPaused ? 'Start Match' : 'Pause Match',
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => _showResetDialog(provider),
          tooltip: 'Reset Match',
        ),
        IconButton(
          icon: provider.isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.cloud_upload, color: Colors.white),
          onPressed: provider.isSaving ? null : () => _saveScore(provider),
          tooltip: 'Save to Backend',
        ),
        IconButton(
          icon: const Icon(Icons.assessment, color: Colors.white),
          onPressed: () => _navigateToScorecard(),
          tooltip: 'View Scorecard',
        ),
      ],
    );
  }

  Widget _buildBody(TournamentBadmintonViewModel provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMatchInfoCard(provider),
          const SizedBox(height: 12),
          _buildScoreboardCard(provider),
          const SizedBox(height: 12),
          _buildActionButtonsCard(provider),
          const SizedBox(height: 12),
          if (!provider.matchOver) _buildPlayerButtonsCard(provider),
          const SizedBox(height: 12),
          if (provider.matchOver) ...[
            _buildPlayerStatsCard(provider),
            const SizedBox(height: 12),
            _buildWinnerCard(provider),
          ],
        ],
      ),
    );
  }

  Widget _buildMatchInfoCard(TournamentBadmintonViewModel provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimeColumn('Match Time',
                    _formatTime(provider.matchDuration), Colors.blue),
                _buildTimeColumn('Game Time',
                    _formatTime(provider.currentGameTime), Colors.green),
                _buildServeIndicator(provider),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn(String label, String time, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[300],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildServeIndicator(TournamentBadmintonViewModel provider) {
    return Column(
      children: [
        Text(
          'Serving',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[300],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: provider.isTeam1Serving
                  ? [Colors.blue, Colors.blue.shade700]
                  : [Colors.red, Colors.red.shade700],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (provider.isTeam1Serving ? Colors.blue : Colors.red)
                    .withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            provider.isTeam1Serving ? 'Team 1' : 'Team 2',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerStatusCard(TournamentBadmintonViewModel provider) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (provider.isPaused) {
      statusColor = Colors.orange;
      statusIcon = Icons.pause_circle_filled;
      statusText = 'MATCH PAUSED - CLICK START TO BEGIN';
    } else if (provider.isTimerRunning) {
      statusColor = Colors.green;
      statusIcon = Icons.play_circle_filled;
      statusText = 'RUNNING';
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.stop_circle;
      statusText = 'STOPPED';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(
            'Timer: $statusText',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreboardCard(TournamentBadmintonViewModel provider) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    provider.team1Display,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue[300],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    provider.team2Display,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red[300],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.grey, height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int set = 0; set < 3; set++)
                  Expanded(
                    child: _buildSetScore(provider, set),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSetsWon(provider.team1Sets, Colors.blue[300]!),
                _buildSetsWon(provider.team2Sets, Colors.red[300]!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetScore(TournamentBadmintonViewModel provider, int set) {
    final isCurrentSet = set == provider.currentSet;
    final team1Score = provider.team1Points[set];
    final team2Score = provider.team2Points[set];
    final isSetComplete = team1Score >= 21 || team2Score >= 21;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentSet ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentSet ? Border.all(color: Colors.blue, width: 2) : null,
      ),
      child: Column(
        children: [
          Text(
            'Set ${set + 1}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isCurrentSet ? Colors.blue[300] : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$team1Score - $team2Score',
            style: GoogleFonts.poppins(
              fontSize: isCurrentSet ? 24 : 20,
              fontWeight: isCurrentSet ? FontWeight.bold : FontWeight.w600,
              color: isCurrentSet ? Colors.white : Colors.grey[300],
            ),
          ),
          if (isSetComplete) ...[
            const SizedBox(height: 4),
            Text(
              team1Score > team2Score
                  ? '${provider.team1Display} Won'
                  : '${provider.team2Display} Won',
              style: GoogleFonts.poppins(
                color: Colors.green[400],
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildSetsWon(int sets, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        'Sets Won: $sets',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: color,
        ),
      ),
    );
  }

  Widget _buildActionButtonsCard(TournamentBadmintonViewModel provider) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Quick Actions',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'T1\nFault',
                    Icons.close,
                    Colors.red,
                    () => _addFault(provider, 1),
                    provider.matchOver || provider.isPaused,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildActionButton(
                    'Let',
                    Icons.refresh,
                    Colors.orange,
                    () => _addLet(provider),
                    provider.matchOver || provider.isPaused,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildActionButton(
                    'T2\nFault',
                    Icons.close,
                    Colors.red,
                    () => _addFault(provider, 2),
                    provider.matchOver || provider.isPaused,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _buildActionButton(
                    'Change\nSides',
                    Icons.swap_horiz,
                    Colors.purple,
                    () => _toggleServe(provider),
                    provider.isPaused,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color,
      VoidCallback onPressed, bool disabled) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: disabled ? null : onPressed,
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildPlayerButtonsCard(TournamentBadmintonViewModel provider) {
    // Debug: Print what we're getting
    // print('=== BUILD PLAYER BUTTONS DEBUG ===');
    // print('MatchData: ${provider.matchData}');
    // print('MatchType: ${provider.matchData?.matchType}');
    // print('Player1: ${provider.matchData?.player1}');
    // print('Player2: ${provider.matchData?.player2}');
    // print('Team1Player1: ${provider.matchData?.team1Player1}');
    // print('Team1Player2: ${provider.matchData?.team1Player2}');
    // print('Team2Player1: ${provider.matchData?.team2Player1}');
    // print('Team2Player2: ${provider.matchData?.team2Player2}');
    // print('==================================');

    // Get player names based on match type
    List<String> team1Players = [];
    List<String> team2Players = [];

    if (provider.matchData?.matchType?.contains('SINGLES') == true ||
        provider.matchData?.matchType?.contains('Singles') == true) {
      team1Players = [provider.matchData?.player1 ?? 'Player 1'];
      team2Players = [provider.matchData?.player2 ?? 'Player 2'];
    } else {
      if (provider.matchData?.team1Player1?.isNotEmpty == true) {
        team1Players.add(provider.matchData!.team1Player1!);
      }
      if (provider.matchData?.team1Player2?.isNotEmpty == true) {
        team1Players.add(provider.matchData!.team1Player2!);
      }
      if (provider.matchData?.team2Player1?.isNotEmpty == true) {
        team2Players.add(provider.matchData!.team2Player1!);
      }
      if (provider.matchData?.team2Player2?.isNotEmpty == true) {
        team2Players.add(provider.matchData!.team2Player2!);
      }
    }

    print('Team1Players: $team1Players');
    print('Team2Players: $team2Players');

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${provider.team1Display} Players',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue[300],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: team1Players
                  .map((player) =>
                      _buildPlayerButton(provider, player, 1, Colors.blue))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text(
              '${provider.team2Display} Players',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.red[300],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: team2Players
                  .map((player) =>
                      _buildPlayerButton(provider, player, 2, Colors.red))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerButton(TournamentBadmintonViewModel provider,
      String playerName, int team, Color color) {
    final playerPoints = provider.playerPoints[playerName] ?? 0;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: (provider.matchOver || provider.isPaused)
                  ? null
                  : () => _addPoint(provider, playerName, team),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      playerName,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$playerPoints pts',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerStatsCard(TournamentBadmintonViewModel provider) {
    // Get all player names based on match type
    List<String> allPlayers = [];

    if (provider.matchData?.matchType?.contains('SINGLES') == true ||
        provider.matchData?.matchType?.contains('Singles') == true) {
      allPlayers = [
        provider.matchData?.player1 ?? 'Player 1',
        provider.matchData?.player2 ?? 'Player 2',
      ];
    } else {
      // Doubles - add all 4 players
      if (provider.matchData?.team1Player1?.isNotEmpty == true) {
        allPlayers.add(provider.matchData!.team1Player1!);
      }
      if (provider.matchData?.team1Player2?.isNotEmpty == true) {
        allPlayers.add(provider.matchData!.team1Player2!);
      }
      if (provider.matchData?.team2Player1?.isNotEmpty == true) {
        allPlayers.add(provider.matchData!.team2Player1!);
      }
      if (provider.matchData?.team2Player2?.isNotEmpty == true) {
        allPlayers.add(provider.matchData!.team2Player2!);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Player Statistics',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ...allPlayers.map((playerName) => _buildPlayerStatRow(
                playerName, provider.playerPoints[playerName] ?? 0)),
            if (allPlayers.isEmpty)
              Text(
                'No player data available',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerStatRow(String playerName, int points) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            playerName,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[300],
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$points points',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue[300],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerCard(TournamentBadmintonViewModel provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Match Complete!',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Winner: ${provider.winner ?? "Unknown"}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _addPoint(
      TournamentBadmintonViewModel provider, String player, int team) {
    provider.updateScore(team, player, 'point');
  }

  void _addFault(TournamentBadmintonViewModel provider, int team) {
    String player = team == 1
        ? (provider.matchData?.player1 ?? 'Player 1')
        : (provider.matchData?.player2 ?? 'Player 2');
    provider.updateScore(team, player, 'fault', isFault: true);
  }

  void _addLet(TournamentBadmintonViewModel provider) {
    int letTeam = provider.isTeam1Serving ? 1 : 2;
    String player = letTeam == 1
        ? (provider.matchData?.player1 ?? 'Player 1')
        : (provider.matchData?.player2 ?? 'Player 2');
    provider.updateScore(letTeam, player, 'let', isLet: true);
  }

  void _undo(TournamentBadmintonViewModel provider) {
    provider.undoLastAction();
  }

  void _toggleServe(TournamentBadmintonViewModel provider) {
    provider.toggleServe();
  }

  void _pauseMatch(TournamentBadmintonViewModel provider) {
    provider.pauseMatch();
    // Auto-save when match is paused
    _autoSaveData();
  }

  void _resumeMatch(TournamentBadmintonViewModel provider) {
    provider.resumeMatch();
  }

  void _navigateToScorecard() {
    // Auto-save before navigating to scorecard
    _autoSaveData();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentBadmintonScorecardScreen(
          matchId: widget.matchId,
        ),
      ),
    );
  }

  void _showResetDialog(TournamentBadmintonViewModel provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C3E50),
        title: Text(
          'Reset Match',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to reset the match? This action cannot be undone.',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[300],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetMatch(provider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Reset',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetMatch(TournamentBadmintonViewModel provider) async {
    try {
      await provider.resetMatch();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Match reset successfully!',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to reset match: $e',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  void _saveScore(TournamentBadmintonViewModel provider) {
    provider.saveMatchHistory();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Score saved successfully!',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
