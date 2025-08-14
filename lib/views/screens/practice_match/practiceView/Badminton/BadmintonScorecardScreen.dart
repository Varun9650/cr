import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../practiceRepository/PracticeMatchService.dart';

class BadmintonScorecardScreen extends StatefulWidget {
  final int matchId;

  const BadmintonScorecardScreen({
    Key? key,
    required this.matchId,
  }) : super(key: key);

  @override
  State<BadmintonScorecardScreen> createState() =>
      _BadmintonScorecardScreenState();
}

class _BadmintonScorecardScreenState extends State<BadmintonScorecardScreen> {
  final PracticeMatchService _service = PracticeMatchService();
  bool _isLoading = true;
  Map<String, dynamic>? _matchData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMatchData();
  }

  Future<void> _fetchMatchData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final data = await _service.getlatestrecordBadminton(widget.matchId);

      if (data == null) {
        setState(() {
          _errorMessage = 'No match data found';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _matchData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load match data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Badminton Scorecard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchMatchData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
              ),
            )
          : _errorMessage != null
              ? _buildErrorWidget()
              : _matchData != null
                  ? _buildScorecard()
                  : const Center(child: Text('No data available')),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchMatchData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Retry',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorecard() {
    final data = _matchData!;
    print("match data: $data");
    final matchType = data['matchType'] ?? 'Unknown';
    final team1Name = data['team1Name'] ?? data['team1_name'] ?? 'Team 1';
    final team2Name = data['team2Name'] ?? data['team2_name'] ?? 'Team 2';
    final matchOver = data['matchOver'] ?? false;
    final matchDate = data['match_date'] ?? DateTime.now().toString();

    // Parse scores
    List<int> team1Points = _parsePoints(data['team1Points']);
    List<int> team2Points = _parsePoints(data['team2Points']);
    print("team1Points: $team1Points");
    // Calculate sets won
    int team1Sets = 0, team2Sets = 0;
    for (int i = 0; i < team1Points.length; i++) {
      if (team1Points[i] > team2Points[i]) {
        team1Sets++;
      } else if (team2Points[i] > team1Points[i]) {
        team2Sets++;
      }
    }

    // Winner conversion logic
    dynamic winnerRaw = data['winnerTeam'];
    print("winnerRaw: $winnerRaw, type: ${winnerRaw.runtimeType}");
    String winner;
    if (winnerRaw == 1 || winnerRaw == '1') {
      winner = team1Name;
    } else if (winnerRaw == 2 || winnerRaw == '2') {
      winner = team2Name;
    } else if (winnerRaw != null) {
      winner = winnerRaw.toString();
    } else {
      winner = '';
    }
    print("winner: $winner, type: ${winner.runtimeType}");

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMatchHeader(matchType, team1Name, team2Name, matchOver,
              winner.toString(), matchDate),
          if (matchOver) ...[
            const SizedBox(height: 16),
            _buildWinnerCard(
                winner.toString(), team1Name, team2Name, team1Sets, team2Sets),
          ],
          const SizedBox(height: 24),
          _buildScoreSection(team1Name, team2Name, team1Points, team2Points,
              team1Sets, team2Sets),
          const SizedBox(height: 24),
          _buildPlayerPoints(data),
          const SizedBox(height: 24),
          _buildMatchStats(data),
        ],
      ),
    );
  }

  Widget _buildWinnerCard(dynamic winner, String team1Name, String team2Name,
      int team1Sets, int team2Sets) {
    String winnerText;

    // Convert winner to string for safe comparison
    String winnerStr = winner?.toString() ?? '';

    if (winner == 1 || winnerStr == '1' || winnerStr == team1Name) {
      winnerText = '$team1Name won the match ($team1Sets-$team2Sets)';
    } else if (winner == 2 || winnerStr == '2' || winnerStr == team2Name) {
      winnerText = '$team2Name won the match ($team2Sets-$team1Sets)';
    } else if (winnerStr.isNotEmpty) {
      winnerText = '$winnerStr won the match';
    } else {
      winnerText = 'Match completed';
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, color: Colors.green, size: 28),
          const SizedBox(width: 12),
          Text(
            winnerText,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchHeader(String matchType, String team1Name, String team2Name,
      bool matchOver, dynamic winner, String matchDate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
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
      child: Column(
        children: [
          Text(
            matchType.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  team1Name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'VS',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  team2Name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          if (matchOver) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green, width: 1),
              ),
              child: Text(
                'Winner: ${winner ?? 'Unknown'}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[100],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            _formatDate(matchDate),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection(
      String team1Name,
      String team2Name,
      List<int> team1Points,
      List<int> team2Points,
      int team1Sets,
      int team2Sets) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Match Score',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTeamScore(
                    team1Name, team1Points, team1Sets, Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTeamScore(
                    team2Name, team2Points, team2Sets, Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScore(
      String teamName, List<int> points, int setsWon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            teamName,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: points.asMap().entries.map((entry) {
              int index = entry.key;
              int score = entry.value;
              return Column(
                children: [
                  Text(
                    'Set ${index + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        score.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Sets: $setsWon',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerDetails(Map<String, dynamic> data) {
    final matchType = data['matchType'] ?? '';
    final isSingles = matchType.endsWith('Singles');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Players',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          if (isSingles) ...[
            _buildPlayerRow(
                'Player 1', data['player1'] ?? 'Unknown', Colors.blue),
            const SizedBox(height: 12),
            _buildPlayerRow(
                'Player 2', data['player2'] ?? 'Unknown', Colors.orange),
          ] else ...[
            _buildPlayerRow('Team 1 - Player 1',
                data['team1Player1'] ?? 'Unknown', Colors.blue),
            const SizedBox(height: 8),
            _buildPlayerRow('Team 1 - Player 2',
                data['team1Player2'] ?? 'Unknown', Colors.blue),
            const SizedBox(height: 12),
            _buildPlayerRow('Team 2 - Player 1',
                data['team2Player1'] ?? 'Unknown', Colors.orange),
            const SizedBox(height: 8),
            _buildPlayerRow('Team 2 - Player 2',
                data['team2Player2'] ?? 'Unknown', Colors.orange),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerRow(String label, String playerName, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                playerName,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerPoints(Map<String, dynamic> data) {
    final matchType = data['matchType'] ?? '';
    final isSingles = matchType.endsWith('Singles');
    final playerPoints = _parsePlayerPoints(data['playerPoints']);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Player Details And Points',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          if (isSingles) ...[
            _buildPlayerPointRow('Player 1', data['player1'] ?? 'Unknown',
                playerPoints[data['player1']] ?? 0, Colors.blue),
            const SizedBox(height: 12),
            _buildPlayerPointRow('Player 2', data['player2'] ?? 'Unknown',
                playerPoints[data['player2']] ?? 0, Colors.orange),
          ] else ...[
            _buildPlayerPointRow(
                'Team 1 - Player 1',
                data['team1Player1'] ?? 'Unknown',
                playerPoints[data['team1Player1']] ?? 0,
                Colors.blue),
            const SizedBox(height: 8),
            _buildPlayerPointRow(
                'Team 1 - Player 2',
                data['team1Player2'] ?? 'Unknown',
                playerPoints[data['team1Player2']] ?? 0,
                Colors.blue),
            const SizedBox(height: 12),
            _buildPlayerPointRow(
                'Team 2 - Player 1',
                data['team2Player1'] ?? 'Unknown',
                playerPoints[data['team2Player1']] ?? 0,
                Colors.orange),
            const SizedBox(height: 8),
            _buildPlayerPointRow(
                'Team 2 - Player 2',
                data['team2Player2'] ?? 'Unknown',
                playerPoints[data['team2Player2']] ?? 0,
                Colors.orange),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerPointRow(
      String label, String playerName, int points, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  playerName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$points pts',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchStats(Map<String, dynamic> data) {
    // Winner conversion logic for stats
    dynamic winnerRaw = data['winnerTeam'];
    String winner;
    if (winnerRaw == 1 || winnerRaw == '1') {
      winner = data['team1Name'] ?? data['team1_name'] ?? 'Team 1';
    } else if (winnerRaw == 2 || winnerRaw == '2') {
      winner = data['team2Name'] ?? data['team2_name'] ?? 'Team 2';
    } else if (winnerRaw != null) {
      winner = winnerRaw.toString();
    } else {
      winner = 'Unknown';
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Match Statistics',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow('Match Status',
              data['matchOver'] == true ? 'Completed' : 'In Progress'),
          _buildStatRow('Current Set', '${(data['currentSet'] ?? 0) + 1}'),
          _buildStatRow('Total Sets Played', '${data['currentSet'] ?? 0}'),
          if (data['matchOver'] == true) ...[
            _buildStatRow('Winner', winner),
            _buildStatRow(
                'Match Duration', _formatDuration(data['matchDuration'] ?? 0)),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  List<int> _parsePoints(dynamic pointsData) {
    if (pointsData == null) return [0, 0, 0];

    if (pointsData is String) {
      List<String> pointsStr = pointsData.split(',');
      return pointsStr.map((e) => int.tryParse(e.trim()) ?? 0).toList();
    } else if (pointsData is List) {
      return List<int>.from(pointsData);
    }

    return [0, 0, 0];
  }

  Map<String, int> _parsePlayerPoints(dynamic playerPointsData) {
    if (playerPointsData == null) return {};

    if (playerPointsData is String) {
      // Parse toString() format like "{player1: 6, player2: 3}"
      String playerPointsStr = playerPointsData;
      Map<String, int> playerPoints = {};

      // Remove curly braces and split by comma
      if (playerPointsStr.startsWith('{') && playerPointsStr.endsWith('}')) {
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
            }
          }
        }
      }
      return playerPoints;
    } else if (playerPointsData is Map) {
      return Map<String, int>.from(playerPointsData);
    }

    return {};
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
}
