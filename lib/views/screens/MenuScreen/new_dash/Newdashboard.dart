// // ignore_for_file: deprecated_member_use

// import 'package:another_carousel_pro/another_carousel_pro.dart';
// import 'package:cricyard/core/app_export.dart';
// import 'package:cricyard/core/utils/sport_image_provider.dart';
// import 'package:cricyard/views/screens/Login%20Screen/view/decision.dart';
// import 'package:cricyard/views/screens/MenuScreen/live_cricket/live_cricket.dart';
// import 'package:cricyard/views/screens/ReuseableWidgets/new_drawer.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:path/path.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../../Entity/matches/Match/repository/Match_api_service.dart';
// import '../../../../providers/tab_navigation_provider.dart';
// import '../../ReuseableWidgets/BottomAppBarWidget.dart';
// import '../Notification/views/GetAllNotification.dart';
// import '../tournament/views/tournament_badminton_scorecard_screen.dart';

// class Newdashboard extends StatefulWidget {
//   Newdashboard({super.key});

//   @override
//   _NewdashboardState createState() => _NewdashboardState();
// }

// class _NewdashboardState extends State<Newdashboard> {
//   int _currentTab = 0;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   Map<String, dynamic> userData = {};
//   final MatchApiService apiService = MatchApiService();
//   List<Map<String, dynamic>> matchLive = [];
//   bool isLoading = false;

//   List<Map<String, dynamic>> dummyData2 = [
//     {
//       'title': 'India vs\nWest indies',
//       'imgPath': 'assets/images/img_image_2.png',
//       'color': Color(0xff1289bd)
//     },
//     {
//       'title': 'Australia \nTour',
//       'imgPath': 'assets/images/img_image_2.png',
//       'color': Color(0xff010593),
//     },
//     {
//       'title': 'England \nTour',
//       'imgPath': 'assets/images/img_image_1.png',
//       'color': Color(0xff930101),
//     },
//   ];

//   void getLoginState() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       isLogin = prefs.getBool('isLoggedIn') ?? false;
//     });
//     print("LoginState-$isLogin");
//     await Future.delayed(Duration(seconds: 2));
//     String? savedSport = prefs.getString('preferred_sport');
//     print('Saved Sport fetched on New Dashboard: $savedSport');
//   }

//   var isLogin = false;

//   int _selectedIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     getPreferredSport();

//     fetchMatchesLive();
//     getUserData();
//     getLoginState();
//     // fetchData();
//     print('user data is ..$userData');
//   }

//   String? preferredSport;

//   Future<void> getPreferredSport() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       preferredSport = prefs.getString('preferred_sport');
//     });
//   }

//   getUserData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var userdatastr = prefs.getString('userData');
//     if (userdatastr != null) {
//       try {
//         setState(() {
//           userData = json.decode(userdatastr);
//         });
//         print(userData['token']);
//       } catch (e) {
//         print("error is ..................$e");
//       }
//     }
//   }

//   Future<void> fetchMatchesLive() async {
//     setState(() {
//       isLoading = true;
//     });
//     try {
//       final fetchedEntities = await apiService.liveMatches();
//       print('live match is ${fetchedEntities.length}');
//       setState(() {
//         matchLive = fetchedEntities;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void setTab(int index) {
//     setState(() {
//       _currentTab = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.blue[400],
//         forceMaterialTransparency: true,
//         elevation: 2,
//         leading: IconButton(
//             onPressed: () {
//               _scaffoldKey.currentState?.openDrawer();
//             },
//             icon: const Icon(
//               Icons.menu,
//               color: Color(0xFF219ebc),
//               size: 30,
//             )),
//         title: Image.asset(
//           ImageConstant.imgImagegenSportlowWidth,
//           scale: 4,
//         ),
//         actions: [
//           SizedBox(
//               height: 26, child: Image.asset(ImageConstant.imgNotification3)),
//           const SizedBox(
//             width: 20,
//           ),
//           GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => GetAllNotification(),
//                 ),
//               );
//             },
//             child:
//                 SizedBox(height: 26, child: Image.asset(ImageConstant.imgBell)),
//           ),
//           SizedBox(
//             width: 10,
//           ),
//         ],
//       ),
//       key: _scaffoldKey,
//       //drawer: CustomDrawer(context: context),
//       drawer: NewDrawer(
//         context: context,
//       ),

