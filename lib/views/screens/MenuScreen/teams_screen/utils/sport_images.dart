import 'package:flutter/material.dart';
import 'package:cricyard/core/utils/image_constant.dart';

class SportImages {
  static String getSportBackground(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return ImageConstant.imgCricketGround;
      case 'football':
        return 'assets/images/football_ground.jpg';
      case 'basketball':
        return 'assets/images/basketball_court.jpg';
      case 'badminton':
        return 'assets/images/badminton_court.jpg';
      case 'tennis':
        return 'assets/images/tennis_court.jpg';
      case 'hockey':
        return 'assets/images/hockey_ground.jpg';
      default:
        return ImageConstant.imgCricketGround;
    }
  }

  static String getPlayerImage(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return ImageConstant.imgImage51;
      case 'football':
        return 'assets/images/football_player.png';
      case 'basketball':
        return 'assets/images/basketball_player.png';
      case 'badminton':
        return 'assets/images/badminton_player.png';
      case 'tennis':
        return 'assets/images/tennis_player.png';
      case 'hockey':
        return 'assets/images/hockey_player.png';
      default:
        return ImageConstant.imgImage51;
    }
  }

  static String getTeamIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return 'assets/images/cricket_team_icon.png';
      case 'football':
        return 'assets/images/football_team_icon.png';
      case 'basketball':
        return 'assets/images/basketball_team_icon.png';
      case 'badminton':
        return 'assets/images/badminton_team_icon.png';
      case 'tennis':
        return 'assets/images/tennis_team_icon.png';
      case 'hockey':
        return 'assets/images/hockey_team_icon.png';
      default:
        return 'assets/images/cricket_team_icon.png';
    }
  }

  static String getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'wicket keeper':
        return 'assets/images/wicket_keeper_icon.png';
      case 'batsman':
        return 'assets/images/batsman_icon.png';
      case 'all rounders':
        return 'assets/images/all_rounder_icon.png';
      case 'bowlers':
        return 'assets/images/bowler_icon.png';
      case 'captain':
        return 'assets/images/captain_icon.png';
      case 'vice captain':
        return 'assets/images/vice_captain_icon.png';
      default:
        return 'assets/images/player_icon.png';
    }
  }

  static Color getSportColor(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return const Color(0xFF2E5B34);
      case 'football':
        return const Color(0xFF1E3A8A);
      case 'basketball':
        return const Color(0xFFDC2626);
      case 'badminton':
        return const Color(0xFF059669);
      case 'tennis':
        return const Color(0xFF7C3AED);
      case 'hockey':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF2E5B34);
    }
  }

  static Color getSportAccentColor(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return const Color(0xFF4C9B56);
      case 'football':
        return const Color(0xFF3B82F6);
      case 'basketball':
        return const Color(0xFFEF4444);
      case 'badminton':
        return const Color(0xFF10B981);
      case 'tennis':
        return const Color(0xFF8B5CF6);
      case 'hockey':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF4C9B56);
    }
  }
}
