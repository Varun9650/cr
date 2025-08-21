// Production-Level Tournament Badminton Scorecard
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Added for Timer

import '../viewmodel/tournament_badminton_view_model.dart';

class TournamentBadmintonScorecardScreen extends StatefulWidget {
  final int matchId;

  const TournamentBadmintonScorecardScreen({
    Key? key,
    required this.matchId,
  }) : super(key: key);

  @override
  State<TournamentBadmintonScorecardScreen> createState() =>
      _TournamentBadmintonScorecardScreenState();
}

class _TournamentBadmintonScorecardScreenState
    extends State<TournamentBadmintonScorecardScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Use shared ViewModel listener - no need to load data separately
    // The ViewModel will automatically handle live updates for the same matchId
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureViewModelConnection();
      _startPeriodicRefresh();
    });
  }

  @override
  void dispose() {
    _stopPeriodicRefresh();
    super.dispose();
  }

  // Start periodic refresh to get live updates
  void _startPeriodicRefresh() {
    _stopPeriodicRefresh(); // Stop any existing timer

    // Refresh every 5 seconds to get live updates
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        final provider =
            Provider.of<TournamentBadmintonViewModel>(context, listen: false);
        // Only refresh if we're connected to the right match and it's not completed
        if (provider.matchId == widget.matchId && !provider.matchOver) {
          // Silent background refresh - no UI blocking
          provider.fetchMatchData(widget.matchId).then((_) {
            print('Scorecard: Silent periodic refresh completed');
          }).catchError((error) {
            print('Scorecard: Silent periodic refresh failed: $error');
          });
        }
      }
    });
    print('Scorecard: Started periodic refresh timer (5 seconds)');
  }

  // Stop periodic refresh
  void _stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // Ensure ViewModel is connected to the same match for live updates
  void _ensureViewModelConnection() {
    final provider =
        Provider.of<TournamentBadmintonViewModel>(context, listen: false);

    // Always ensure we have fresh data for the current match
    if (provider.matchId != widget.matchId || provider.matchData == null) {
      print('Scorecard: Connecting ViewModel to match ID: ${widget.matchId}');
      provider.initializeMatch(widget.matchId);
    } else {
      print(
          'Scorecard: ViewModel already connected to match ID: ${widget.matchId}');
      // Even if connected, refresh the data to ensure we have latest
      provider.fetchMatchData(widget.matchId);
    }
  }

  // Force refresh data
  void _forceRefreshData() {
    final provider =
        Provider.of<TournamentBadmintonViewModel>(context, listen: false);
    print('Scorecard: Force refreshing data for match ID: ${widget.matchId}');

    // Show loading indicator without blocking UI
    provider.clearError();

    // Background refresh - don't show loading screen
    provider.fetchMatchData(widget.matchId).then((_) {
      print('Scorecard: Background refresh completed');
    }).catchError((error) {
      print('Scorecard: Background refresh failed: $error');
    });
  }

  // Check if match has started (has any points or actions)
  bool _hasMatchStarted(TournamentBadmintonViewModel provider) {
    // Check if any sets have points or if there are any actions
    bool hasPoints = provider.team1Points.any((points) => points > 0) ||
        provider.team2Points.any((points) => points > 0);
    bool hasActions = provider.history.isNotEmpty;
    bool hasDuration = provider.matchDuration > 0;

    return hasPoints || hasActions || hasDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TournamentBadmintonViewModel>(
      builder: (context, provider, child) {
        // Debug: Print current state
        print(
            'Scorecard: Building with provider.matchId: ${provider.matchId}, widget.matchId: ${widget.matchId}');
        print(
            'Scorecard: Has match data: ${provider.matchData != null}, isLoading: ${provider.isLoading}');

        // Only show loading for initial connection, not for data refreshes
        if (provider.matchId != widget.matchId ||
            (provider.isLoading && provider.matchData == null)) {
          return Scaffold(
            backgroundColor: const Color(0xFF1A1A1A),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    'Connecting to Match...',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Match ID: ${widget.matchId}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getLoadingMessage(provider),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (provider.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Connection Error',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[300],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.errorMessage!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.red[200],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              provider.clearError();
                              _ensureViewModelConnection();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              'Retry Connection',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        // Check if we have match data
        if (provider.matchData == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF1A1A1A),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_tennis,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Match Not Started',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Match ID: ${widget.matchId}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Go Back',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                      ),
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

  // Get appropriate loading message based on match state
  String _getLoadingMessage(TournamentBadmintonViewModel provider) {
    if (provider.matchOver == true) {
      return 'Loading completed match...';
    } else if (_hasMatchStarted(provider)) {
      return 'Getting live updates...';
    } else {
      return 'Loading match details...';
    }
  }

  PreferredSizeWidget _buildAppBar(TournamentBadmintonViewModel provider) {
    return AppBar(
      backgroundColor: const Color(0xFF264653),
      elevation: 0,
      title: Row(
        children: [
          Text(
            'Match Scorecard',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          // Status indicator - Live for ongoing, Completed for finished
          Consumer<TournamentBadmintonViewModel>(
            builder: (context, provider, child) {
              if (provider.matchOver) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.blue.withOpacity(0.5), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 12,
                        color: Colors.blue[300],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'COMPLETED',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[300],
                        ),
                      ),
                    ],
                  ),
                );
              } else if (_hasMatchStarted(provider)) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.green.withOpacity(0.5), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[300],
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // Match not started yet
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.orange.withOpacity(0.5), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: Colors.orange[300],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'NOT STARTED',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[300],
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (provider.isLoading && provider.matchData != null)
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 1.5,
              ),
            ),
          ),
        if (provider.isLoading && provider.matchData != null)
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 1.5,
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: provider.isLoading ? null : _forceRefreshData,
          tooltip: 'Refresh Scorecard',
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
          // Show completion banner for finished matches
          if (provider.matchOver) ...[
            _buildCompletionBanner(provider),
            const SizedBox(height: 16),
          ],
          // Show not started banner for pending matches
          if (!_hasMatchStarted(provider) && !provider.matchOver) ...[
            _buildNotStartedBanner(provider),
            const SizedBox(height: 16),
          ],
          _buildMatchHeaderCard(provider),
          const SizedBox(height: 16),
          _buildScoreSummaryCard(provider),
          const SizedBox(height: 16),
          _buildDetailedScoreCard(provider),
          const SizedBox(height: 16),
          _buildPlayerStatisticsCard(provider),
          const SizedBox(height: 16),
          _buildMatchDetailsCard(provider),
          if (provider.matchOver) ...[
            const SizedBox(height: 16),
            _buildWinnerCard(provider),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletionBanner(TournamentBadmintonViewModel provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Match Completed',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Winner: ${provider.winner ?? "Unknown"}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Final Score: ${provider.team1Sets} - ${provider.team2Sets}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'FINAL',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotStartedBanner(TournamentBadmintonViewModel provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[600]!, Colors.orange[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.schedule,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Match Not Started',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Waiting for match to begin...',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Teams: ${provider.team1Display} vs ${provider.team2Display}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'PENDING',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchHeaderCard(TournamentBadmintonViewModel provider) {
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
                _buildTeamInfo(provider.team1Display, Colors.blue[300]!),
                const Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                _buildTeamInfo(provider.team2Display, Colors.red[300]!),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purple, width: 1),
              ),
              child: Text(
                '${provider.matchData?.matchType ?? "Unknown"} Match',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple[300],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamInfo(String teamName, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.sports_tennis, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            teamName,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSummaryCard(TournamentBadmintonViewModel provider) {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Final Score',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFinalScore(provider.team1Sets, provider.team1Display,
                    Colors.blue[300]!),
                const Text(
                  '-',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                _buildFinalScore(provider.team2Sets, provider.team2Display,
                    Colors.red[300]!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalScore(int sets, String teamName, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: color, width: 3),
          ),
          child: Center(
            child: Text(
              '$sets',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          teamName,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDetailedScoreCard(TournamentBadmintonViewModel provider) {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set-by-Set Score',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(3, (index) => _buildSetRow(provider, index)),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(TournamentBadmintonViewModel provider, int setIndex) {
    final team1Score = provider.team1Points[setIndex];
    final team2Score = provider.team2Points[setIndex];

    // Use same badminton rules as scoreboard: win by 2 from 21, cap at 30
    final int diff = (team1Score - team2Score).abs();
    final bool isSetComplete =
        ((team1Score >= 21 || team2Score >= 21) && diff >= 2) ||
            team1Score == 30 ||
            team2Score == 30;

    final setWinner = team1Score > team2Score ? 1 : 2;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSetComplete
            ? (setWinner == 1
                ? Colors.blue.withOpacity(0.1)
                : Colors.red.withOpacity(0.1))
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSetComplete
              ? (setWinner == 1 ? Colors.blue : Colors.red)
              : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '${setIndex + 1}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$team1Score',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[300],
                  ),
                ),
                Text(
                  '-',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.grey[400],
                  ),
                ),
                Text(
                  '$team2Score',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[300],
                  ),
                ),
              ],
            ),
          ),
          if (isSetComplete) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: setWinner == 1 ? Colors.blue : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                setWinner == 1 ? 'T1' : 'T2',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ] else if (team1Score >= 20 && team2Score >= 20) ...[
            // Show deuce/advantage status for incomplete sets at 20+
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: Text(
                diff == 0 ? 'Deuce' : 'Adv',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[300],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerStatisticsCard(TournamentBadmintonViewModel provider) {
    List<String> allPlayers = [];

    if (provider.matchData?.matchType?.contains('Singles') == true) {
      allPlayers = [
        provider.matchData?.player1 ?? 'Player 1',
        provider.matchData?.player2 ?? 'Player 2',
      ];
    } else {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Player Statistics',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ...allPlayers.map((playerName) => _buildPlayerStatRow(
                playerName,
                provider.playerPoints[playerName] ?? 0,
                allPlayers.indexOf(playerName) < 2
                    ? Colors.blue[300]!
                    : Colors.red[300]!)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerStatRow(String playerName, int points, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Icon(
                Icons.person,
                color: color,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playerName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Individual Points',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$points pts',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchDetailsCard(TournamentBadmintonViewModel provider) {
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Match Details',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
                'Match ID', '${widget.matchId}', Icons.confirmation_number),
            _buildDetailRow(
                'Match Type',
                '${provider.matchData?.matchType ?? "Unknown"}',
                Icons.sports_tennis),
            _buildDetailRow('Total Duration',
                _formatTime(provider.matchDuration), Icons.timer),
            _buildDetailRow(
                'Current Set', '${provider.currentSet + 1}', Icons.games),
            _buildDetailRow(
                'Sets Played',
                '${provider.team1Sets + provider.team2Sets}',
                Icons.sports_score),
            _buildDetailRow(
                'Match Status',
                provider.matchOver ? 'Completed' : 'In Progress',
                provider.matchOver ? Icons.check_circle : Icons.play_circle),
            if (provider.isPaused)
              _buildDetailRow('Game Status', 'Paused', Icons.pause_circle),
            _buildDetailRow(
                'Serving Team',
                provider.isTeam1Serving
                    ? provider.team1Display
                    : provider.team2Display,
                Icons.sports_tennis),
            // Add umpire and court information
            if (provider.matchData?.umpireName?.isNotEmpty == true)
              _buildDetailRow(
                  'Umpire', provider.matchData!.umpireName!, Icons.person),
            if (provider.matchData?.courtName?.isNotEmpty == true)
              _buildDetailRow(
                  'Court', provider.matchData!.courtName!, Icons.location_on),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue[300], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
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
          colors: [Colors.green, Colors.green[700]!],
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
              'Match Winner',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.winner ?? "Unknown",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
