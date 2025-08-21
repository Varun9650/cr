import 'package:cricyard/core/utils/smart_print.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../tournament/views/tournament_badminton_scoreboard_screen.dart';
import '../viewmodel/badminton_scoreboard_create_view_model.dart';

class BadmintonScoreBoardCreateEntityScreen extends StatefulWidget {
  final int matchId;
  final int tourId;
  final String matchType;
  final Map<String, dynamic> entity; // Add entity parameter

  const BadmintonScoreBoardCreateEntityScreen({
    Key? key,
    required this.matchId,
    required this.tourId,
    required this.matchType,
    required this.entity, // Add entity parameter
  }) : super(key: key);

  @override
  State<BadmintonScoreBoardCreateEntityScreen> createState() =>
      _BadmintonScoreBoardCreateEntityScreenState();
}

class _BadmintonScoreBoardCreateEntityScreenState
    extends State<BadmintonScoreBoardCreateEntityScreen> {
  final _formKey = GlobalKey<FormState>();

  // Single player fields
  final TextEditingController _player1NameController = TextEditingController();
  final TextEditingController _player2NameController = TextEditingController();

  // Double player fields
  final TextEditingController _player1Team1Controller = TextEditingController();
  final TextEditingController _player2Team1Controller = TextEditingController();
  final TextEditingController _player1Team2Controller = TextEditingController();
  final TextEditingController _player2Team2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _player1NameController.dispose();
    _player2NameController.dispose();
    _player1Team1Controller.dispose();
    _player2Team1Controller.dispose();
    _player1Team2Controller.dispose();
    _player2Team2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = BadmintonScoreboardCreateViewModel();
        // Initialize the provider after creation with entity data
        WidgetsBinding.instance.addPostFrameCallback((_) {
          provider.initializeData(
              widget.matchId, widget.tourId, widget.matchType, widget.entity);
        });
        return provider;
      },
      child: Consumer<BadmintonScoreboardCreateViewModel>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF219ebc),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              title: Text(
                'Player Entry',
                style: GoogleFonts.getFont('Poppins',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A)),
              ),
              centerTitle: true,
            ),
            body: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(provider),
                          const SizedBox(height: 32),
                          _buildTeamInfoSection(provider),
                          const SizedBox(height: 24),
                          _buildPlayerEntryForm(provider),
                          const SizedBox(height: 24),
                          _buildValidationSummary(provider),
                          const SizedBox(height: 32),
                          _buildSubmitButton(provider),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BadmintonScoreboardCreateViewModel provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF219ebc), Color(0xFF023e8a)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF219ebc).withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.sports_tennis,
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
                  'Badminton Match Setup',
                  style: GoogleFonts.getFont('Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Match Type: ${provider.matchType}',
                  style: GoogleFonts.getFont('Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInfoSection(BadmintonScoreboardCreateViewModel provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Information',
            style: GoogleFonts.getFont('Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 16),
          Text(
            'Match ID: ${provider.matchId}',
            style: GoogleFonts.getFont('Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tournament ID: ${provider.tourId}',
            style: GoogleFonts.getFont('Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerEntryForm(BadmintonScoreboardCreateViewModel provider) {
    return Consumer<BadmintonScoreboardCreateViewModel>(
      builder: (context, provider, child) {
        // Debug: Print the match type to see what's being passed
        print('Match Type: "${provider.matchType}"');
        print('Contains Singles: ${provider.matchType.contains('Singles')}');

        // Check for different variations of Singles
        final matchTypeLower = provider.matchType.toLowerCase();
        final isSingles = matchTypeLower.contains('singles') ||
            matchTypeLower.contains('single') ||
            matchTypeLower == 'singles' ||
            matchTypeLower == 'single';

        print('Is Singles: $isSingles');

        if (isSingles) {
          return _buildSinglePlayerForm(provider);
        } else {
          return _buildDoublePlayerForm(provider);
        }
      },
    );
  }

  Widget _buildSinglePlayerForm(BadmintonScoreboardCreateViewModel provider) {
    // Get auto-populated player names
    final playerNames = provider.getSinglesPlayerNames();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Player Entry (Singles)',
          style: GoogleFonts.getFont('Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 16),
        _buildPlayerCard(
          title: 'Player 1',
          playerName: playerNames['player1'] ?? 'Loading...',
          icon: Icons.person,
          color: const Color(0xFF219ebc),
          isLoading: provider.isLoadingMembers,
        ),
        const SizedBox(height: 16),
        _buildPlayerCard(
          title: 'Player 2',
          playerName: playerNames['player2'] ?? 'Loading...',
          icon: Icons.person,
          color: const Color(0xFF023e8a),
          isLoading: provider.isLoadingMembers,
        ),
      ],
    );
  }

  Widget _buildDoublePlayerForm(BadmintonScoreboardCreateViewModel provider) {
    // Get auto-populated player names
    final playerNames = provider.getDoublesPlayerNames();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Player Entry (Doubles)',
          style: GoogleFonts.getFont('Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 16),
        _buildTeamCard(
          title: 'Team 1',
          player1Name: playerNames['team1Player1'] ?? 'Loading...',
          player2Name: playerNames['team1Player2'] ?? 'Loading...',
          color: const Color(0xFF219ebc),
          isLoading: provider.isLoadingMembers,
        ),
        const SizedBox(height: 16),
        _buildTeamCard(
          title: 'Team 2',
          player1Name: playerNames['team2Player1'] ?? 'Loading...',
          player2Name: playerNames['team2Player2'] ?? 'Loading...',
          color: const Color(0xFF023e8a),
          isLoading: provider.isLoadingMembers,
        ),
      ],
    );
  }

  Widget _buildPlayerCard({
    required String title,
    required String playerName,
    required IconData icon,
    required Color color,
    required bool isLoading,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                '$title *',
                style: GoogleFonts.getFont('Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(Icons.check_circle, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    playerName,
                    style: GoogleFonts.getFont('Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isLoading ? Colors.grey[600] : color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard({
    required String title,
    required String player1Name,
    required String player2Name,
    required Color color,
    required bool isLoading,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.group, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                '$title *',
                style: GoogleFonts.getFont('Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    if (isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(Icons.check_circle, color: color, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Player 1: $player1Name',
                        style: GoogleFonts.getFont('Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isLoading ? Colors.grey[600] : color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SizedBox(width: 28), // Align with player 1
                    Expanded(
                      child: Text(
                        'Player 2: $player2Name',
                        style: GoogleFonts.getFont('Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isLoading ? Colors.grey[600] : color),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BadmintonScoreboardCreateViewModel provider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: provider.isSubmitting
            ? null
            : () {
                smartPrint('Submit button pressed!');
                _handleSubmit(provider);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF219ebc),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: const Color(0xFF219ebc).withOpacity(0.3),
        ),
        child: provider.isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Creating...",
                    style: GoogleFonts.getFont('Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ],
              )
            : Text(
                "Start Badminton Scoreboard",
                style: GoogleFonts.getFont('Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildValidationSummary(BadmintonScoreboardCreateViewModel provider) {
    return Consumer<BadmintonScoreboardCreateViewModel>(
      builder: (context, provider, child) {
        // Check if team members are loaded
        bool isFormValid = !provider.isLoadingMembers &&
            provider.team1Members.isNotEmpty &&
            provider.team2Members.isNotEmpty;

        String statusMessage = 'Loading team members...';
        if (provider.isLoadingMembers) {
          statusMessage = 'Loading team members...';
        } else if (provider.team1Members.isEmpty ||
            provider.team2Members.isEmpty) {
          statusMessage = 'Team members not found';
        } else {
          statusMessage = 'Players ready';
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isFormValid
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFormValid
                  ? Colors.green.withOpacity(0.3)
                  : Colors.orange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isFormValid ? Icons.check_circle : Icons.warning,
                color: isFormValid ? Colors.green : Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusMessage,
                      style: GoogleFonts.getFont('Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isFormValid ? Colors.green : Colors.orange),
                    ),
                    if (isFormValid) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${provider.team1Name} vs ${provider.team2Name}',
                        style: GoogleFonts.getFont('Poppins',
                            fontSize: 14, color: Colors.green),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit(
      BadmintonScoreboardCreateViewModel provider) async {
    print('=== SUBMIT BUTTON CLICKED ===');
    print('Match Type: ${provider.matchType}');
    print('Team 1 ID: ${provider.team1Id}, Name: ${provider.team1Name}');
    print('Team 2 ID: ${provider.team2Id}, Name: ${provider.team2Name}');

    // Check if team members are loaded
    if (provider.isLoadingMembers) {
      print('Still loading team members');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please wait while team members are loading',
            style: GoogleFonts.getFont('Poppins', fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    if (provider.team1Members.isEmpty || provider.team2Members.isEmpty) {
      print('Team members not found');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Team members not found. Please check team data.',
            style: GoogleFonts.getFont('Poppins', fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    // Collect player data automatically from teams
    print('Collecting player data from teams... \n');
    Map<String, dynamic> playerData = {};

    final matchTypeLower = provider.matchType.toLowerCase();
    final isSingles = matchTypeLower.contains('singles') ||
        matchTypeLower.contains('single') ||
        matchTypeLower == 'singles' ||
        matchTypeLower == 'single';

    if (isSingles) {
      print('Processing Singles match type \n');
      final singlesNames = provider.getSinglesPlayerNames();
      playerData = {
        'player1': singlesNames['player1'] ?? 'Player 1',
        'player2': singlesNames['player2'] ?? 'Player 2',
      };
    } else {
      print('Processing Doubles match type \n');
      final doublesNames = provider.getDoublesPlayerNames();
      playerData = {
        'team1Player1': doublesNames['team1Player1'] ?? 'Team 1 Player 1',
        'team1Player2': doublesNames['team1Player2'] ?? 'Team 1 Player 2',
        'team2Player1': doublesNames['team2Player1'] ?? 'Team 2 Player 1',
        'team2Player2': doublesNames['team2Player2'] ?? 'Team 2 Player 2',
      };
    }

    print('Final player data: $playerData \n');

    try {
      await provider.createBadmintonScoreboard(playerData);

      if (provider.isSuccess && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Badminton scoreboard created successfully!',
              style:
                  GoogleFonts.getFont('Poppins', fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TournamentBadmintonScoreboardScreen(
              matchId: widget.matchId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error creating scoreboard: $e',
              style:
                  GoogleFonts.getFont('Poppins', fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}
