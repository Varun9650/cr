import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../theme/custom_text_style.dart';

class LoginThreePage extends StatefulWidget {
  const LoginThreePage({Key? key})
      : super(
          key: key,
        );

  @override
  LoginThreePageState createState() => LoginThreePageState();
}

class LoginThreePageState extends State<LoginThreePage>
    with
        AutomaticKeepAliveClientMixin<LoginThreePage>,
        TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic> userData = {};

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    getUserData();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

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

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),

            const SizedBox(height: 20),

            // Profile Information Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Personal Information Section
                  _buildSectionCard(
                    title: 'Personal Information',
                    icon: Icons.person_outline,
                    color: Colors.blue[600]!,
                    children: [
                      _buildInfoTile(
                        title: 'Full Name',
                        value: _getSafeStringValue('fullName'),
                        icon: Icons.person,
                        color: Colors.blue[600]!,
                        index: 0,
                      ),
                      _buildInfoTile(
                        title: 'Email Address',
                        value: _getSafeStringValue('email'),
                        icon: Icons.email,
                        color: Colors.green[600]!,
                        index: 1,
                      ),
                      _buildInfoTile(
                        title: 'Phone Number',
                        value: _getSafeStringValue('mob_no'),
                        icon: Icons.phone,
                        color: Colors.orange[600]!,
                        index: 2,
                      ),
                      _buildInfoTile(
                        title: 'Unique Player ID',
                        value: _getSafeStringValue('unique_player_id'),
                        icon: Icons.badge,
                        color: Colors.purple[600]!,
                        index: 3,
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),

                  // Location Information Section
                  _buildSectionCard(
                    title: 'Location Information',
                    icon: Icons.location_on_outlined,
                    color: Colors.red[600]!,
                    children: [
                      _buildInfoTile(
                        title: 'City',
                        value: _getSafeStringValue('city'),
                        icon: Icons.location_city,
                        color: Colors.red[600]!,
                        index: 0,
                      ),
                      _buildInfoTile(
                        title: 'State',
                        value: _getSafeStringValue('state'),
                        icon: Icons.map,
                        color: Colors.red[600]!,
                        index: 1,
                      ),
                      _buildInfoTile(
                        title: 'Address',
                        value: _getSafeStringValue('address',
                            defaultValue:
                                '${_getSafeStringValue('city')}, ${_getSafeStringValue('state')}'),
                        icon: Icons.home,
                        color: Colors.red[600]!,
                        index: 2,
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),

                  // Family Information Section
                  _buildSectionCard(
                    title: 'Family Information',
                    icon: Icons.family_restroom,
                    color: Colors.indigo[600]!,
                    children: [
                      _buildInfoTile(
                        title: 'Father\'s Name',
                        value: _getSafeStringValue('father_name'),
                        icon: Icons.person,
                        color: Colors.indigo[600]!,
                        index: 0,
                      ),
                      _buildInfoTile(
                        title: 'Mother\'s Name',
                        value: _getSafeStringValue('mother_name'),
                        icon: Icons.person,
                        color: Colors.indigo[600]!,
                        index: 1,
                      ),
                    ],
                  ),

                  const SizedBox(height: 35),

                  // T-Shirt Information Section - NEW
                  _buildSectionCard(
                    title: 'T-Shirt Information',
                    icon: Icons.checkroom,
                    color: Colors.teal[600]!,
                    children: [
                      _buildInfoTile(
                        title: 'T-Shirt Size',
                        value: _getSafeStringValue('tshirt_size'),
                        icon: Icons.style,
                        color: Colors.teal[600]!,
                        index: 0,
                        isEditable: true,
                        onTap: () {
                          _showTshirtSizeDialog();
                        },
                      ),
                      _buildInfoTile(
                        title: 'T-Shirt Status',
                        value: _getSafeBoolValue('tshirt_received')
                            ? 'Received'
                            : 'Pending',
                        icon: Icons.local_shipping,
                        color: _getSafeBoolValue('tshirt_received')
                            ? Colors.green[600]!
                            : Colors.orange[600]!,
                        index: 1,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[600]!,
            Colors.blue[400]!,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Profile Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // User Name
              Text(
                _getSafeStringValue('fullName', defaultValue: 'User'),
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // User Role/Status
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Cricket Player',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),

                // Section Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    children: children,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required int index,
    bool isEditable = false,
    VoidCallback? onTap,
  }) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value.dy) * 20 * (index + 1)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isEditable ? color.withOpacity(0.05) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isEditable
                          ? color.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      width: isEditable ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              value,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isEditable) ...[
                        Icon(
                          Icons.edit,
                          color: color,
                          size: 18,
                        ),
                      ] else ...[
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey[400],
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to safely get string value from userData
  String _getSafeStringValue(String key,
      {String defaultValue = 'Not specified'}) {
    final value = userData[key];
    if (value == null) return defaultValue;
    if (value is String) return value;
    if (value is int || value is double) return value.toString();
    if (value is bool) return value ? 'Yes' : 'No';
    return value.toString();
  }

  // Helper method to safely get boolean value from userData
  bool _getSafeBoolValue(String key, {bool defaultValue = false}) {
    final value = userData[key];
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value != 0;
    return defaultValue;
  }

  void _showTshirtSizeDialog() {
    String selectedSize = _getSafeStringValue('tshirt_size', defaultValue: '');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Select T-Shirt Size',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Choose your preferred t-shirt size:',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children:
                        ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL'].map((size) {
                      return ChoiceChip(
                        label: Text(size),
                        selected: selectedSize == size,
                        onSelected: (bool selected) {
                          setState(() {
                            selectedSize = selected ? size : '';
                          });
                        },
                        selectedColor: Colors.blue[100],
                        labelStyle: TextStyle(
                          color: selectedSize == size
                              ? Colors.blue[800]
                              : Colors.grey[700],
                          fontWeight: selectedSize == size
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Safely update the userData map
                setState(() {
                  userData['tshirt_size'] = selectedSize;
                });
                Navigator.of(context).pop();

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('T-shirt size updated to: $selectedSize'),
                    backgroundColor: Colors.green[600],
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Save',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
