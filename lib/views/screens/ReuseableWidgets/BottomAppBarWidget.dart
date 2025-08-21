import 'package:cricyard/core/app_export.dart';
import 'package:cricyard/core/utils/sport_image_provider.dart';
import 'package:cricyard/views/screens/MenuScreen/new_dash/Newdashboard.dart';
import 'package:flutter/material.dart';
import 'package:cricyard/views/widgets/custom_icon_button.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as fs;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../MenuScreen/merch/screens/home_screen.dart';
import '../MenuScreen/teams_screen/teamView/my_teams_screen.dart';
import '../MenuScreen/tournament/my_tournamnet_screen/viewmodel/my_tournament_view_model.dart';
import '../MenuScreen/tournament/my_tournamnet_screen/widgets/EnrolledTournamentScreen.dart';

class BottomAppBarWidget extends StatefulWidget {
  const BottomAppBarWidget({Key? key}) : super(key: key);

  @override
  State<BottomAppBarWidget> createState() => _BottomAppBarWidgetState();
}

class _BottomAppBarWidgetState extends State<BottomAppBarWidget> {
  String? preferredSport;
  bool isLoggedIn = false; // Add login state

  @override
  void initState() {
    super.initState();
    getPreferredSport();
    checkLoginStatus(); // Check login status
  }

  Future<void> getPreferredSport() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      preferredSport = prefs.getString('preferred_sport');
    });
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  void _showLoginMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Please login to access this feature',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SizedBox(
        height: 115.v,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 35.v),
                padding: EdgeInsets.symmetric(
                  horizontal: 13.h,
                  vertical: 15.v,
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: fs.Svg(
                      ImageConstant.imgGroup146,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconButton(
                      height: 50.adaptSize,
                      width: 50.adaptSize,
                      padding_f: EdgeInsets.all(13.h),
                      child: Tooltip(
                        message: "My Teams",
                        child: Builder(
                          builder: (context) {
                            return GestureDetector(
                              onTap: () {
                                if (!isLoggedIn) {
                                  _showLoginMessage(context);
                                  return;
                                }
                                print("Team Icon Clicked");
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MyTeamScreen()));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(7),
                                child: Icon(
                                  Icons.people,
                                  color: const Color(0xFF0096c7),
                                  size: 28.0.v,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 27.h),
                      child: CustomIconButton(
                        height: 50.adaptSize,
                        width: 50.adaptSize,
                        padding_f: EdgeInsets.all(12.h),
                        child: Tooltip(
                          message: "My Tournaments",
                          child: Builder(
                            builder: (context) {
                              return GestureDetector(
                                onTap: () {
                                  if (!isLoggedIn) {
                                    _showLoginMessage(context);
                                    return;
                                  }
                                  // Initialize data through ViewModel
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    final provider =
                                        Provider.of<MyTournamentViewModel>(
                                            context,
                                            listen: false);
                                    provider.fetchEnrolledTournaments();
                                  });
                                  print("Tournament Icon Clicked");
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              EnrolledTournamentScreen()));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(7),
                                  child: Icon(
                                    Icons.emoji_events,
                                    color: const Color(0xFF0096c7),
                                    size: 28.0.v,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 123.h),
                      child: CustomIconButton(
                        height: 50.adaptSize,
                        width: 50.adaptSize,
                        padding_f: EdgeInsets.all(12.h),
                        child: Builder(
                          builder: (context) {
                            final liveIcon =
                                SportImageProvider.getBottomLiveIcon3(
                                    preferredSport);
                            if (liveIcon != null &&
                                (liveIcon.endsWith('.jpg') ||
                                    liveIcon.endsWith('.jpeg') ||
                                    liveIcon.endsWith('.png'))) {
                              return GestureDetector(
                                onTap: () {
                                  if (!isLoggedIn) {
                                    _showLoginMessage(context);
                                    return;
                                  }
                                  // Handle live icon click for logged in users
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.withOpacity(0.3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(7),
                                  child: Image.asset(
                                    liveIcon,
                                    height: 28.0.v,
                                    width: 28.0.h,
                                    fit: BoxFit.contain,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                              );
                            } else {
                              return GestureDetector(
                                onTap: () {
                                  if (!isLoggedIn) {
                                    _showLoginMessage(context);
                                    return;
                                  }
                                  // Handle live icon click for logged in users
                                },
                                child: CustomImageView(
                                  svgPath: liveIcon,
                                  height: 32.0.v,
                                  width: 32.0.h,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 26.h),
                      child: CustomIconButton(
                        height: 50.adaptSize,
                        width: 50.adaptSize,
                        padding_f: EdgeInsets.all(10.h),
                        child: Builder(
                          builder: (context) {
                            final moreIcon =
                                SportImageProvider.getBottomMoreIcon4(
                                    preferredSport);
                            if (moreIcon != null &&
                                (moreIcon.endsWith('.jpg') ||
                                    moreIcon.endsWith('.png'))) {
                              return GestureDetector(
                                onTap: () {
                                  if (!isLoggedIn) {
                                    _showLoginMessage(context);
                                    return;
                                  }
                                  // Handle more icon click for logged in users
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.withOpacity(0.3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(7),
                                  child: Image.asset(
                                    moreIcon,
                                    height: 28.0.v,
                                    width: 28.0.h,
                                    fit: BoxFit.contain,
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                              );
                            } else {
                              return GestureDetector(
                                onTap: () {
                                  if (!isLoggedIn) {
                                    _showLoginMessage(context);
                                    return;
                                  }
                                  // Handle more icon click for logged in users
                                },
                                child: CustomImageView(
                                  svgPath: moreIcon,
                                  height: 32.0.v,
                                  width: 32.0.h,
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(bottom: 40.0),
                child: CustomIconButton(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Newdashboard(),
                        ));
                  },
                  height: 70.adaptSize,
                  width: 70.adaptSize,
                  padding_f: EdgeInsets.all(10.h),
                  child: CustomImageView(
                    svgPath: ImageConstant.home,
                    height: 32.0.v, // Adjusted height
                    width: 32.0.h, // Adjusted width
                  ),
                ),
              ),
            ),
            // CustomFloatingButton(
            //   height: 64,
            //   width: 64,
            //   alignment: Alignment.topCenter,
            //   child: CustomImageView(
            //     svgPath: ImageConstant.imgLocation,
            //     height: 32.0.v,
            //     width: 32.0.h,
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductHomeScreen(),
                          ));
                    },
                    child: Column(
                      children: [
                        SizedBox(
                            height: 60,
                            child: Image.asset(ImageConstant.imgStore)),
                        Text(
                          "Go to store",
                          style: GoogleFonts.getFont('Poppins',
                              color: Colors.black),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (context) =>const ProductHomeScreen() ,));
                    },
                    child: Column(
                      children: [
                        SizedBox(
                            height: 60,
                            child: Image.asset(ImageConstant.imgStore)),
                        Text(
                          "Create store",
                          style: GoogleFonts.getFont('Poppins',
                              color: Colors.black),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ));
      },
    );
  }
}
