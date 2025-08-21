// Centralized image provider for sport-wise images
import 'image_constant.dart';

class SportImageProvider {
  static String getBannerImage(String? sport) {
    switch (sport?.toLowerCase()) {
      case 'badminton':
        return ImageConstant.imgBadminton;
      case 'cricket':
        return ImageConstant.imgCricketPlayer;
      default:
        return ImageConstant.imgBadminton;
    }
  }

  static String getLogoImage(String? sport) {
    switch (sport?.toLowerCase()) {
      case 'badminton':
        return ImageConstant.imgImagegenSportlowWidth;
      case 'cricket':
        return ImageConstant.imgImageRemovebgPreview;
      default:
        return ImageConstant.imgImagegenSportlowWidth;
    }
  }

  static String getBottomIcon1(String? sport) {
    switch (sport?.toLowerCase()) {
      case 'badminton':
        // print('crick image got');

        return ImageConstant.closeupshuttlecock;

      case 'cricket':
        return ImageConstant.imgBatball;
      default:
        return ImageConstant.closeupshuttlecock;
    }
  }

  static String getBottomIcon2(String? sport) {
    switch (sport?.toLowerCase()) {
      case 'badminton':
        print('badminton image got');
        return ImageConstant.arrangementminimal;
      case 'cricket':
        return ImageConstant.imgBxCricketBall;
      default:
        return ImageConstant.arrangementminimal;
    }
  }

  static String getBottomLiveIcon3(String? sport) {
    switch (sport?.toLowerCase()) {
      case 'badminton':
        // print('badminton image got');
        return ImageConstant.liveimg;
      case 'cricket':
        return ImageConstant.imgFluentLive24Filled;
      default:
        return ImageConstant.liveimg;
    }
  }

  static String getBottomMoreIcon4(String? sport) {
    switch (sport?.toLowerCase()) {
      case 'badminton':
        print('badminton image got');
        return ImageConstant.more;
      case 'cricket':
        return ImageConstant.imgOverflowmenu;
      default:
        return ImageConstant.more;
    }
  }

  static String getNewsImage(String? sport) {
    switch (sport?.toLowerCase()) {
      case 'badminton':
        return ImageConstant.tournament;
      case 'cricket':
        return ImageConstant.image_195;
      default:
        return ImageConstant.tournament;
    }
  }

  static String getMainBackground(String? sport) {
    switch (sport?.toLowerCase()) {
      case 'badminton':
        return ImageConstant.imgBadminton;
      case 'cricket':
        return ImageConstant.imgLogin;
      default:
        return ImageConstant.imgLogin;
    }
  }

  static String getPlayerImage(String? sport) {
    switch (sport?.toLowerCase()) {
      case 'badminton':
        return ImageConstant.imgBadminton1;
      case 'cricket':
        return ImageConstant.imgAlfredKenneall;
      default:
        return ImageConstant.imgBadminton1;
    }
  }

  static String getSportName(String? sport) {
    switch (sport?.toLowerCase()) {
      case 'badminton':
        return 'Badminton';
      case 'cricket':
        return 'Cricket';
      default:
        return 'Sport';
    }
  }

  static String getAppName() {
    return 'GenSport'; // Default app name, can be customized if needed
  }

  // Add more methods as needed for other widgets
}
