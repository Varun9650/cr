import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../viewmodel/edit_games_view_model.dart';

class EditGamesScreen extends StatefulWidget {
  final int matchId;
  final String team1Name;
  final String team2Name;

  const EditGamesScreen({
    Key? key,
    required this.matchId,
    required this.team1Name,
    required this.team2Name,
  }) : super(key: key);

  @override
  State<EditGamesScreen> createState() => _EditGamesScreenState();
}

class _EditGamesScreenState extends State<EditGamesScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = EditGamesViewModel();
        // Initialize data after creation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          provider.loadMatchData(widget.matchId);
        });
        return provider;
      },
      child: Consumer<EditGamesViewModel>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: const Color(0xFF1A1A1A),
            appBar: _buildAppBar(provider),
            body: _buildBody(provider),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(EditGamesViewModel provider) {
    return AppBar(
      backgroundColor: const Color(0xFF264653),
      elevation: 0,
      title: Text(
        'Edit Match',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (provider.isSaving)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(EditGamesViewModel provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Error Loading Match Data',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadMatchData(widget.matchId),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMatchInfoCard(provider),
          const SizedBox(height: 16),
          _buildScoreEditCard(provider),
          const SizedBox(height: 16),
          _buildPlayerEditCard(provider),
          const SizedBox(height: 16),
          _buildSaveButton(provider),
        ],
      ),
    );
  }

  Widget _buildMatchInfoCard(EditGamesViewModel provider) {
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
                Expanded(
                  child: Text(
                    widget.team1Name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[300],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.team2Name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[300],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
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
                'Match ID: ${widget.matchId}',
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

  Widget _buildScoreEditCard(EditGamesViewModel provider) {
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
              'Edit Scores',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTeamScoreInput(
                    'Team 1 Sets',
                    provider.team1Sets,
                    (value) => provider.setTeam1Sets(value),
                    Colors.blue[300]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTeamScoreInput(
                    'Team 2 Sets',
                    provider.team2Sets,
                    (value) => provider.setTeam2Sets(value),
                    Colors.red[300]!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Set Scores',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(3, (index) => _buildSetScoreRow(provider, index)),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamScoreInput(
      String label, int value, Function(int) onChanged, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[300],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 1),
          ),
          child: TextFormField(
            initialValue: value.toString(),
            keyboardType: TextInputType.number,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (text) {
              final newValue = int.tryParse(text) ?? 0;
              onChanged(newValue);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSetScoreRow(EditGamesViewModel provider, int setIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
              children: [
                Expanded(
                  child: _buildScoreInput(
                    provider.team1Points[setIndex].toString(),
                    (value) => provider.setTeam1Point(setIndex, value),
                    Colors.blue[300]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildScoreInput(
                    provider.team2Points[setIndex].toString(),
                    (value) => provider.setTeam2Point(setIndex, value),
                    Colors.red[300]!,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreInput(String value, Function(int) onChanged, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: TextFormField(
        initialValue: value,
        keyboardType: TextInputType.number,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
        onChanged: (text) {
          final newValue = int.tryParse(text) ?? 0;
          onChanged(newValue);
        },
      ),
    );
  }

  Widget _buildPlayerEditCard(EditGamesViewModel provider) {
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
              'Player Points',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ...provider.playerPoints.entries.map((entry) =>
                _buildPlayerPointRow(entry.key, entry.value, (value) {
                  provider.setPlayerPoint(entry.key, value);
                })),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerPointRow(
      String playerName, int points, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              playerName,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[300],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue, width: 1),
              ),
              child: TextFormField(
                initialValue: points.toString(),
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[300],
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: (text) {
                  final newValue = int.tryParse(text) ?? 0;
                  onChanged(newValue);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(EditGamesViewModel provider) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: provider.isSaving ? null : () => _saveMatch(provider),
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (provider.isSaving)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              else
                const Icon(Icons.save, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                provider.isSaving ? 'Saving...' : 'Save Changes',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveMatch(EditGamesViewModel provider) async {
    try {
      await provider.saveMatchHistory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Match updated successfully!',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

        // Navigate back after successful save
        Navigator.pop(
            context, true); // Return true to indicate successful update
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update match: $e',
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
}
