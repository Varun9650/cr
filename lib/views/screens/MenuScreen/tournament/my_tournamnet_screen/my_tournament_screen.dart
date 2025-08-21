// MVVM Structure: View only - No direct API calls
// All API calls are handled through Repository -> ViewModel -> View
import 'package:cricyard/core/app_export.dart';
import 'package:cricyard/views/screens/MenuScreen/tournament/views/inviteTeam_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/custom_icon_button.dart';
import '../../../ReuseableWidgets/BottomAppBarWidget.dart';
import 'MyMatchById.dart';
import 'viewmodel/my_tournament_view_model.dart';
import 'widgets/EnrolledTournamentScreen.dart';
import 'widgets/createdTourScreen.dart';

class MyTournamnetScreen extends StatefulWidget {
  const MyTournamnetScreen({Key? key}) : super(key: key);

  @override
  _MyTournamentScreenState createState() => _MyTournamentScreenState();
}

class _MyTournamentScreenState extends State<MyTournamnetScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize data through ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<MyTournamentViewModel>(context, listen: false);
      provider.initializeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyTournamentViewModel>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
              backgroundColor: Colors.grey[200],
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomIconButton(
                  height: 32.adaptSize,
                  width: 32.adaptSize,
                  padding_f: EdgeInsets.all(6.h),
                  decoration: IconButtonStyleHelper.outlineIndigo,
                  onTap: () {
                    onTapBtnArrowleftone(context);
                  },
                  child: CustomImageView(
                    svgPath: ImageConstant.imgArrowLeft,
                  ),
                ),
              ),
              title: Text(
                "My Tournament",
                style: GoogleFonts.getFont('Poppins',
                    fontWeight: FontWeight.w500, color: Colors.black),
              ),
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: _buildTabview(context))),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(controller: _tabController, children: [
                  // createdTour(provider),
                  // enrolledTour(provider),

                  CreatedTournamentScreen(),
                  EnrolledTournamentScreen()
                ]),
          bottomNavigationBar: BottomAppBarWidget(),
        );
      },
    );
  }

  Widget _buildTabview(BuildContext context) {
    return Container(
      height: 56.v,
      width: 424.h,
      decoration: BoxDecoration(
        color:
            const Color(0xFF0096c7), //const Color.fromARGB(255, 24, 140, 236),
        // theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(
          10.h,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelPadding: EdgeInsets.zero,
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        dividerColor: Colors.transparent,
        unselectedLabelColor: Colors.white,
        unselectedLabelStyle: GoogleFonts.getFont('Poppins',
            color: Colors.white, fontWeight: FontWeight.w200, fontSize: 12),
        labelStyle: GoogleFonts.getFont('Poppins',
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        tabs: const [
          Tab(
            child: Text(
              "Created",
            ),
          ),
          Tab(
            child: Text(
              "Enrolled",
            ),
          ),
        ],
      ),
    );
  }

  Widget createdTour(MyTournamentViewModel provider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          // _buildScoreboardCardList(context, provider),
          _buildScoreboardCardGrid(context, provider, false),

          // SizedBox(height: 9.v),
          // Padding(
          //   padding: EdgeInsets.only(left: 33.h),
          //   child: Text(
          //     "Top stories",
          //     style: theme.textTheme.headlineSmall,
          //   ),
          // ),
          // SizedBox(height: 14.v),
          // _buildStackCreateFrom(context),
          // SizedBox(height: 16.v),
          // _buildNewsCard(context)
        ],
      ),
    );

    /// Section Widget for vertical grid (2 per row)
  }

  Widget _buildScoreboardCardGrid(
      BuildContext context, MyTournamentViewModel provider, bool isEnrolled) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // final tournaments = provider.myTournaments.reversed.toList();
    final tournaments = isEnrolled
        ? provider.enrolledTournaments.reversed.toList()
        : provider.myTournaments.reversed.toList();
    print("Tournaments: ${tournaments.length}");

    if (tournaments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: Text(
            isEnrolled
                ? "No tournaments enrolled yet."
                : "No tournaments created yet.",

            // "No tournaments created yet.",
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tournaments.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 cards per row
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.05, // Smaller card (more square, less tall)
        ),
        itemBuilder: (context, index) {
          final tournament = tournaments[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyMatchById(
                      tournament: tournament, isEnrolled: isEnrolled),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.18),
                    blurRadius: 5,
                    spreadRadius: 1.5,
                    offset: const Offset(1, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Centered image (smaller)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Image.asset(
                      ImageConstant.imgAward,
                      fit: BoxFit.contain,
                      width: 48,
                      height: 48,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tournament name and invite icon

                        // Tournament name and invite icon
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                tournament['tournament_name'] ?? "No Name",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                            if (!isEnrolled)
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          InviteTeamScreen(tournament['id']),
                                    ),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(left: 4.0),
                                  child: Icon(Icons.group_add,
                                      color: Colors.black, size: 18),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 6),
                        Text(
                          tournament['tournament_name'] ?? "No Name",
                          style: GoogleFonts.poppins(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Venue
                        Text(
                          tournament['venues'] ?? "No Venue",
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Date
                        Text(
                          tournament['dates'] ?? "No Date",
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // View Details button-style text
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "View Details",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget enrolledTour(MyTournamentViewModel provider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20,
          ),
          // _buildScoreboardCardList2(context, provider),
          _buildScoreboardCardGrid(context, provider, true),

          // SizedBox(height: 9.v),
          // Padding(
          //   padding: EdgeInsets.only(left: 33.h),
          //   child: Text(
          //     "Top stories",
          //     style: theme.textTheme.headlineSmall,
          //   ),
          // ),
          // SizedBox(height: 14.v),
          // _buildStackCreateFrom(context),
          // SizedBox(height: 16.v),
          // _buildNewsCard(context)
        ],
      ),
    );
  }

  /// Section Widget for where I have to show dynamically
  // Widget _buildScoreboardCardList(
  //     BuildContext context, MyTournamentViewModel provider, bool isEnrolled) {
  //   return Align(
  //     alignment: Alignment.centerRight,
  //     child: SizedBox(
  //       height: 150.v, // Adjust the height as needed
  //       child: provider.isLoading
  //           ? const Center(child: CircularProgressIndicator())
  //           : ListView.separated(
  //               padding: EdgeInsets.only(left: 20.h),
  //               scrollDirection: Axis.horizontal,
  //               separatorBuilder: (context, index) {
  //                 return SizedBox(
  //                   width: 12.h,
  //                 );
  //               },
  //               itemCount: provider.myTournaments.length,
  //               itemBuilder: (context, index) {
  //                 return ScoreboardcardlistItemWidget(
  //                   tournamentData:
  //                       provider.myTournaments.reversed.toList()[index],
  //                   onTap: () {
  //                     Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                             builder: (context) => MyMatchById(
  //                                   tournament: provider.myTournaments.reversed
  //                                       .toList()[index],
  //                                   isEnrolled: isEnrolled,
  //                                 )));
  //                   },
  //                   tournamentName: '',
  //                 );
  //               },
  //             ),
  //     ),
  //   );
  // }

  /// Section Widget for where I have to show dynamically for 2nd data of tournament
  // Widget _buildScoreboardCardList2(
  //     BuildContext context, MyTournamentViewModel provider, bool isEnrolled) {
  //   return Align(
  //     alignment: Alignment.centerRight,
  //     child: SizedBox(
  //       height: 150.v, // Adjust the height as needed
  //       child: provider.isLoading
  //           ? const Center(child: CircularProgressIndicator())
  //           : ListView.separated(
  //               padding: EdgeInsets.only(left: 20.h),
  //               scrollDirection: Axis.horizontal,
  //               separatorBuilder: (context, index) {
  //                 return SizedBox(
  //                   width: 12.h,
  //                 );
  //               },
  //               itemCount: provider.enrolledTournaments.length,
  //               itemBuilder: (context, index) {
  //                 final tournament = provider.enrolledTournaments[index];
  //                 final tournamentName = provider.getTournamentName(tournament);

  //                 // Debugging prints to check the tournament data and name
  //                 print("Tournament by user id $index data: $tournament");
  //                 print("Tournament by userid $index name: $tournamentName");

  //                 return ScoreboardcardlistItemWidget(
  //                   tournamentData: tournament,
  //                   onTap: () {
  //                     print('This is tournament data-> $tournament');
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                         builder: (context) => MyMatchById(
  //                           tournament: provider.enrolledTournaments[index],isEnrolled: isEnrolled,
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                   tournamentName: '',
  //                 );
  //               },
  //             ),
  //     ),
  //   );
  // }

  /// Section Widget
  // Widget _buildStackCreateFrom(BuildContext context) {
  //   return Align(
  //     alignment: Alignment.centerRight,
  //     child: SizedBox(
  //       height: 492.v,
  //       width: 395.h,
  //       child: Stack(
  //         alignment: Alignment.center,
  //         children: [
  //           Align(
  //             alignment: Alignment.centerLeft,
  //             child: Container(
  //               height: 492.v,
  //               width: 361.h,
  //               decoration: BoxDecoration(
  //                 color: appTheme.whiteA700.withOpacity(0.6),
  //                 border: Border(
  //                   bottom: BorderSide(
  //                     color: appTheme.gray300,
  //                     width: 1.h,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //           Align(
  //             alignment: Alignment.center,
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   // "Asia Cup 2023".toUpperCase(),
  //                   "Asia Cup 2023",
  //                   style: CustomTextStyles.labelLargeSFProTextErrorContainer,
  //                 ),
  //                 SizedBox(height: 6.v),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Padding(
  //                       padding: EdgeInsets.only(right: 7.h),
  //                       child: CustomImageView(
  //                         imagePath: ImageConstant.imgImage3,
  //                         height: 222.v,
  //                         width: 170.h,
  //                       ),
  //                     ),
  //                     CustomImageView(
  //                       imagePath: ImageConstant.imgImage3,
  //                       height: 222.v,
  //                       width: 170.h,
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // /// Section Widget
  // Widget _buildNewsCard(BuildContext context) {
  //   return Align(
  //     alignment: Alignment.centerRight,
  //     child: SizedBox(
  //       height: 230.v,
  //       width: 395.h,
  //       child: Stack(
  //         alignment: Alignment.center,
  //         children: [
  //           Align(
  //             alignment: Alignment.centerLeft,
  //             child: Container(
  //               height: 230.v,
  //               width: 361.h,
  //               decoration: BoxDecoration(
  //                 color: appTheme.whiteA700.withOpacity(0.6),
  //                 border: Border(
  //                   bottom: BorderSide(
  //                     color: appTheme.gray300,
  //                     width: 1.h,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  onTapBtnArrowleftone(BuildContext context) {
    Navigator.pop(context);
  }
}
