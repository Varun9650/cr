import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tournament_badminton_scoreboard_screen.dart';

class TournamentBadmintonDemo extends StatefulWidget {
  const TournamentBadmintonDemo({Key? key}) : super(key: key);

  @override
  State<TournamentBadmintonDemo> createState() =>
      _TournamentBadmintonDemoState();
}

class _TournamentBadmintonDemoState extends State<TournamentBadmintonDemo> {
  final TextEditingController _matchIdController = TextEditingController();

  @override
  void dispose() {
    _matchIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF264653),
        elevation: 0,
        title: Text(
          'Tournament Badminton Demo',
          style: GoogleFonts.getFont('Poppins',
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E50),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF34495E)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.sports_tennis,
                    size: 80,
                    color: Colors.blue[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tournament Badminton Scoreboard',
                    style: GoogleFonts.getFont('Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter Match ID to start scoring',
                    style: GoogleFonts.getFont('Poppins',
                        fontSize: 16, color: Colors.grey[300]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Match ID Input
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E50),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF34495E)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Match ID',
                    style: GoogleFonts.getFont('Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _matchIdController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.getFont('Poppins',
                        fontSize: 16, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter match ID (e.g., 123)',
                      hintStyle: GoogleFonts.getFont('Poppins',
                          fontSize: 16, color: Colors.grey[400]),
                      filled: true,
                      fillColor: const Color(0xFF34495E),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Start Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final matchId = int.tryParse(_matchIdController.text);
                  if (matchId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TournamentBadmintonScoreboardScreen(
                          matchId: matchId,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid match ID'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  'Start Badminton Scoreboard',
                  style: GoogleFonts.getFont('Poppins',
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Info Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[900]!.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[700]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue[400], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'How it works',
                        style: GoogleFonts.getFont('Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[400]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Enter the match ID from your tournament\n'
                    '• The scoreboard will load match data automatically\n'
                    '• Score points for each team\n'
                    '• Track sets and match progress\n'
                    '• View match history and statistics',
                    style: GoogleFonts.getFont('Poppins',
                        fontSize: 14, color: Colors.grey[300]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
