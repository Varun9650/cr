import 'package:cricyard/core/utils/sport_image_provider.dart';
import 'package:cricyard/views/screens/Login%20Screen/view/login_screen_f.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/app_export.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../signupF/SignupScreenF.dart';

class DecisionScreen extends StatefulWidget {
  const DecisionScreen({Key? key}) : super(key: key);

  @override
  State<DecisionScreen> createState() => _DecisionScreenState();
}

class _DecisionScreenState extends State<DecisionScreen> {
  String? preferredSport;

  @override
  void initState() {
    super.initState();
    getPreferredSport();
  }

  Future<void> getPreferredSport() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      preferredSport = prefs.getString('preferred_sport');
    });
  }

  String getSportText() {
    switch (preferredSport?.toLowerCase()) {
      case 'badminton':
        return 'Badminton';
      case 'cricket':
        return 'Cricket';
      default:
        return 'Sport';
    }
  }

  String getFirstImg() {
    switch (preferredSport?.toLowerCase()) {
      case 'badminton':
        return ImageConstant.imgBadminton1;
      case 'cricket':
        return ImageConstant.imgAlfredKenneall;
      default:
        return ImageConstant.imgBadminton1;
    }
  }

  String getSecondImg() {
    switch (preferredSport?.toLowerCase()) {
      case 'badminton':
        return ImageConstant.imgImagegenSportlowWidth;
      case 'cricket':
        return ImageConstant.imgImageRemovebgPreview;
      default:
        return ImageConstant.imgImagegenSportlowWidth;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(vertical: 28.v),
          child: Column(
            children: [
              _buildStackSection(context),
              SizedBox(height: 46.v),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 278.h,
                  margin: EdgeInsets.only(left: 54.h),
                  child: Text(
                    "Discover all about ${getSportText()}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.displayMedium!.copyWith(
                      fontWeight: FontWeight.bold, // Make text bold
                      fontSize: 35.0, // Increase font size
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(
                  left: 54.h,
                  right: 66.h,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomElevatedButton(
                      height: 67.v,
                      width: MediaQuery.of(context).size.width / 2 - 70.h,
                      text: "Sign in",
                      buttonTextStyle: CustomTextStyles.titleMedium18,
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreenF(false)),
                          (route) => false, // Remove all routes from the stack
                        );
                      },
                    ),
                    const SizedBox(width: 2),
                    CustomElevatedButton(
                      height: 67.v,
                      width: MediaQuery.of(context).size.width / 2 - 70.h,
                      text: "Sign up",
                      buttonTextStyle: CustomTextStyles.titleMedium18,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupScreenF()),
                          // (route) => false, // Remove all routes from the stack
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildStackSection(BuildContext context) {
    return SizedBox(
      height: 413.v,
      width: double.maxFinite,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // comment  temporary
          // black background
          // CustomImageView(
          //   svgPath: ImageConstant.imgGroup3090,
          //   height: 338.v,
          //   width: 291.h,
          //   alignment: Alignment.bottomCenter,
          // ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 400.v,
              width: double.maxFinite,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // player image
                  Opacity(
                    opacity: 0.35,
                    child: CustomImageView(
                      imagePath: getFirstImg(),
                      height: double.infinity,
                      width: double.infinity,
                      alignment: Alignment.center,
                      fit: BoxFit.contain, // ✅ or use BoxFit.fitHeight
                    ),
                  ),

                  const SizedBox(height: 15),

                  //  logo
                  // cricyard logo - dynamically scales inside same image box
                  Opacity(
                    opacity: 0.70,
                    child: Align(
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit
                            .contain, // ensures logo scales without being cut
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.h), // optional spacing
                          child: CustomImageView(
                            imagePath:
                                SportImageProvider.getLogoImage(preferredSport),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
