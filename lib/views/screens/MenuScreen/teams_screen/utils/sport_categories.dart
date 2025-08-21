import 'package:flutter/material.dart';

class SportCategories {
  static List<String> getCategories(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return ['Wicket Keepers', 'Batsman', 'All Rounder', 'Bowlers'];
      case 'football':
        return ['Goalkeepers', 'Defenders', 'Midfielders', 'Forwards'];
      case 'basketball':
        return [
          'Point Guards',
          'Shooting Guards',
          'Small Forwards',
          'Power Forwards',
          'Centers'
        ];
      case 'badminton':
        return []; // No categories for badminton - show all players together
      case 'tennis':
        return ['Singles Players', 'Doubles Players'];
      case 'hockey':
        return ['Goalkeepers', 'Defenders', 'Midfielders', 'Forwards'];
      default:
        return ['Players'];
    }
  }

  static List<String> getRoles(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return ['Captain', 'Vice Captain', 'Wicket Keeper'];
      case 'football':
        return ['Captain', 'Vice Captain', 'Goalkeeper'];
      case 'basketball':
        return ['Captain', 'Vice Captain', 'Point Guard'];
      case 'badminton':
        return ['Captain', 'Vice Captain', 'Lead Player'];
      case 'tennis':
        return ['Captain', 'Vice Captain', 'Lead Player'];
      case 'hockey':
        return ['Captain', 'Vice Captain', 'Goalkeeper'];
      default:
        return ['Captain', 'Vice Captain'];
    }
  }

  static Map<String, int> getCategoryMaxPlayers(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return {
          'Wicket Keepers': 2,
          'Batsman': 3,
          'All Rounder': 3,
          'Bowlers': 4,
        };
      case 'football':
        return {
          'Goalkeepers': 2,
          'Defenders': 4,
          'Midfielders': 4,
          'Forwards': 3,
        };
      case 'basketball':
        return {
          'Point Guards': 2,
          'Shooting Guards': 2,
          'Small Forwards': 2,
          'Power Forwards': 2,
          'Centers': 2,
        };
      case 'badminton':
        return {
          'Players': 8, // Total players for badminton team
        };
      case 'tennis':
        return {
          'Singles Players': 4,
          'Doubles Players': 6,
        };
      case 'hockey':
        return {
          'Goalkeepers': 2,
          'Defenders': 4,
          'Midfielders': 4,
          'Forwards': 3,
        };
      default:
        return {
          'Players': 11,
        };
    }
  }

  static Map<String, String> getRoleCodes(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return {
          'Captain': 'C',
          'Vice Captain': 'VC',
          'Wicket Keeper': 'WK',
        };
      case 'football':
        return {
          'Captain': 'C',
          'Vice Captain': 'VC',
          'Goalkeeper': 'GK',
        };
      case 'basketball':
        return {
          'Captain': 'C',
          'Vice Captain': 'VC',
          'Point Guard': 'PG',
        };
      case 'badminton':
        return {
          'Captain': 'C',
          'Vice Captain': 'VC',
          'Lead Player': 'LP',
        };
      case 'tennis':
        return {
          'Captain': 'C',
          'Vice Captain': 'VC',
          'Lead Player': 'LP',
        };
      case 'hockey':
        return {
          'Captain': 'C',
          'Vice Captain': 'VC',
          'Goalkeeper': 'GK',
        };
      default:
        return {
          'Captain': 'C',
          'Vice Captain': 'VC',
        };
    }
  }

  static Map<String, IconData> getRoleIcons(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return {
          'Captain': Icons.star,
          'Vice Captain': Icons.star_half,
          'Wicket Keeper': Icons.sports_baseball,
        };
      case 'football':
        return {
          'Captain': Icons.star,
          'Vice Captain': Icons.star_half,
          'Goalkeeper': Icons.sports_soccer,
        };
      case 'basketball':
        return {
          'Captain': Icons.star,
          'Vice Captain': Icons.star_half,
          'Point Guard': Icons.sports_basketball,
        };
      case 'badminton':
        return {
          'Captain': Icons.star,
          'Vice Captain': Icons.star_half,
          'Lead Player': Icons.sports_tennis,
        };
      case 'tennis':
        return {
          'Captain': Icons.star,
          'Vice Captain': Icons.star_half,
          'Lead Player': Icons.sports_tennis,
        };
      case 'hockey':
        return {
          'Captain': Icons.star,
          'Vice Captain': Icons.star_half,
          'Goalkeeper': Icons.sports_hockey,
        };
      default:
        return {
          'Captain': Icons.star,
          'Vice Captain': Icons.star_half,
        };
    }
  }

  static Map<String, Color> getRoleColors(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return {
          'Captain': Colors.amber,
          'Vice Captain': Colors.orange,
          'Wicket Keeper': Colors.green,
        };
      case 'football':
        return {
          'Captain': Colors.amber,
          'Vice Captain': Colors.orange,
          'Goalkeeper': Colors.blue,
        };
      case 'basketball':
        return {
          'Captain': Colors.amber,
          'Vice Captain': Colors.orange,
          'Point Guard': Colors.red,
        };
      case 'badminton':
        return {
          'Captain': Colors.amber,
          'Vice Captain': Colors.orange,
          'Lead Player': Colors.purple,
        };
      case 'tennis':
        return {
          'Captain': Colors.amber,
          'Vice Captain': Colors.orange,
          'Lead Player': Colors.green,
        };
      case 'hockey':
        return {
          'Captain': Colors.amber,
          'Vice Captain': Colors.orange,
          'Goalkeeper': Colors.indigo,
        };
      default:
        return {
          'Captain': Colors.amber,
          'Vice Captain': Colors.orange,
        };
    }
  }
}
