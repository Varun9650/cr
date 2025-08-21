import 'package:cricyard/core/utils/size_utils.dart';
import 'package:cricyard/views/screens/SportSelection/view/sportSelection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/image_constant.dart';
import '../../../theme/theme_helper.dart';
import '../MenuScreen/new_dash/Newdashboard.dart';
import '../SportSelection/repository/sportSelectionApiService.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _getBackgroundImage() {
    // You can fetch the selected sport from SharedPreferences if needed
    const String selectedSport = "Badminton"; // Replace with actual logic
    switch (selectedSport.toLowerCase()) {
      case 'badminton':
        return ImageConstant.imgBadminton;
      case 'cricket':
        return ImageConstant.imgLogin;
      default:
        return ImageConstant.imgLogin;
    }
  }

  String _getSportMainImage() {
    // You can fetch the selected sport from SharedPreferences if needed
    const String selectedSport = "Badminton"; // Replace with actual logic
    switch (selectedSport.toLowerCase()) {
      case 'badminton':
        return ImageConstant.imgBadminton;
      case 'cricket':
        return ImageConstant.imgCricyard1;
      default:
        return ImageConstant.imgBadminton;
    }
  }

  @override
  void initState() {
    super.initState();
    _checkSportSelection();
    // Future.delayed(Duration(seconds: 5)).then((value) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Newdashboard(),)));
    // Future.delayed(Duration(seconds: 5)).then((value) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SportSelectionScreen())));
  }

  Future<void> _checkSportSelection() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // final String? selectedSport = prefs.getString('preferred_sport');
    final String selectedSport =
        "Badminton"; // For testing purposes, hardcoded to 'Badminton');

    print('My sport is: $selectedSport');
    final sportProvider =
        Provider.of<SportSelectionProvider>(context, listen: false);

    if (selectedSport != null) {
      await prefs.setString('preferred_sport', selectedSport);
      sportProvider.savePreferredSport(selectedSport);
      print("Sport is set: $selectedSport");
      // Sport is selected, navigate directly to the dashboard or home screen
      Future.delayed(Duration(seconds: 3))
          .then((value) => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Newdashboard()),
              ));
    } else {
      // No sport selected, navigate to the sport selection screen
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => SportSelectionScreen()),
      // );
      Future.delayed(Duration(seconds: 3)).then((value) =>
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => SportSelectionScreen())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: appTheme.black900,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: appTheme.black900,
            image: DecorationImage(
              image: AssetImage(
                _getBackgroundImage(),
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            height: 64,
            padding: EdgeInsets.symmetric(
              horizontal: 23.h,
              vertical: 83.v,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // The image at its natural aspect ratio, centered, with lower opacity
                    Opacity(
                      opacity: 0.45, // Lowered opacity for lighter effect
                      child: Image.asset(
                        ImageConstant.imgImagegenSport,
                        fit: BoxFit.contain,
                        height: MediaQuery.of(context).size.height * 0.15,
                        width: MediaQuery.of(context).size.height * 0.98,
                      ),
                    ),
                    // Soft shade overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.18),
                              Colors.transparent,
                              Colors.black.withOpacity(0.18),
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: 62),
                // Temporary Commented out the CustomImageView for sport main Logo
                // Uncomment the following lines if you want to display the sport main logo
                // CustomImageView(
                //   imagePath: _getSportMainImage(),
                //   height: MediaQuery.of(context).size.height * 0.45,
                //   width: MediaQuery.of(context).size.height * 0.45,
                // ),
                // const Spacer(flex: 37),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
