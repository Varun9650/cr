import 'dart:convert';
import 'dart:typed_data' as typed_data; // Import 'dart:typed_data' with prefix

import 'package:cricyard/resources/api_constants.dart';
import 'package:cricyard/views/screens/Login%20Screen/view/decision.dart';
import 'package:cricyard/views/screens/Login%20Screen/view/login_screen_f.dart';
import 'package:cricyard/views/screens/MenuScreen/change_language/change_language.dart';
import 'package:cricyard/views/screens/MenuScreen/feedback_form/feedback.dart';
import 'package:cricyard/views/screens/MenuScreen/find_friends_screen/find_friends_screen.dart';
import 'package:cricyard/views/screens/MenuScreen/go_live_screen/go_live_screen.dart';
import 'package:cricyard/views/screens/MenuScreen/leaderboard_screen/leaderboard_screen.dart';
import 'package:cricyard/views/screens/MenuScreen/live_cricket/live_cricket.dart';
import 'package:cricyard/views/screens/MenuScreen/merch/screens/home_screen.dart';
import 'package:cricyard/views/screens/MenuScreen/pickup_management/pickup_management_entry.dart';
import 'package:cricyard/views/screens/MenuScreen/profile_screen/views/profile_screen.dart';
import 'package:cricyard/views/screens/MenuScreen/teams_screen/teamView/TeamsScreen.dart';
import 'package:cricyard/views/screens/MenuScreen/tournament/views/tournamnetScreen.dart';
import 'package:cricyard/views/screens/MenuScreen/master/master_menu_screen.dart';
import 'package:cricyard/views/screens/SportSelection/view/sportSelection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/token_manager.dart';
import '../LogoutService/Logoutservice.dart';
import '../practice_match/practiceView/practice_match_home_View.dart';
import '../profileManagement/change_password_f.dart';

class NewDrawer extends StatefulWidget {
  final BuildContext context;
  NewDrawer({super.key, required this.context});

  @override
  State<NewDrawer> createState() => _NewDrawerState();
}

class _NewDrawerState extends State<NewDrawer> {
  var isLogin = false;
  var isGuest = true;
  typed_data.Uint8List? _imageBytes;
  bool isLoading = false;
  String? preferredSport;
  List<String> _roleMenuKeys = [];

  @override
  void initState() {
    getLoginState();
    fetchProfileImageData();
    super.initState();
    _loadPreferredSport();
    _loadRoleMenus();
  }

