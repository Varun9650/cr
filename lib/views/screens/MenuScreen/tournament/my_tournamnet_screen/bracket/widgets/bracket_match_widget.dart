import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BracketMatchWidget extends StatelessWidget {
  final Map<String, dynamic> match;
  final Function(String, String, String)? onWinnerSelected;
  final bool showWinnerButtons;
  final Function(String, String)? onStatusChanged;
  final Function(String matchId, String teamSlot)? onRemoveTeam;
  final Function(String matchId, String teamSlot)? onAddTeam;
  final List<String>? availableTeams;

  const BracketMatchWidget({
    Key? key,
    required this.match,
    this.onWinnerSelected,
    this.showWinnerButtons = true,
    this.onStatusChanged,
    this.onRemoveTeam,
    this.onAddTeam,
    this.availableTeams,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final team1 = match['team1'];
    final team2 = match['team2'];
    final winner = match['winner'];
    final status = match['status'];
    final matchId = match['match_id'];
    final completed = status == 'completed';

    Color cardColor = Colors.white;
    Color borderColor = Colors.grey[300]!;
    double borderWidth = 1;

    if (status == 'completed') {
      cardColor = Colors.green[100]!;
      borderColor = Colors.green[700]!;
      borderWidth = 2;
    } else if (status == 'ready') {
      cardColor = Colors.blue[100]!;
      borderColor = Colors.blue[700]!;
      borderWidth = 2;
    }

    return Container(
      width: 220,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTeamRow(
              context, matchId, 'team1', team1, winner == team1, completed),
          const Divider(height: 1),
          _buildTeamRow(
              context, matchId, 'team2', team2, winner == team2, completed),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _buildStatusDropdown(context, matchId, status),
          ),
          if (showWinnerButtons && status == 'ready')
            _buildWinnerButtons(matchId, team1, team2),
        ],
      ),
    );
  }

  Widget _buildTeamRow(BuildContext context, String matchId, String teamSlot,
      dynamic teamName, bool isWinner, bool isCompleted) {
    // final isEmpty = teamName == null || teamName == 'BYE';
    final isDummy = teamName == 'BYE';
    final isEmpty = teamName == null || teamName.toString().trim().isEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: isWinner && isCompleted ? Colors.green[100] : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          if (isWinner && isCompleted)
            const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 4),
          Expanded(
            child: isEmpty
                ? (onAddTeam != null
                    ? TextButton.icon(
                        onPressed: () => onAddTeam!(matchId, teamSlot),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Team',
                            style: TextStyle(fontSize: 12)),
                      )
                    : const Text('Add Team', style: TextStyle(fontSize: 12)))
                : Text(
                    isDummy ? 'BYE' : teamName.toString(),
                    style: TextStyle(
                      fontWeight: isWinner && isCompleted
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isDummy
                          ? Colors.grey[700]
                          : (teamName == 'TBD'
                              ? Colors.grey[600]
                              : Colors.black),
                      fontSize: 14,
                    ),
                  ),
          ),
          if (!isCompleted && !isEmpty && !isDummy && onRemoveTeam != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red, size: 18),
              tooltip: 'Remove Team',
              onPressed: () => onRemoveTeam!(matchId, teamSlot),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(
      BuildContext context, String matchId, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Status:', style: TextStyle(fontSize: 12, color: Colors.black87)),
        const SizedBox(width: 6),
        DropdownButton<String>(
          value: status,
          items: const [
            DropdownMenuItem(value: 'pending', child: Text('Pending')),
            DropdownMenuItem(value: 'ready', child: Text('Ready')),
            DropdownMenuItem(value: 'completed', child: Text('Completed')),
          ],
          onChanged: (val) {
            if (val != null && onStatusChanged != null) {
              onStatusChanged!(matchId, val);
            }
          },
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildWinnerButtons(String matchId, dynamic team1, dynamic team2) {
    // Handle single team cases
    final hasTeam1 = team1 != null && team1 != 'BYE' && team1 != 'TBD';
    final hasTeam2 = team2 != null && team2 != 'BYE' && team2 != 'TBD';

    // If only one team exists, show single winner button
    if (hasTeam1 && !hasTeam2) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton(
          onPressed: () =>
              onWinnerSelected?.call(matchId, team1.toString(), 'BYE'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Text(
            '$team1 Wins',
            style: GoogleFonts.getFont(
              'Poppins',
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    if (!hasTeam1 && hasTeam2) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: ElevatedButton(
          onPressed: () =>
              onWinnerSelected?.call(matchId, team2.toString(), 'BYE'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Text(
            '$team2 Wins',
            style: GoogleFonts.getFont(
              'Poppins',
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // If both teams exist, show both buttons
    if (hasTeam1 && hasTeam2) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => onWinnerSelected?.call(
                    matchId, team1.toString(), team2.toString()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  'Team 1',
                  style: GoogleFonts.getFont(
                    'Poppins',
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => onWinnerSelected?.call(
                    matchId, team2.toString(), team1.toString()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(
                  'Team 2',
                  style: GoogleFonts.getFont(
                    'Poppins',
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // If no valid teams, return empty container
    return const SizedBox.shrink();
  }
}
