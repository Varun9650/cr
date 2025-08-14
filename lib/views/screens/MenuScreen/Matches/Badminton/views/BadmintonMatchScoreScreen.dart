// ignore_for_file: use_build_context_synchronously
import 'package:cricyard/core/utils/size_utils.dart';
import 'package:cricyard/views/screens/MenuScreen/Matches/views/my_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../../Entity/matches/Match/views/Match_update_entity_screen.dart';
import 'BadmintonScoreBoardCreateEntityScreen.dart';
import '../viewmodel/badminton_match_view_model.dart';
import '../../../tournament/views/tournament_badminton_scoreboard_screen.dart';

class BadmintonMatchScoreScreen extends StatefulWidget {
  final Map<String, dynamic> entity;
  final bool status;

  const BadmintonMatchScoreScreen(
      {super.key, required this.entity, required this.status});

  @override
  _BadmintonMatchScoreScreenState createState() =>
      _BadmintonMatchScoreScreenState();
}

class _BadmintonMatchScoreScreenState extends State<BadmintonMatchScoreScreen> {
  @override
  void initState() {
    print(' entity in hhh ${widget.entity}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = BadmintonMatchViewModel();
        // Initialize the provider after creation
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await provider.initializeMatch(widget.entity, widget.status);
          // Check if we should auto-navigate after initialization is complete
          print(
              'BadmintonMatchScreen: Checking auto-navigation - isLastRecord: ${provider.isLastRecord}, isData: ${provider.isData}, isLoadingData: ${provider.isLoadingData}');
          if (provider.isLastRecord &&
              provider.isData &&
              !provider.isLoadingData) {
            print('BadmintonMatchScreen: Auto-navigating to scoreboard');
            // Use a separate post frame callback to ensure context is available
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TournamentBadmintonScoreboardScreen(
                    matchId: provider.matchId,
                  ),
                ),
              );
            });
          } else {
            print(
                'BadmintonMatchScreen: Not auto-navigating, showing restructure screen');
          }
        });
        return provider;
      },
      child: Consumer<BadmintonMatchViewModel>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                "${provider.team1Name} v/s ${provider.team2Name}",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: const Color(0xFF219ebc),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.grey[200],
            body: provider.isLoadingData
                ? Stack(
                    children: [
                      _buildMatchInfo(provider),
                      _showOverlay(),
                    ],
                  )
                : provider.isData
                    ? _buildMatchInfo(provider)
                    : _buildRestructure(provider),
          );
        },
      ),
    );
  }

  Widget _buildMatchInfo(BadmintonMatchViewModel provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.sports_tennis,
                  size: 64,
                  color: const Color(0xFF219ebc),
                ),
                const SizedBox(height: 16),
                Text(
                  'Badminton Match',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.matchType,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${provider.team1Name} vs ${provider.team2Name}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestructure(BadmintonMatchViewModel provider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyElevatedButton(
                height: 67.v,
                width: MediaQuery.of(context).size.width * 0.45,
                text: "Reschedule",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MatchUpdateEntityScreen(entity: widget.entity)),
                  );
                },
              ),
              const SizedBox(width: 2),
              MyElevatedButton(
                height: 67.v,
                width: MediaQuery.of(context).size.width * 0.45,
                text: "Cancel",
                onPressed: () async {
                  await provider.cancelBadmintonMatch();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: MyElevatedButton(
            height: 67.0,
            width: MediaQuery.of(context).size.width,
            text: "Start Match",
            // onPressed: () async {
            //   await provider.startBadmintonMatch();
            // },
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BadmintonScoreBoardCreateEntityScreen(
                          matchId: provider.matchId,
                          tourId: provider.tournamentId,
                          matchType: provider.matchType,
                          entity: widget.entity,
                        )),
              )
                  .then((value) => Navigator.of(context))
                  .then((value) => provider.getLastRecordBadminton());
            },
          ),
        ),
      ],
    );
  }

  Widget _showOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
