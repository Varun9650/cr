import 'package:cricyard/core/app_export.dart';
import 'package:cricyard/core/utils/smart_print.dart';
import 'package:cricyard/views/screens/MenuScreen/Basketball/views/BasketballScorecard/basketballMatchScoreTour.dart';
import 'package:cricyard/views/screens/MenuScreen/Football/views/FootballScorecard/footballMatchScoreTour.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../theme/custom_button_style.dart';
import '../../../../../widgets/custom_elevated_button.dart';
import '../../../Matches/Badminton/views/BadmintonMatchScoreScreen.dart';
import '../../../Matches/views/Cricket/CricketMatchScoreScreen.dart';
import '../../score_board/tournament_scoreboard_screen.dart';
import '../viewmodel/matches_view_model.dart';
import 'edit_games_screen.dart';
import '../../views/tournament_badminton_scorecard_screen.dart';

class MatchesScreen extends StatefulWidget {
  final int tourId;
  final bool isEnrolled;
  const MatchesScreen(
      {super.key, required this.tourId, required this.isEnrolled});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with WidgetsBindingObserver {
  String? _preferredSport;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPreferredSport();
  }

  Future<void> _loadPreferredSport() async {
    final sport = await getPreferredSport();
    setState(() {
      _preferredSport = sport;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<String> getPreferredSport() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('preferred_sport') ??
        'Unknown'; // Default to Unknown
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes back to foreground
      _refreshData();
    }
  }

  void _refreshData() {
    if (mounted) {
      final provider = Provider.of<MatchesViewModel>(context, listen: false);
      provider.refreshData(widget.tourId, widget.isEnrolled);
    }
  }

  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data every time screen becomes visible (except first load)
    if (!_isFirstLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshData();
      });
    }
    _isFirstLoad = false;
  }

  // Helper method to get color for match type
  Color _getMatchTypeColor(String matchType) {
    final preferredSport = _preferredSport ?? 'Badminton';
    final type = matchType.toLowerCase();

    if (preferredSport.toLowerCase() == 'badminton') {
      // Badminton match types
      switch (type) {
        case "men's doubles":
        case "mens doubles":
        case "men doubles":
          return Colors.blue;
        case "women's doubles":
        case "womens doubles":
        case "women doubles":
          return Colors.pink;
        case "mixed doubles":
        case "mixed":
          return Colors.purple;
        case "men's singles":
        case "mens singles":
        case "men singles":
          return Colors.green;
        case "women's singles":
        case "womens singles":
        case "women singles":
          return Colors.orange;
        case "final":
        case "semi-final":
        case "quarter-final":
          return Colors.red;
        case "league":
        case "group":
          return Colors.teal;
        default:
          return Colors.grey[600]!;
      }
    } else {
      // Cricket match types (default)
      switch (type) {
        case 't20':
        case 't-20':
          return Colors.deepPurple;
        case 'odi':
        case 'one day':
        case 'one-day':
          return Colors.blue;
        case 'test':
          return Colors.green;
        case 'friendly':
        case 'practice':
          return Colors.orange;
        case 'final':
        case 'semi-final':
        case 'quarter-final':
          return Colors.red;
        case 'league':
        case 'group':
          return Colors.teal;
        default:
          return Colors.grey[600]!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = MatchesViewModel();
        // Initialize data after creation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          provider.initializeData(widget.tourId, widget.isEnrolled);
        });
        return provider;
      },
      child: Consumer<MatchesViewModel>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: Colors.grey[200],
            appBar: AppBar(
              backgroundColor: const Color(0xFF264653),
              title: Text(
                'Tournament Matches',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  icon: provider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.refresh, color: Colors.white),
                  onPressed: provider.isLoading
                      ? null
                      : () => provider.refreshData(
                          widget.tourId, widget.isEnrolled),
                  tooltip: 'Refresh Matches',
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                await provider.refreshData(widget.tourId, widget.isEnrolled);
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildMyMatchesRow(context, provider),
                    provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildGridText(context, provider),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMyMatchesRow(BuildContext context, MatchesViewModel provider) {
    // return Row(
    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //   children: [
    //     Expanded(
    //       flex: 3,
    //       child: Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 2.0),
    //         child: _buildCustomElevatedButton(
    //           text: "Completed Match",
    //           onPressed: () => provider.setSelectedMatchType('Completed'),
    //           isSelected: provider.selectedMatchType == 'Completed',
    //         ),
    //       ),
    //     ),
    //     Expanded(
    //       flex: 2,
    //       child: Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 2.0),
    //         child: _buildCustomElevatedButton(
    //           text: "Live Match",
    //           onPressed: () => provider.setSelectedMatchType('Live'),
    //           isSelected: provider.selectedMatchType == 'Live',
    //         ),
    //       ),
    //     ),
    //     Expanded(
    //       flex: 3,
    //       child: Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 2.0),
    //         child: _buildCustomElevatedButton(
    //           text: "Upcoming Match",
    //           onPressed: () => provider.setSelectedMatchType('Upcoming'),
    //           isSelected: provider.selectedMatchType == 'Upcoming',
    //         ),
    //       ),
    // ),

    return Column(
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              onChanged: (value) {
                provider.setSearchQuery(value);
              },
              decoration: InputDecoration(
                hintText:
                    'Search matches by team name, tournament, location...',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[600],
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        // Match type buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: _buildCustomElevatedButton(
                  text: "Completed Match",
                  onPressed: () => provider.setSelectedMatchType('Completed'),
                  isSelected: provider.selectedMatchType == 'Completed',
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: _buildCustomElevatedButton(
                  text: "Live Match",
                  onPressed: () => provider.setSelectedMatchType('Live'),
                  isSelected: provider.selectedMatchType == 'Live',
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: _buildCustomElevatedButton(
                    text: "Upcoming Match",
                    onPressed: () => provider.setSelectedMatchType('Upcoming'),
                    isSelected: provider.selectedMatchType == 'Upcoming'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomElevatedButton({
    required String text,
    VoidCallback? onPressed,
    required bool isSelected,
  }) {
    return CustomElevatedButton(
      height: 50.v,
      width: MediaQuery.of(context).size.width * 0.1,
      text: text,
      buttonStyle: CustomButtonStyles.none,
      decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF264653) : Colors.grey[400],
          borderRadius: BorderRadius.circular(12)),
      buttonTextStyle: GoogleFonts.getFont('Poppins',
          fontSize: isSelected ? 14 : 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
          color: Colors.white),
      onPressed: onPressed,
    );
  }

  Widget _buildGridText(BuildContext context, MatchesViewModel provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (provider.filteredMatches.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'No matches found.',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(right: 11.h),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: provider.filteredMatches.length,
        itemBuilder: (BuildContext context, int index) {
          final entity = provider.filteredMatches[index];
          // smartPrint('entity is $entity');
          return _buildListItem(entity, provider);
        },
      ),
    );
  }

  void _navigateToEditScreen(
      BuildContext context, Map<String, dynamic> entity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditGamesScreen(
          matchId: entity['id'],
          team1Name: entity['team_1_name'] ?? 'Team 1',
          team2Name: entity['team_2_name'] ?? 'Team 2',
        ),
      ),
    ).then((result) {
      // Refresh data if edit was successful
      if (result == true) {
        final provider = Provider.of<MatchesViewModel>(context, listen: false);
        provider.refreshData(widget.tourId, widget.isEnrolled);
      }
    });
  }

  void _navigateToScoreboard(BuildContext context, Map<String, dynamic> entity,
      bool isMatchOver, bool status, MatchesViewModel provider) async {
    String preferredSport = await getPreferredSport();
    print('This is current sport: $preferredSport');

    final matchDateTime = DateTime.parse(entity['datetime_field']);
    final now = DateTime.now();

    // final timeRemaining = matchDateTime.difference(now);
    // final hours = timeRemaining.inHours;
    // final minutes = timeRemaining.inMinutes % 60;
    // final formattedTimeRemaining = "${hours}h : ${minutes}m";

    // // Check if match status is completed
    // final matchStatus = entity['matchStatus']?.toString().toLowerCase();
    // final isCompleted = matchStatus == 'completed' ||
    //     matchStatus == 'finished' ||
    //     matchStatus == 'ended';
    final timeDifference = matchDateTime.difference(now);
    final isMatchPast = timeDifference.isNegative;

    // Check if match status is completed
    final matchStatus = entity['matchStatus']?.toString().toLowerCase();
    final isCompleted = matchStatus!.contains('completed') ||
        matchStatus.contains('finished') ||
        matchStatus.contains('ended');
    Widget screen;

    // If match is completed, navigate to scorecard
    if (isCompleted ||
        widget.isEnrolled ||
        provider.selectedMatchType == 'Completed') {
      switch (preferredSport) {
        case 'Badminton':
          screen = TournamentBadmintonScorecardScreen(
            matchId: entity['id'],
          );
          break;
        case 'Football':
          // TODO: Add Football scorecard when available
          screen = FootballScoreboardScreenTournament(
            matchId: entity['id'],
            team1: entity['team_1_name'],
            team2: entity['team_2_name'],
          );
          break;
        case 'Basketball':
          // TODO: Add Basketball scorecard when available
          screen = BasketballScoreboardScreenTournament(
            matchId: entity['id'],
            team1: entity['team_1_name'],
            team2: entity['team_2_name'],
          );
          break;
        case 'Cricket':
          // TODO: Add Cricket scorecard when available
          screen = CricketTournamentScoreBoardScreen(
            matchId: entity['id'],
            team1: entity['team_1_name'],
            team2: entity['team_2_name'],
          );
          break;
        default:
          // Default to scoreboard for unknown sports
          screen = CricketTournamentScoreBoardScreen(
            matchId: entity['id'],
            team1: entity['team_1_name'],
            team2: entity['team_2_name'],
          );
      }
    } else {
      // For non-completed matches, navigate to scoreboard as before
      switch (preferredSport) {
        case 'Football':
          screen = FootballScoreboardScreenTournament(
              matchId: entity['id'],
              team1: entity['team_1_name'],
              team2: entity['team_2_name']);
          break;
        case 'Basketball':
          screen = BasketballScoreboardScreenTournament(
              matchId: entity['id'],
              team1: entity['team_1_name'],
              team2: entity['team_2_name']);
          break;
        case 'Badminton':
          screen = BadmintonMatchScoreScreen(
            entity: entity,
            status: status,
          );
          break;
        case 'Cricket':
          // formattedTimeRemaining.contains('-')
          isMatchPast
              ? screen = CricketTournamentScoreBoardScreen(
                  matchId: entity['id'],
                  team1: entity['team_1_name'],
                  team2: entity['team_2_name'])
              : screen = CricketMatchScoreScreen(
                  entity: entity,
                  status: status,
                );
          break;
        default:
          screen = CricketTournamentScoreBoardScreen(
              matchId: entity['id'],
              team1: entity['team_1_name'],
              team2: entity['team_2_name']);
      }
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Widget _buildListItem(
      Map<String, dynamic> entity, MatchesViewModel provider) {
    final matchDateTime = DateTime.parse(entity['datetime_field']);
    final now = DateTime.now();

    // final timeRemaining = matchDateTime.difference(now);
    // final hours = timeRemaining.inHours;
    // final minutes = timeRemaining.inMinutes % 60;
    // final formattedTimeRemaining = "${hours}h : ${minutes}m";
    final timeDifference = matchDateTime.difference(now);

    // Calculate time display
    String timeDisplay;
    Color timeColor;

    if (timeDifference.isNegative) {
      // Match is over/past
      final hoursAgo = timeDifference.inHours.abs();
      final minutesAgo = (timeDifference.inMinutes.abs() % 60);
      if (hoursAgo > 0) {
        timeDisplay = '${hoursAgo}h ${minutesAgo}m ago';
      } else {
        timeDisplay = '${minutesAgo}m ago';
      }
      timeColor = Colors.red;
    } else {
      // Match is upcoming
      final hours = timeDifference.inHours;
      final minutes = timeDifference.inMinutes % 60;
      if (hours > 0) {
        timeDisplay = '${hours}h ${minutes}m';
      } else {
        timeDisplay = '${minutes}m';
      }
      timeColor = Colors.deepPurple;
    }

    final matchStatus = entity['matchStatus'];
    bool status = provider.getStatus(matchStatus);

    return GestureDetector(
      onTap: () {
        smartPrint('ID-${entity['id']}');
        //***** implement scoreboard navigator screen *******//
        // matchStatus == 'Startedd' ? Navigator.push(context, MaterialPageRoute(builder: (context) => streamVideoWidget(),)) :

        bool isMatchOver =
            DateTime.parse(entity['datetime_field']).isBefore(DateTime.now());
        _navigateToScoreboard(context, entity, isMatchOver, status, provider);

        // OLD Code before preferred sport -------
        // formattedTimeRemaining.contains('-')
        //     ? Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => CricketTournamentScoreBoardScreen(
        //             matchId: entity['id'],
        //             team1: '',
        //             team2: '',
        //           ),
        //         ))
        //     : Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => CricketMatchScoreScreen(
        //             entity: entity,
        //             status: status,
        //           ),
        //         ),
        //       );
        // OLD Code before preferred sport -------
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 6),
        child: Container(
          // height: 150, // Removed fixed height to allow content to expand
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Circle Avatar with first letter
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            width: 50, // size of avatar
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple[400], // background color
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                      scale: animation, child: child);
                                },
                                child: Text(
                                  entity['team_1_name'] != null &&
                                          entity['team_1_name'].isNotEmpty
                                      ? entity['team_1_name'][0].toUpperCase()
                                      : '?',
                                  key: ValueKey(entity[
                                      'team_1_name']), // important for AnimatedSwitcher
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              entity['team_1_name'],
                              style: CustomTextStyles.titleMediumPoppins,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Expanded(
                    //     child: Column(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     CircleAvatar(
                    //       backgroundColor: Colors.transparent,
                    //       backgroundImage:
                    //           AssetImage(ImageConstant.imgEngRoundFlag),
                    //     ),
                    //     FittedBox(
                    //       fit: BoxFit.scaleDown,
                    //       child: Text(
                    //         entity['team_1_name'],
                    //         style: CustomTextStyles.titleMediumPoppins,
                    //       ),
                    //     )
                    //   ],
                    // )),
                    Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    entity['tournament_name'] ?? 'Match',
                                    style: CustomTextStyles.titleMediumPoppins,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    entity['matchStatus'],
                                    style: GoogleFonts.getFont('Poppins',
                                        fontSize: 12,
                                        color:
                                            entity['matchStatus'] == 'Started'
                                                ? Colors.black
                                                : Colors.red),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    // formattedTimeRemaining.contains('-')
                                    //     ? 'Match Over'
                                    //     : formattedTimeRemaining,
                                    // style: formattedTimeRemaining.contains('-')
                                    timeDisplay,
                                    style: timeColor == Colors.red
                                        ? CustomTextStyles.titleSmallRed700
                                        : CustomTextStyles
                                            .titleSmallDeeppurpleA400,
                                  ),
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    entity['datetime_field'],
                                    style: CustomTextStyles.titleSmallGray600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 2,
                            ),
                            // Match Type display
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getMatchTypeColor(
                                      entity['match_category'] ?? ''),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  entity['match_category'] ?? 'N/A',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Location: ${entity['location']}",
                                style: CustomTextStyles.titleSmallGray600,
                              ),
                            ),
                            // Umpire name
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Umpire: ${entity['umpire_name'] ?? 'N/A'}",
                                style: CustomTextStyles.titleSmallGray600,
                              ),
                            ),
                            // Court name
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "Court: ${entity['court_name'] ?? 'N/A'}",
                                style: CustomTextStyles.titleSmallGray600,
                              ),
                            ),
                          ],
                        )),

                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color:
                                  Colors.red[400], // different color for team 2
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                      scale: animation, child: child);
                                },
                                child: Text(
                                  entity['team_2_name'] != null &&
                                          entity['team_2_name'].isNotEmpty
                                      ? entity['team_2_name'][0].toUpperCase()
                                      : '?',
                                  key: ValueKey(entity['team_2_name']),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              entity['team_2_name'],
                              style: CustomTextStyles.titleMediumPoppins,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Expanded(
                    //     child: Column(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     CircleAvatar(
                    //       backgroundColor: Colors.transparent,
                    //       backgroundImage: AssetImage(
                    //           ImageConstant.imgShriLankaRoundFlag),
                    //     ),
                    //     FittedBox(
                    //       fit: BoxFit.scaleDown,
                    //       child: Text(
                    //         entity['team_2_name'],
                    //         style: CustomTextStyles.titleMediumPoppins,
                    //       ),
                    //     )
                    //   ],
                    // )),
                  ],
                ),
              ),
              // Edit button positioned at top right
              if (!widget.isEnrolled &&
                  provider.selectedMatchType == 'Completed')
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _navigateToEditScreen(context, entity),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
