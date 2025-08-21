import 'dart:convert';
import 'dart:typed_data';

import 'package:cricyard/core/app_export.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../providers/token_manager.dart';
import '../../../../../resources/api_constants.dart';
import '../../../LogoutService/Logoutservice.dart';
import '../../../ReuseableWidgets/BottomAppBarWidget.dart';
import '../../../profileManagement/profile_settings_f.dart';
import 'login_three_page.dart';
import 'logistics_screen.dart';

class Profile_Screen extends StatefulWidget {
  const Profile_Screen({Key? key}) : super(key: key);

  @override
  Profile_ScreenState createState() => Profile_ScreenState();
}

class Profile_ScreenState extends State<Profile_Screen>
    with TickerProviderStateMixin {
  late TabController tabviewController;
  Uint8List? _imageBytes;
  Map<String, dynamic> userData = {};
  bool isLoading = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userdatastr = prefs.getString('userData');
    if (userdatastr != null) {
      try {
        setState(() {
          userData = json.decode(userdatastr);
        });
      } catch (e) {
        print("error is ..................$e");
      }
    }
  }

  String? preferredSport;
  Future<void> getPreferredSport() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      preferredSport = prefs.getString('preferred_sport');
    });
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
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 401) {
        LogoutService.logout();
      }
      if (response.statusCode >= 200 && response.statusCode <= 209) {
        String responseData = response.body.replaceAll(
          '"}',
          '',
        ); // Remove trailing '"}'
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
        print('Failed to load image data: ${response.statusCode}');
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching image data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getPreferredSport();
    fetchProfileImageData();
    getUserData();

    tabviewController = TabController(length: 2, vsync: this);

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Listener to detect tab changes and navigate when "Logistics" is selected
    tabviewController.addListener(() {
      if (tabviewController.indexIsChanging) {
        if (tabviewController.index == 1) {
          // 1 represents the "Logistics" tab index
          Future.microtask(
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LogisticsScreen()),
            ),
          );
        }
      }
    });

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: RefreshIndicator(
          onRefresh: () async {
            await fetchProfileImageData();
            await getUserData();
          },
          color: Colors.blue[600],
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // Enhanced Profile Header
                _buildEnhancedProfileHeader(),

                const SizedBox(height: 24),

                // Enhanced Tab Bar
                _buildEnhancedTabBar(),

                const SizedBox(height: 20),

                // Tab Content
                _buildTabbarview(context),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBarWidget(),
      ),
    );
  }

  Widget _buildEnhancedProfileHeader() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue[600]!,
                  Colors.blue[400]!,
                  Colors.indigo[400]!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Back Button and Title Row
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            onPressed: () => onTapBtnArrowleftone(context),
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "My Profile",
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Profile Image and Info
                    Row(
                      children: [
                        // Profile Image
                        Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 3,
                                ),
                              ),
                              child: isLoading
                                  ? Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : _imageBytes != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(47),
                                      child: Image.memory(
                                        _imageBytes!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                            ),
                            // Edit Button
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () => onTapBtnEdit(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Colors.blue[600],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 20),

                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello ${capitalize(userData['fullName'] ?? 'User')}!',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Badminton Player',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (userData['unique_player_id'] != null)
                                Text(
                                  'ID: ${userData['unique_player_id']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedTabBar() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value.dy) * 30),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TabBar(
              controller: tabviewController,
              labelPadding: const EdgeInsets.symmetric(vertical: 16),
              labelColor: Colors.white,
              labelStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelColor: Colors.grey[600],
              unselectedLabelStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[400]!],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, size: 18),
                      const SizedBox(width: 8),
                      Text("My Profile"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_shipping, size: 18),
                      const SizedBox(width: 8),
                      Text("Logistics"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Section Widget
  Widget _buildTabbarview(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            height: 700,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: TabBarView(
              controller: tabviewController,
              children: const [LoginThreePage(), LogisticsScreen()],
            ),
          ),
        );
      },
    );
  }

  /// Navigates back to the previous screen.
  onTapBtnArrowleftone(BuildContext context) {
    Navigator.pop(context);
  }

  /// Navigates to the Edit screen.
  onTapBtnEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileSettingsScreenF(userData: userData),
      ),
    );
  }

  /// Navigates to the Setting screen.
  onTapBtnSetting(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.setting_screen);
  }
}
