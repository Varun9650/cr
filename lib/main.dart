import 'package:cricyard/Entity/absent_hurt/Absent_hurt/viewmodel/absent_hurt_viewmodel.dart';
import 'package:cricyard/Entity/add_tournament/My_Tournament/viewmodel/My_Tournament_viewmodel.dart';
import 'package:cricyard/Entity/contact_us/Contact_us/viewmodel/Contact_us_viewmodel.dart';
import 'package:cricyard/Entity/cricket/Cricket/viewmodel/Cricket_viewmodel.dart';
import 'package:cricyard/Entity/event_management/Event_Management/viewmodel/Event_Management_viewmodel.dart';
import 'package:cricyard/Entity/feedback_form/FeedBack_Form/viewmodel/FeedBack_Form_viewmodel.dart';
import 'package:cricyard/Entity/followers/Followers/viewmodel/Followers_viewmodel.dart';
import 'package:cricyard/Entity/friends/Find_Friends/viewmodel/Find_Friends_viewmodel.dart';
import 'package:cricyard/Entity/highlights/Highlights/viewmodel/Highlights_viewmodel.dart';
import 'package:cricyard/Entity/leaderboard/LeaderBoard/viewmodel/LeaderBoard_viewmodel.dart';
import 'package:cricyard/Entity/live_cricket_match/Live_Cricket/viewmodel/Live_Cricket_viewmodel.dart';
import 'package:cricyard/Entity/live_score_update/Live_Score_Update/viewmodel/Live_Score_viewmodel.dart';
import 'package:cricyard/Entity/matches/Match/viewmodel/Match_viewmodel.dart';
import 'package:cricyard/Entity/matches/Match_Setting/viewmodel/Match_Setting_viewmodel.dart';
import 'package:cricyard/Entity/matches/Matches/viewmodels/Matches_viewmodel.dart';
import 'package:cricyard/Entity/matches/Start_Match/viewmodel/Start_Match_viewmodel.dart';
import 'package:cricyard/Entity/obstructing_the_field/Obstructing_The_Field/viewmodel/Obstructing_The_Field_viewmodel.dart';
import 'package:cricyard/Entity/player/Player_Detail/viewmodel/Player_Detail_viewmodel.dart';
import 'package:cricyard/Entity/retired/Retired/viewmodels/Retired_viewmodel.dart';
import 'package:cricyard/Entity/retired_out/Retired_out/viewmodel/Retired_out_viewmodel.dart';
import 'package:cricyard/Entity/runs/Runs/viewmodel/Runs_viewmodel.dart';
import 'package:cricyard/Entity/runs/Score_board/viewmodel/Score_board_viewmodel.dart';
import 'package:cricyard/Entity/select_team/Select_Team/viewmodel/Select_Team_viewmodel.dart';
import 'package:cricyard/Entity/start_inning/Start_inning/viewmodels/Start_inning_viewmodel.dart';
import 'package:cricyard/Entity/team/Teams/viewmodels/Teams_viewmodel.dart';
import 'package:cricyard/notifications/service/notification_service.dart';
import 'package:cricyard/views/screens/MenuScreen/Basketball/viewmodel/basketballMatchScoreProvider.dart';
import 'package:cricyard/views/screens/MenuScreen/Football/viewmodel/footballMatchScoreProvider.dart';
import 'package:cricyard/views/screens/MenuScreen/Hockey/viewmodel/hockeyMatchScoreProvider.dart';
import 'package:cricyard/views/screens/MenuScreen/Tennis/viewmodel/tennisDoublesScoreProvider.dart';
import 'package:cricyard/views/screens/MenuScreen/Tennis/viewmodel/tennisSinglesScoreProvider.dart';
import 'package:cricyard/views/screens/MenuScreen/master/Roles/viewmodel/roles_view_model.dart';
import 'package:cricyard/views/screens/MenuScreen/teams_screen/teamViewModel/team_view_model.dart';
import 'package:cricyard/views/screens/MenuScreen/tournament/my_tournamnet_screen/points_table/points_table_view_model.dart';
import 'package:cricyard/views/screens/MenuScreen/tournament/my_tournamnet_screen/viewmodel/my_tournament_view_model.dart';
import 'package:cricyard/views/screens/MenuScreen/tournament/my_tournamnet_screen/viewmodel/matches_view_model.dart';
import 'package:cricyard/views/screens/MenuScreen/tournament/my_tournamnet_screen/viewmodel/edit_games_view_model.dart';
import 'package:cricyard/views/screens/MenuScreen/tournament/my_tournamnet_screen/bracket/bracket_view_model.dart';
import 'package:cricyard/views/screens/MenuScreen/tournament/viewmodel/invite_team_view_model.dart';
import 'package:cricyard/views/screens/MenuScreen/tournament/viewmodel/tournament_badminton_view_model.dart';
import 'package:cricyard/views/screens/MenuScreen/tournament/viewmodel/schedule_match_view_model.dart';
import 'package:cricyard/Entity/BadmintonCourt/viewmodels/court_viewmodel.dart';
import 'package:cricyard/Entity/UmpireManagement/viewmodels/umpire_viewmodel.dart';
import 'package:cricyard/views/screens/SportSelection/repository/sportSelectionApiService.dart';
import 'package:cricyard/views/screens/practice_match/practiceViewmodel/PracticeMatchViewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/utils/logger.dart';
import 'core/utils/smart_print.dart';
import 'core/utils/size_utils.dart';
import 'notifications/view model/notifications_view_model.dart';
import 'routes/app_routes.dart';
import 'theme/theme_helper.dart';
import 'views/screens/MenuScreen/master/UserRoleManagement/viewmodel/user_role_view_model.dart';
import 'views/screens/MenuScreen/merch/provider/product_data_provider.dart';
import 'views/screens/MenuScreen/pickup_management/Pickup_Management/viewmodel/pickup_management_viewmodel.dart';