//       bottomNavigationBar: BottomAppBarWidget(),

//       backgroundColor: Colors.grey[200],
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Text(
//               //   "Trending now",
//               //   style: CustomTextStyles.headlineSmallSemiBold,
//               // ),
//               _buildOngoingStack(context),
//               SizedBox(height: 10.v),
//               // _bannerWidget(),
//               SizedBox(height: 10.v),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: _slidingBannerWidget(),
//               ),
//               // SizedBox(height: 10.v),
//               // _customTabBar(),
//               // SizedBox(height: 10.v),
//               // _headlineWidget(),
//               // SizedBox(height: 10.v),
//               // // bottom card
//               // SizedBox(
//               //   height: 270,
//               //   child: ListView.builder(
//               //     scrollDirection: Axis.horizontal,
//               //     itemCount: dummyData2.length,
//               //     itemBuilder: (context, index) {
//               //       final data = dummyData2[index];
//               //       return _bottomCardWidget(
//               //           data['imgPath'], data['title'], data['color']);
//               //     },
//               //   ),
//               // ),
//               //_bottomCardWidget(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _loginReqWidget(BuildContext context) {
//     return Center(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             "Please Login to access this feature",
//             style: GoogleFonts.getFont('Poppins', color: Colors.black),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               InkWell(
//                   onTap: () {
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const DecisionScreen(),
//                         ));
//                   },
//                   child: Text(
//                     "Click here",
//                     style: GoogleFonts.getFont('Poppins', color: Colors.blue),
//                   )),
//               SizedBox(
//                 width: 6,
//               ),
//               Text(
//                 "to login ",
//                 style: GoogleFonts.getFont('Poppins', color: Colors.black),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // /// Section Widget
//   Widget _buildOngoingStack(BuildContext context) {
//     return DottedBorder(
//         color: Colors.purple,
//         borderType: BorderType.RRect,
//         radius: const Radius.circular(12),
//         dashPattern: const [8, 4],
//         padding: const EdgeInsets.all(6),
//         child: SizedBox(
//             height: 260,
//             child: !isLogin
//                 ? _loginReqWidget(context)
//                 : isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : (matchLive.isEmpty
//                         ? Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   preferredSport == 'Badminton'
//                                       ? Icons
//                                           .sports_tennis // or use a custom badminton icon if available
//                                       : Icons.sports_cricket,
//                                   color: Colors.purple,
//                                   size: 60,
//                                 ),
//                                 const SizedBox(height: 16),
//                                 Text(
//                                   "No Live Match",
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 22,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.purple,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   "Stay tuned! Live matches will appear here.",
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 15,
//                                     color: Colors.grey[700],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           )
//                         : ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: matchLive.length,
//                             itemBuilder: (context, index) {
//                               final data = matchLive[index];
//                               if (preferredSport == 'Badminton') {
//                                 // 🏸 Badminton UI
//                                 return badmintonMatchCard(
//                                   context,
//                                   matchId: data['id'],
//                                   team1Name: data['team_1_name'] ?? 'Team 1',
//                                   team2Name: data['team_2_name'] ?? 'Team 2',
//                                   courtName: data['court_name'] ?? '',
//                                   tournamentName: data['tournament_name'] ?? '',
//                                   umpireName: data['umpire_name'] ?? '',
//                                 );
//                               } else {
//                                 // 🏏 Cricket UI
//                                 return _myContainer(context,
//                                     matchTitle: data['tournament_name'],
//                                     team1: data['team_1_name'],
//                                     team1Status: data['team1Status'] ?? 'nope',
//                                     team2: data['team_2_name'],
//                                     team1S: data['extn1'] ?? '0',
//                                     team2S: data['extn1'] ?? '0',
//                                     team1Wkts: data['extn1'] ?? '0',
//                                     team2Wkts: data['extn1'] ?? '0',
//                                     team1Overs: data['extn1'] ?? '0',
//                                     team2Overs: data['extn1'] ?? '0',
//                                     team1Crr: data['extn1'] ?? '0',
//                                     tossBy: data['extn1'] ?? '0',
//                                     team1Logo: data['team1Logo'] ??
//                                         ImageConstant.imgEngRoundFlag,
//                                     team2Logo: data['team2Logo'] ??
//                                         ImageConstant.imgShriLankaRoundFlag);
//                               }
//                             }))));
//   }

//   Widget badmintonMatchCard(
//     BuildContext context, {
//     required int matchId,
//     required String team1Name,
//     required String team2Name,
//     required String courtName,
//     required String tournamentName,
//     required String umpireName,
//   }) {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => TournamentBadmintonScorecardScreen(
//               matchId: matchId,
//             ),
//           ),
//         );
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: SizedBox(
//           width: MediaQuery.of(context).size.width * 0.87,
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.15),
//                   blurRadius: 6,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Tournament Name (Top Bar)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 12.0, vertical: 10),
//                   child: Text(
//                     tournamentName,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ),
//                 Divider(color: Colors.grey[200]),

//                 // Teams Section
//                 Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // Team 1
//                       Text(
//                         team1Name,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),

//                       const Text(
//                         "VS",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.redAccent,
//                         ),
//                       ),

//                       // Team 2
//                       Text(
//                         team2Name,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         textAlign: TextAlign.end,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),

//                 Divider(color: Colors.grey[200]),

//                 // Court Name
//                 ListTile(
//                   dense: true,
//                   contentPadding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
//                   leading: const Icon(Icons.sports_tennis,
//                       size: 20, color: Colors.blueGrey),
//                   title: Text(
//                     courtName,
//                     style: const TextStyle(fontSize: 14, color: Colors.black87),
//                   ),
//                 ),

//                 // Umpire Name
//                 ListTile(
//                   dense: true,
//                   contentPadding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
//                   leading:
//                       const Icon(Icons.person, size: 20, color: Colors.orange),
//                   title: Text(
//                     "Umpire: $umpireName",
//                     style: const TextStyle(fontSize: 14, color: Colors.black87),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _myContainer(BuildContext context,
//       {required String matchTitle,
//       required team1,
//       required team1Status,
//       required team2,
//       required team1S,
//       required team2S,
//       required team1Wkts,
//       required team2Wkts,
//       required team1Overs,
//       required team2Overs,
//       required team1Crr,
//       required tossBy,
//       required team1Logo,
//       required team2Logo}) {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => LiveCricketScreen(),
//             ));
//       },
//       child: Column(
//         children: [
//           // top section
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: SizedBox(
//               width: MediaQuery.of(context).size.width * 0.87,
//               child: Container(
//                 width: double.infinity,
//                 height: 240,
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     color: Colors.white),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // top section
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10.0,
//                       ),
//                       child: SizedBox(
//                         height: 55,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               matchTitle,
//                               style: CustomTextStyles.titleMediumBlack900Medium,
//                             ),
//                             Text(
//                               '$team1 vs $team2',
//                               style: CustomTextStyles.titleMediumBlack900Medium,
//                             ),
//                             Row(
//                               children: [
//                                 Text("Live",
//                                     style: CustomTextStyles.titleSmallGray600),
//                                 const SizedBox(
//                                   width: 10,
//                                 ),
//                                 Image.asset(
//                                   ImageConstant.imgLive,
//                                   scale: 16,
//                                 )
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Divider(
//                       color: Colors.grey[200],
//                     ),
//                     // middle most section
//                     SizedBox(
//                       height: 140,
//                       width: double.infinity,
//                       child: Row(
//                         children: [
//                           Expanded(
//                               flex: 3,
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   ListTile(
//                                       leading: CircleAvatar(
//                                         backgroundColor: Colors.transparent,
//                                         backgroundImage: AssetImage(team1Logo),
//                                       ),
//                                       title: SizedBox(
//                                         width: 130,
//                                         child: FittedBox(
//                                           fit: BoxFit.scaleDown,
//                                           child: Text(
//                                             team1,
//                                             style: CustomTextStyles
//                                                 .titleMediumBlack900Medium,
//                                           ),
//                                         ),
//                                       ),
//                                       trailing: SizedBox(
//                                         width: 40,
//                                         child: team1Status == 'Bat'
//                                             ? FittedBox(
//                                                 fit: BoxFit.scaleDown,
//                                                 child: RichText(
//                                                     text: TextSpan(
//                                                         text:
//                                                             "$team1S- $team1Wkts",
//                                                         style: CustomTextStyles
//                                                             .titleMedium18,
//                                                         children: const [
//                                                       TextSpan(
//                                                           text: '*',
//                                                           style: TextStyle(
//                                                               color:
//                                                                   Colors.red)),
//                                                     ])),
//                                               )
//                                             : const FittedBox(
//                                                 fit: BoxFit.scaleDown,
//                                                 child: Text(
//                                                   'Yet to Bat',
//                                                   style: TextStyle(
//                                                       color: Colors.grey,
//                                                       fontSize: 16),
//                                                 ),
//                                               ),
//                                       )),
//                                   ListTile(
//                                       leading: CircleAvatar(
//                                         backgroundImage: AssetImage(team2Logo),
//                                         backgroundColor: Colors.transparent,
//                                       ),
//                                       title: SizedBox(
//                                         width: 130,
//                                         child: FittedBox(
//                                           fit: BoxFit.scaleDown,
//                                           child: Text(
//                                             team2,
//                                             style: CustomTextStyles
//                                                 .titleMediumBlack900Medium,
//                                           ),
//                                         ),
//                                       ),
//                                       trailing: SizedBox(
//                                         width: 40,
//                                         child: team1Status == 'Ball'
//                                             ? FittedBox(
//                                                 fit: BoxFit.scaleDown,
//                                                 child: RichText(
//                                                     text: TextSpan(
//                                                         text:
//                                                             "$team2S -$team2Wkts",
//                                                         style: CustomTextStyles
//                                                             .titleMedium18,
//                                                         children: const [
//                                                       TextSpan(
//                                                           text: '*',
//                                                           style: TextStyle(
//                                                               color:
//                                                                   Colors.red)),
//                                                     ])),
//                                               )
//                                             : const FittedBox(
//                                                 fit: BoxFit.scaleDown,
//                                                 child: Text(
//                                                   'Yet to bat',
//                                                   style: TextStyle(
//                                                       color: Colors.grey,
//                                                       fontSize: 16),
//                                                 ),
//                                               ),
//                                       )),
//                                 ],
//                               )),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: VerticalDivider(
//                               color: Colors.grey[200],
//                             ),
//                           ),
//                           Expanded(
//                               child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 team1Status == 'Bat'
//                                     ? "($team2Overs)Overs"
//                                     : "($team1Overs)Overs",
//                                 style: CustomTextStyles.titleMediumMedium,
//                               ),
//                               Text(
//                                 "$team1Crr crr",
//                                 style: const TextStyle(
//                                     color: Colors.grey,
//                                     fontWeight: FontWeight.w700,
//                                     fontSize: 14),
//                               )
//                             ],
//                           ))
//                         ],
//                       ),
//                     ),
//                     Divider(
//                       color: Colors.grey[200],
//                     ),
//                     // bottom section
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10.0, vertical: 10),
//                       child: Text(
//                         tossBy,
//                         style: CustomTextStyles.titleSmallGray600,
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _bannerWidget() {
//     return Container(
//       height: 120,
//       width: double.infinity,
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           gradient: const LinearGradient(
//             colors: [
//               Color(0xff3efafa),
//               Color(0xff52ecfd),
//               Color(0xffa058f1),
//               Color(0xff913bf3),
//               Color(0xff9a3bf3)
//             ],
//           )),
//       child: Row(
//         children: [
//           Expanded(
//               child: Padding(
//             padding: const EdgeInsets.only(left: 8.0),
//             child: SizedBox(
//                 height: 80.v,
//                 child: Image.asset(
//                   "assets/images/image_65.png",
//                   scale: 4,
//                 )),
//           )),
//           Expanded(
//               flex: 2,
//               child: SizedBox(
//                   height: double.infinity,
//                   width: double.infinity,
//                   child: Image.asset(
//                     "assets/images/image_204.png",
//                     fit: BoxFit.fill,
//                   ))),
//           Expanded(
//               flex: 2,
//               child: Stack(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(left: 18.0),
//                     child: Align(
//                         alignment: Alignment.bottomRight,
//                         child: SizedBox(
//                             height: 240.v,
//                             child: Image.asset(
//                               "assets/images/image_4.png",
//                               color: Colors.black.withOpacity(0.2),
//                               scale: 1,
//                               fit: BoxFit.cover,
//                             ))),
//                   ),
//                   Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text(
//                           "FOR STATS, LATEST \n SCORE & NEWS",
//                           style: TextStyle(
//                               fontSize: 14, fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(
//                           height: 8.v,
//                         ),
//                         GestureDetector(
//                           onTap: () {},
//                           child: Container(
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                                 color: Colors.black.withOpacity(0.4),
//                                 borderRadius: BorderRadius.circular(20)),
//                             child: const Text(
//                               "CLICK HERE",
//                               style: TextStyle(fontSize: 10),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 ],
//               )),
//         ],
//       ),
//     );
//   }

//   Widget _slidingBannerWidget() {
//     return SizedBox(
//       height: 400,
//       width: double.infinity,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: AnotherCarousel(
//           images: [
//             AssetImage(
//               SportImageProvider.getNewsImage(preferredSport),
//             ),
//             AssetImage(
//               SportImageProvider.getNewsImage(preferredSport),
//             ),
//             AssetImage(
//               SportImageProvider.getNewsImage(preferredSport),
//             ),
//           ],
//           borderRadius: true,
//           radius: const Radius.circular(4),
//           autoplay: false,
//           dotColor: Colors.grey,
//           dotIncreasedColor: Colors.yellowAccent,
//           indicatorBgPadding: 1,
//           dotSize: 6,
//         ),
//       ),
//     );
//   }

//   Widget _customTabBar() {
//     return Container(
//       height: 70,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           _tabItem(
//             index: 0,
//             selectedIndex: _selectedIndex,
//             onTap: () {
//               setState(() {
//                 _selectedIndex = 0;
//               });
//             },
//             text: "Top Headline",
//           ),
//           _tabItem(
//             index: 1,
//             selectedIndex: _selectedIndex,
//             onTap: () {
//               setState(() {
//                 _selectedIndex = 1;
//               });
//             },
//             text: "Most Popular",
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _tabItem(
//       {required int index,
//       selectedIndex,
//       required VoidCallback onTap,
//       required String text}) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Container(
//             decoration: BoxDecoration(
//                 color:
//                     index == selectedIndex ? Colors.yellow : Colors.transparent,
//                 borderRadius: BorderRadius.circular(12)),
//             child: Center(
//               child: Text(text,
//                   style: index == selectedIndex
//                       ? CustomTextStyles.titleSmallPoppinsBlack900
//                       : CustomTextStyles.titleSmallGray600),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _headlineWidget() {
//     return Container(
//       height: 160,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//               child: Padding(
//             padding: const EdgeInsets.all(4.0),
//             child: ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: SizedBox(
//                     height: 100,
//                     child: Image.asset(
//                       "assets/images/image.png",
//                       fit: BoxFit.cover,
//                     ))),
//           )),
//           Expanded(
//               flex: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     const Text(
//                       "hey how are you,hey how are you,hey how are you,hey how are you,",
//                       style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold),
//                     ),
//                     Row(
//                       children: [
//                         const Text(
//                           "PTI",
//                           style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(
//                           width: 6.h,
//                         ),
//                         const Text(
//                           "•",
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                         SizedBox(
//                           width: 6.h,
//                         ),
//                         const Text(
//                           "1 hour ago",
//                           style: TextStyle(
//                               color: Colors.grey,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               )),
//         ],
//       ),
//     );
//   }

//   Widget _bottomCardWidget(String imgPath, title, Color color) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         width: 200,
//         decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(12),
//             image: const DecorationImage(
//                 image: AssetImage(
//                   "assets/images/image_2.png",
//                 ),
//                 fit: BoxFit.cover)),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               radius: 50,
//               child: Image.asset(imgPath),
//             ),
//             SizedBox(
//               height: 10.v,
//             ),
//             Text(
//               "$title",
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _imageSliderBannerWidget() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         height: 400,
//         width: double.infinity,
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12), color: Colors.red),
//         child: ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.asset(
//               "assets/images/image_195.png",
//               fit: BoxFit.fill,
//             )),
//       ),
//     );
//   }

//   void _onTabChange(int index) {
//     if (_currentTab == 1 || _currentTab == 2) {
//       FocusManager.instance.primaryFocus?.unfocus();
//     }
//     Provider.of<TabNavigationProvider>(context as BuildContext, listen: false)
//         .updateTabs(_currentTab);
//     setState(() {
//       _currentTab = index;
//     });
//   }

//   Future<bool> _onBackPress() {
//     if (_currentTab == 0) {
//       return Future.value(true);
//     } else {
//       int lastTab = Provider.of<TabNavigationProvider>(context as BuildContext,
//               listen: false)
//           .lastTab;
//       Provider.of<TabNavigationProvider>(context as BuildContext, listen: false)
//           .removeLastTab();
//       setTab(lastTab);
//     }
//     return Future.value(false);
//   }
// }

// ignore_for_file: deprecated_member_use

import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:cricyard/core/app_export.dart';
import 'package:cricyard/core/utils/sport_image_provider.dart';
import 'package:cricyard/views/screens/Login%20Screen/view/decision.dart';
import 'package:cricyard/views/screens/MenuScreen/live_cricket/live_cricket.dart';
import 'package:cricyard/views/screens/ReuseableWidgets/new_drawer.dart';
import 'package:cricyard/views/screens/MenuScreen/teams_screen/teamView/my_teams_screen.dart';
import 'package:cricyard/views/screens/MenuScreen/tournament/my_tournamnet_screen/widgets/EnrolledTournamentScreen.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Entity/matches/Match/repository/Match_api_service.dart';
import '../../ReuseableWidgets/BottomAppBarWidget.dart';
import '../Notification/views/GetAllNotification.dart';
import '../tournament/my_tournamnet_screen/my_tournament_screen.dart';
import '../tournament/views/tournament_badminton_scorecard_screen.dart';

class Newdashboard extends StatefulWidget {
  Newdashboard({super.key});

  @override
  _NewdashboardState createState() => _NewdashboardState();
}

class _NewdashboardState extends State<Newdashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, dynamic> userData = {};
  final MatchApiService apiService = MatchApiService();
  List<Map<String, dynamic>> matchLive = [];
  bool isLoading = false;
  bool isLogin = false;
  String? preferredSport;

  @override
  void initState() {
    super.initState();
    getPreferredSport();
    fetchMatchesLive();
    getUserData();
    getLoginState();
  }

  Future<void> getPreferredSport() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      preferredSport = prefs.getString('preferred_sport');
    });
  }

  void getLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLogin = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userdatastr = prefs.getString('userData');
    if (userdatastr != null) {
      try {
        setState(() {
          userData = json.decode(userdatastr);
        });
      } catch (e) {
        print("Error parsing user data: $e");
      }
    }
  }

  Future<void> fetchMatchesLive() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedEntities = await apiService.liveMatches();
      setState(() {
        matchLive = fetchedEntities;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildModernAppBar(),
      key: _scaffoldKey,
      drawer: NewDrawer(context: context),
      bottomNavigationBar: BottomAppBarWidget(),
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchMatchesLive();
          await getUserData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              SizedBox(height: 20.v),
              _buildLiveMatchesSection(),
              SizedBox(height: 20.v),
              if (isLogin) ...[
                _buildQuickActionsSection(),
                SizedBox(height: 20.v),
              ],
              _buildNewsSection(),
              SizedBox(height: 40.v),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0096c7),
              const Color(0xFF219ebc),
              const Color(0xFF023e8a),
            ],
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu, color: Colors.white, size: 24),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              preferredSport == 'Badminton'
                  ? Icons.sports_tennis
                  : Icons.sports_cricket,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            preferredSport ?? 'Badminton',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        if (isLogin) ...[
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GetAllNotification()),
                );
              },
              icon: const Icon(Icons.notifications,
                  color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0096c7),
            const Color(0xFF023e8a),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0096c7).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  preferredSport == 'Badminton'
                      ? Icons.sports_tennis
                      : Icons.sports_cricket,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLogin ? "Welcome back!" : "Welcome to GenSport!",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isLogin && userData.isNotEmpty)
                      Text(
                        userData['fullName'] ?? 'Player',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (!isLogin) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DecisionScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0096c7),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Login Now",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLiveMatchesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Live Matches",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "LIVE",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!isLogin)
            _buildLoginPrompt()
          else if (isLoading)
            _buildLoadingState()
          else if (matchLive.isEmpty)
            _buildNoLiveMatches()
          else
            _buildLiveMatchesList(),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Login to view live matches",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DecisionScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0096c7),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Login",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0096c7)),
        ),
      ),
    );
  }

  Widget _buildNoLiveMatches() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              preferredSport == 'Badminton'
                  ? Icons.sports_tennis
                  : Icons.sports_cricket,
              size: 48,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No Live Matches",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Stay tuned! Live matches will appear here.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMatchesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: matchLive.length,
      itemBuilder: (context, index) {
        final data = matchLive[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: preferredSport == 'Badminton'
              ? _buildBadmintonMatchCard(data)
              : _buildCricketMatchCard(data),
        );
      },
    );
  }

  Widget _buildBadmintonMatchCard(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TournamentBadmintonScorecardScreen(
                  matchId: data['id'],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "LIVE",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      data['tournament_name'] ?? 'Tournament',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0096c7).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.sports_tennis,
                              size: 32,
                              color: const Color(0xFF0096c7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['team_1_name'] ?? 'Team 1',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              "VS",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Live",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF023e8a).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.sports_tennis,
                              size: 32,
                              color: const Color(0xFF023e8a),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['team_2_name'] ?? 'Team 2',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.sports_tennis,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                data['court_name'] ?? 'Court',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.person,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Umpire: ${data['umpire_name'] ?? 'TBD'}",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCricketMatchCard(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LiveCricketScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data['tournament_name'] ?? 'Tournament',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "LIVE",
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor:
                                const Color(0xFF0096c7).withOpacity(0.1),
                            child: Image.asset(
                              data['team1Logo'] ??
                                  ImageConstant.imgEngRoundFlag,
                              width: 40,
                              height: 40,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['team_1_name'] ?? 'Team 1',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${data['extn1'] ?? '0'}/${data['extn1'] ?? '0'}",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0096c7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              "VS",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Live",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor:
                                const Color(0xFF023e8a).withOpacity(0.1),
                            child: Image.asset(
                              data['team2Logo'] ??
                                  ImageConstant.imgShriLankaRoundFlag,
                              width: 40,
                              height: 40,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['team_2_name'] ?? 'Team 2',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${data['extn1'] ?? '0'}/${data['extn1'] ?? '0'}",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF023e8a),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text("Overs",
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.grey[600])),
                          Text("${data['extn1'] ?? '0'}",
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87)),
                        ],
                      ),
                      Column(
                        children: [
                          Text("CRR",
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.grey[600])),
                          Text("${data['extn1'] ?? '0'}",
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87)),
                        ],
                      ),
                      Column(
                        children: [
                          Text("Toss",
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.grey[600])),
                          Text(data['extn1'] ?? 'TBD',
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quick Actions",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.people,
                  title: "My Teams",
                  subtitle: "Manage teams",
                  color: const Color(0xFF0096c7),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyTeamScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.emoji_events,
                  title: "Tournaments",
                  subtitle: "View tournaments",
                  color: const Color(0xFF023e8a),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyTournamnetScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Latest News",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AnotherCarousel(
                images: [
                  AssetImage(SportImageProvider.getNewsImage(preferredSport)),
                  AssetImage(SportImageProvider.getNewsImage(preferredSport)),
                  AssetImage(SportImageProvider.getNewsImage(preferredSport)),
                ],
                borderRadius: true,
                radius: const Radius.circular(16),
                autoplay: true,
                dotColor: Colors.grey,
                dotIncreasedColor: const Color(0xFF0096c7),
                indicatorBgPadding: 1,
                dotSize: 8,
                dotSpacing: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