  Future<void> _loadPreferredSport() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      preferredSport = prefs.getString('preferred_sport'); // Default to Cricket
    });
  }

  void getLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLogin = prefs.getBool('isLoggedIn') ?? false;
      isGuest = isLogin ? false : true;
    });
  }

  String _normalizeKey(String value) {
    final upper = value.trim().toUpperCase();
    final replaced = upper.replaceAll(RegExp(r'[^A-Z0-9]+'), '_');
    final squashed = replaced.replaceAll(RegExp(r'_+'), '_');
    final sq1 = squashed.replaceAll(RegExp(r'^_+|_+'), '');
    return squashed;
  }

  String _readMenuName(dynamic menu) {
    if (menu == null) return '';
    if (menu is String) return menu;
    if (menu is Map) {
      return (menu['name'] ??
              menu['menuName'] ??
              menu['title'] ??
              menu['menu'] ??
              menu['label'] ??
              menu['screenName'] ??
              menu['display_name'] ??
              '')
          .toString();
    }
    return menu.toString();
  }

  Future<void> _loadRoleMenus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('userData');
      if (raw == null || raw.isEmpty) return;
      final Map<String, dynamic> user = jsonDecode(raw);
      final List roles = (user['roles'] as List?) ?? [];
      final Set<String> seen = {};
      final List<String> orderedKeys = [];
      for (final r in roles) {
        if (r is Map<String, dynamic>) {
          final menus = r['menus'];
          if (menus == null) continue;
          if (menus is String) {
            for (final part in menus.split(',')) {
              final nm = part.trim();
              if (nm.isEmpty) continue;
              final key = _normalizeKey(nm);
              print('Key: $key');
              if (!seen.contains(key)) {
                seen.add(key);
                orderedKeys.add(key);
              }
            }
          } else if (menus is List) {
            for (final m in menus) {
              final nm = _readMenuName(m).trim();
              if (nm.isEmpty) continue;
              final key = _normalizeKey(nm);
              print('Key: $key');

              if (!seen.contains(key)) {
                seen.add(key);
                orderedKeys.add(key);
              }
            }
          }
        }
      }
      setState(() {
        _roleMenuKeys = orderedKeys;
      });
    } catch (e) {
      // ignore
    }
  }

  IconData _getSportIcon(String sport) {
    switch (sport) {
      case 'Football':
        return Icons.sports_soccer_outlined;
      case 'Basketball':
        return Icons.sports_basketball;
      case 'Cricket':
      default:
        return Icons.sports_cricket;
    }
  }

  Widget _getPracticeMatchScreen(String sport) {
    switch (sport) {
      case 'Football':
        return PracticeMatchHomeScreen();
      case 'Basketball':
        return PracticeMatchHomeScreen();
      case 'Cricket':
      default:
        return PracticeMatchHomeScreen();
    }
  }

  List<Widget> _buildDrawerItems() {
    final List<Widget> items = [];
    items.add(_createHeader());

    // Static top items
    items.add(_createDrawerItem(
      icon: Icons.person,
      text: 'Profile Setting',
      onTap: () {
        if (isGuest) {
          showLoginAlert(context);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Profile_Screen(),
            ),
          );
        }
      },
    ));
    items.add(_createDrawerItem(
      icon: Icons.lock,
      text: 'Change Password',
      onTap: () {
        if (isGuest) {
          showLoginAlert(context);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreenF(),
            ),
          );
        }
      },
    ));
    items.add(_createDrawerItem(
      icon: Icons.sports,
      text: 'My Tournaments',
      onTap: () {
        if (isGuest) {
          showLoginAlert(context);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TournamentScreen(),
            ),
          );
        }
      },
    ));
    items.add(_createDrawerItem(
      icon: Icons.people,
      text: 'My Teams',
      onTap: () {
        if (isGuest) {
          showLoginAlert(context);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TeamsSubScreen(),
            ),
          );
        }
      },
    ));

    // Dynamic center items from role menus
    for (final key in _roleMenuKeys) {
      final tile = _menuTileForKey(key);
      if (tile != null) items.add(tile);
    }

    // Bottom: Login/Logout
    items.add(_createDrawerItem(
      icon: isGuest ? Icons.login : Icons.logout,
      text: isGuest ? 'Login' : 'Logout',
      onTap: () {
        if (isGuest) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreenF(false),
            ),
          );
        } else {
          _logoutUser(context);
        }
      },
    ));

    return items;
  }

  Widget? _menuTileForKey(String key) {
    switch (key) {
      case 'PRACTICE_MATCH':
        if (preferredSport == null) return null;
        return _createDrawerItem(
          icon: _getSportIcon(preferredSport!),
          text: '${preferredSport!} Practice Match',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => _getPracticeMatchScreen(preferredSport!),
              ),
            );
          },
        );
      case 'PREFERRED_SPORT':
        return _createDrawerItem(
          icon: Icons.sports,
          text: 'Preferred Sport',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SportSelectionScreen(),
              ),
            );
          },
        );
      case 'LEADERBOARD':
        return _createDrawerItem(
          icon: Icons.leaderboard,
          text: 'Leaderboard',
          onTap: () {
            if (isGuest) {
              showLoginAlert(context);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeaderboardScreen(),
                ),
              );
            }
          },
        );
      case 'GO_LIVE':
        return _createDrawerItem(
          icon: Icons.live_tv,
          text: 'Go Live',
          onTap: () {
            if (isGuest) {
              showLoginAlert(context);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GoLiveScreen(),
                ),
              );
            }
          },
        );
      case 'LIVE_CRICKET':
        return _createDrawerItem(
          icon: Icons.live_tv_rounded,
          text: 'Live Cricket',
          onTap: () {
            if (isGuest) {
              showLoginAlert(context);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LiveCricketScreen(),
                ),
              );
            }
          },
        );
      case 'MY_HIGHLIGHT':
        return _createDrawerItem(
          icon: Icons.highlight,
          text: 'My Highlight',
          onTap: () {
            if (isGuest) {
              showLoginAlert(context);
            }
          },
        );
      case 'CHANGE_LANGUAGE':
        return _createDrawerItem(
          icon: Icons.language,
          text: 'Change Language',
          onTap: () {
            if (isGuest) {
              showLoginAlert(context);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangeLanguageScreen(),
                ),
              );
            }
          },
        );
      case 'COMMUNITY':
        return _createDrawerItem(
          icon: Icons.group,
          text: 'Community',
          onTap: () {
            if (isGuest) {
              showLoginAlert(context);
            }
          },
        );
      case 'FIND_FRIENDS':
        return _createDrawerItem(
          icon: Icons.person_add,
          text: 'Find Friends',
          onTap: () {
            if (isGuest) {
              showLoginAlert(context);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FindFriendsScreen(),
                ),
              );
            }
          },
        );
      case 'MASTER':
        return _createDrawerItem(
          icon: Icons.admin_panel_settings,
          text: 'Master',
          onTap: () {
            if (isGuest) {
              showLoginAlert(context);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MasterMenuScreen(),
                ),
              );
            }
          },
        );
      case 'FEEDBACK':
        return _createDrawerItem(
          icon: Icons.feedback,
          text: 'Feedback',
          onTap: () {
            if (isGuest) {
              showLoginAlert(context);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => feedbackScreen(),
                ),
              );
            }
          },
        );
      case 'MERCH':
        return _createDrawerItem(
          icon: Icons.store,
          text: 'Merch',
          onTap: () {
            if (isGuest) {
              showLoginAlert(context);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductHomeScreen(),
                ),
              );
            }
          },
        );
      case 'LOGISTICS_MANAGEMENT':
        return _createDrawerItem(
          icon: Icons.local_shipping,
          text: 'Logistics Management',
          onTap: () {
            if (isGuest) {
              showLoginAlert(context);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PickupManagementEntry(),
                ),
              );
            }
          },
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: _buildDrawerItems(),
      ),
    );
  }

  Widget _createHeader() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      decoration: const BoxDecoration(
        color: Color(0xFF219ebc),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            CircleAvatar(
                // radius: 70,
                radius: MediaQuery.of(context).size.height * 0.08,
                backgroundImage: _imageBytes != null
                    ? MemoryImage(_imageBytes!)
                    : const NetworkImage(
                            'https://media.istockphoto.com/id/1332100919/vector/man-icon-black-icon-person-symbol.jpg?s=612x612&w=0&k=20&c=AVVJkvxQQCuBhawHrUhDRTCeNQ3Jgt0K1tXjJsFy1eg=')
                        as ImageProvider),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Text(
              'Welcome',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.height * 0.03),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF219ebc)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    style: GoogleFonts.poppins(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_outlined,
              color: Color(0xFF219ebc), size: 12)
        ],
      ),
      onTap: onTap,
    );
  }

  void showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Oops!!"),
          content: Text('Please login to access this feature',
              style: GoogleFonts.getFont('Poppins', color: Colors.black)),
          actions: <Widget>[
            TextButton(
              child: const Text("CANCEL"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("LOGIN NOW"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DecisionScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _logoutUser(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('userData');
      await prefs.remove('isLoggedIn');
      String logoutUrl = "${ApiConstants.baseUrl}/token/logout";
      var response = await http.get(Uri.parse(logoutUrl));
      if (response.statusCode <= 209) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreenF(false)),
          (route) => false,
        );
      } else {
        // Handle error cases
      }
    } catch (error) {
      print('Error occurred during logout: $error');
    }
  }

  Future<void> fetchProfileImageData() async {
    setState(() {
      isLoading = true;
    });
    final token = await TokenManager.getToken();
    const String baseUrl = ApiConstants.baseUrl;
    const String apiUrl = '$baseUrl/api/retrieve-image';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 401) {
        LogoutService.logout();
      }
      if (response.statusCode >= 200 && response.statusCode <= 209) {
        String responseData = response.body.replaceAll('"}', '');
        final commaIndex = responseData.indexOf(',');
        if (commaIndex != -1) {
          final imageData = responseData.substring(commaIndex + 1);
          final bytes = base64Decode(imageData);
          setState(() {
            _imageBytes = bytes;
          });
          print('Image data is decoded.');
        } else {
          print('Invalid image data format');
        }
      } else {
        print(
            'Failed to load image data: ${response.statusCode} : ${response.body}');
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching image data: $e');
    }
  }
}