// lib\views\screens\practice_match\viewmodel\practice_matchview_model.dart
//const simplePeriodicTask = "simplePeriodicTask";
// void showNotification(String v, FlutterLocalNotificationsPlugin flpe) async {
//   var android = const AndroidNotificationDetails(
//     'channel id',
//     'channel NAME',
//     priority: Priority.high,
//     importance: Importance.max,
//   );
//   var iOS = const IOSNotificationDetails();
//   var platform = NotificationDetails(android: android, iOS: iOS);
//   await flp.show(0, 'CloudnSure', '$v', platform, payload: 'VIS \n $v');
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  ThemeHelper().changeTheme('primary');

// Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Request notification permissions
  final notificationViewModel = NotificationViewModel();
  notificationViewModel.requestNotificationPermissions();
  notificationViewModel.getReadableNotifications();

  // Initialize logger and show app startup
  Logger.info('genSport app starting...');
  Logger.debug('Debug mode enabled');

  // Test smart print functions
  smartPrint('App initialized with smart print');
  smartPrintSuccess('Smart print is working!');
  smartPrintDebug('Debug mode enabled with smart print');

  //Request notification permissions
  // await _requestNotificationPermissions();

  // await Workmanager().initialize(callbackDispatcher);
  // await Workmanager().registerPeriodicTask(
  //   "5",
  //   simplePeriodicTask,
  //   existingWorkPolicy: ExistingWorkPolicy.replace,
  //   frequency: const Duration(minutes: 15),
  //   initialDelay: const Duration(seconds: 5),
  //   constraints: Constraints(networkType: NetworkType.connected),
  // );
  // runApp(MyApp());

  runApp(MultiProvider(
    providers: [
      // ChangeNotifierProvider(
      //   create: (context) => NotificationViewModel(),
      // ),

      ChangeNotifierProvider(
        create: (context) => ProductProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => PracticeMatchviewModel(),
      ),
      ChangeNotifierProvider(
        create: (_) => AbsentHurtProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => ContactUsProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => CricketProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => MyTournamentProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => EventManagementProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => FeedbackProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => FollowersProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => FindFriendsProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => HighlightsProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => LeaderboardProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => LiveCricketProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => LiveScoreUpdateProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => MatchProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => MatchSettingProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => MatchesProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => StartMatchProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => ObstructingTheFieldProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => PlayerDetailProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => RetiredEntitiesProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => RetiredOutProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => RunsEntitiesProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => ScoreBoardProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => SelectTeamProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => StartInningProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => TeamsProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => TeamViewModel(),
      ),
      ChangeNotifierProvider(
        create: (_) => MyTournamentViewModel(),
      ),
      ChangeNotifierProvider(
        create: (_) => InviteTeamViewModel(),
      ),
      ChangeNotifierProvider(
        create: (_) => TournamentBadmintonViewModel(),
      ),
      ChangeNotifierProvider(
        create: (_) => MatchesViewModel(),
      ),
      ChangeNotifierProvider(
        create: (_) => EditGamesViewModel(),
      ),
      ChangeNotifierProvider(
        create: (_) => ScheduleMatchViewModel(),
      ),
      ChangeNotifierProvider(
        create: (_) => SportSelectionProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => BracketViewModel(),
      ),
      ChangeNotifierProvider(
        create: (_) => PointsTableViewModel(),
      ),
      ChangeNotifierProvider(
        create: (_) => FootballMatchScoreProvider(
          hostTeam: "hostTeam",
          visitorTeam: "visitorTeam",
          tossWinner: "tossWinner",
          optedTo: "optedTo",
          matchId: 1,
          // 1 is dummy number above
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => HockeyMatchScoreProvider(
          hostTeam: "hostTeam",
          visitorTeam: "visitorTeam",
          tossWinner: "tossWinner",
          optedTo: "optedTo",
          matchId: 1,
          // 1 is dummy number above
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => BasketballMatchScoreProvider(
          hostTeam: "Lakers",
          visitorTeam: "Bulls",
          tossWinner: "tossWinner",
          optedTo: "Bat",
          matchId: 101,
        ), // Your screen widget
      ),
      ChangeNotifierProvider(
        create: (_) => TennisScoreProvider(
          player1: "player10",
          player2: "player20",
          matchId: 101,
        ), // Your screen widget
      ),
      ChangeNotifierProvider(
        create: (_) => TennisDoublesProvider(
          team1: ["Player AA", "Player BB"],
          team2: ["Player CC", "Player DD"],
          matchId: 102,
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => PickupManagementProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => CourtViewModel(),
      ),
      ChangeNotifierProvider(
        create: (_) => UmpireViewModel(),
      ),

      ChangeNotifierProvider(
        create: (_) => RolesViewModel(),
      ),
      ChangeNotifierProvider(
        create: (_) => UserRoleViewModel(),
      ),
    ],
    child: MyApp(),
  ));
}

// Future<void> _requestNotificationPermissions() async {
//   final status = await Permission.notification.request();
//   if (status.isGranted) {
//     print('Notification permissions granted');
//   } else {
//     print('Notification permissions denied');
//   }
// }

// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     FlutterLocalNotificationsPlugin flp = FlutterLocalNotificationsPlugin();
//     var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
//     var iOS = const IOSInitializationSettings();
//     var initSettings = InitializationSettings(android: android, iOS: iOS);
//     flp.initialize(initSettings);
//     String baseUrl = ApiConstants.baseUrl;
//     final apiUrl = '$baseUrl/user_notifications/get_unseen';
//     final token = await TokenManager.getToken();
//     final response = await http.get(
//       Uri.parse(apiUrl),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//     );
//     if (response.statusCode <= 209) {
//       final List<dynamic> data = jsonDecode(response.body);
//       List<Map<String, dynamic>> notifications =
//           data.cast<Map<String, dynamic>>();
//       notifications.forEach((element) async {
//         showNotification(element['notification'], flp);
//         int id = element['id'];
//         final apiUrl2 = '$baseUrl/user_notifications/seen_success/$id';
//         final response2 = await http.get(
//           Uri.parse(apiUrl2),
//           headers: {
//             'Authorization': 'Bearer $token',
//             'Content-Type': 'application/json',
//           },
//         );
//         if (response2.statusCode <= 209) {
//           print("seen request to web success");
//         }
//       });
//     } else {
//       print('Failed to fetch data');
//     }
//     return Future.value(true);
//   });
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Welcome to cloudNsure',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const LoginScreen(),
//       routes: {
//         // '/load': (context) => const ProjectListScreen(),
//
//
//       },
//     );
//   }
// }
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//
// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//
//
//   double getMargin(BuildContext context) {
//     // Calculate the margin based on a percentage of screen width
//     double screenWidth = MediaQuery.of(context).size.width;
//     double marginPercentage = 0.2; // Adjust the percentage as needed
//     return screenWidth * marginPercentage;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return kIsWeb
//         ? Container(
//             margin: EdgeInsets.symmetric(
//               horizontal: getMargin(context),
//             ),
//             child: MaterialApp(
//               navigatorKey: navigatorKey,
//               debugShowCheckedModeBanner: false,
//               title: 'Welcome to cloudNsure',
//               theme: ThemeData(
//                 primarySwatch: Colors.blue,
//                 visualDensity: VisualDensity.adaptivePlatformDensity,
//               ),
//               home:SplashScreen(),
//               routes: {
//
//                 '/regi': (context) =>
//                     RegistrationDetailsScreen(email: 'gaurav@dekatc.com'),
//                 '/user': (context) => CreateUserScreen(),
//
//               },
//             ),
//           )
//         : MaterialApp(
//             debugShowCheckedModeBanner: false,
//             title: 'Welcome to cloudNsure',
//             theme: ThemeData(
//               primarySwatch: Colors.blue,
//               visualDensity: VisualDensity.adaptivePlatformDensity,
//             ),
//             home: SplashScreen(),
//             routes: {
//               // '/load': (context) => const ProjectListScreen(),
//

//             },
//           );
//   }
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       // home: LoginOneScreen(),
//       initialRoute: AppRoutes.loginOneScreen,

//       routes: AppRoutes.routes,
//       theme: ThemeData(
//         primaryColor: Colors.blue,
//         appBarTheme: const AppBarTheme(
//           color: Colors.blue,
//         ),
//       ),
//     );
//   }
// }
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          theme: theme,
          title: 'Gen Sport',
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splashscreen,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
