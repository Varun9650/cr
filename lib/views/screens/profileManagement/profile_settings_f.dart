import 'dart:convert';
import 'dart:typed_data';

import 'package:cricyard/core/app_export.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/token_manager.dart';
import '../../../resources/api_constants.dart';
import '../../widgets/custom_text_form_field.dart';
import '../Login Screen/view/CustomButton.dart';
import '../Login Screen/view/login_screen_f.dart';
import '../LogoutService/Logoutservice.dart';
import '../ReuseableWidgets/BottomAppBarWidget.dart';
import 'profilemanagementservice.dart';

class ProfileSettingsScreenF extends StatefulWidget {
  final Map<String, dynamic> userData;

  ProfileSettingsScreenF({required this.userData});

  @override
  _ProfileSettingsScreenFState createState() => _ProfileSettingsScreenFState();
}

class _ProfileSettingsScreenFState extends State<ProfileSettingsScreenF> {
  ApiServiceProfileManagement apiService = ApiServiceProfileManagement();
  Uint8List? _imageBytes;
  String? _imageFileName;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  TextEditingController fullNameController = TextEditingController();
  TextEditingController pronounsController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController aboutMeController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  // Email verification variables
  bool _isEmailVerified = false;
  bool _isOtpSent = false;
  bool _isVerifying = false;
  bool _isUpdatingProfile = false;

  int? _userId;
  String _originalEmail = '';

  @override
  void initState() {
    super.initState();
    fetchProfileImageData();
    fetchUserProfileData();
    emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    emailController.removeListener(_onEmailChanged);
    emailController.dispose();
    fullNameController.dispose();
    pronounsController.dispose();
    roleController.dispose();
    departmentController.dispose();
    aboutMeController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    final currentEmail = emailController.text.trim();
    if (currentEmail != _originalEmail && currentEmail.isNotEmpty) {
      setState(() {
        _isEmailVerified = false;
        _isOtpSent = false;
      });
    }
  }

  Future<void> _uploadImageFile() async {
    final imagePicker = ImagePicker();
    try {
      final pickedImage =
          await imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        final imageBytes = await pickedImage.readAsBytes();
        setState(() {
          _imageBytes = imageBytes;
          _imageFileName = pickedImage.name;
        });
      }
    } catch (e) {
      print(e);
      _showErrorDialog('Failed to pick image');
    }
  }

  Future<void> fetchUserProfileData() async {
    setState(() {
      isLoading = true;
    });
    final token = await TokenManager.getToken();
    const String baseUrl = ApiConstants.baseUrl;
    const String apiUrl = '$baseUrl/api/user-profile';
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
        print('Response: ${response.body}');
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Load user verification data from SharedPreferences
        // final prefs = await SharedPreferences.getInstance();
        _userId = jsonData['userId'];
        _isEmailVerified = jsonData['isemailverified'] ?? false;

        setState(() {
          fullNameController.text = jsonData['fullName'] ?? '';
          pronounsController.text = jsonData['pronouns'] ?? '';
          roleController.text = jsonData['role'] ?? '';
          departmentController.text = jsonData['department'] ?? '';
          emailController.text = jsonData['email'] ?? '';
          aboutMeController.text = jsonData['about'] ?? '';

          // Set original email for comparison
          _originalEmail = jsonData['email'] ?? '';

          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to load profile data: $e');
    }
  }

  Future<void> fetchProfileImageData() async {
    final token = await TokenManager.getToken();
    const String baseUrl = ApiConstants.baseUrl;
    const String apiUrl = '$baseUrl/api/retrieve-image';

    // print('Image URL: $apiUrl');
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
        String responseData =
            response.body.replaceAll('"}', ''); // Remove trailing '"}'
        // print("Response: $responseData");
        // Find the index of the comma (",") after the prefix
        final commaIndex = responseData.indexOf(',');
        if (commaIndex != -1) {
          final imageData = responseData.substring(commaIndex + 1);
          // Decode base64-encoded image data
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
    } catch (e) {
      print('Error fetching image data: $e');
    }
  }

  Future<void> _submitImage() async {
    if (_imageBytes == null || _imageFileName == null) {
      _showErrorDialog('Please select an image first.');
      return;
    }
    try {
      final token = await TokenManager.getToken();
      await apiService.createFile(_imageBytes!, _imageFileName!, token!);
      _showSuccessDialog('Image uploaded successfully');
    } catch (e) {
      _showErrorDialog('Failed to upload image: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final email = emailController.text.trim();

      // Check if email has changed and is not verified
      if (email != _originalEmail && !_isEmailVerified) {
        _showErrorDialog('Please verify your email before saving changes');
        return;
      }
      setState(() {
        _isUpdatingProfile = true;
      });

      final profileData = {'fullName': fullNameController.text, 'email': email};

      final token = await TokenManager.getToken();
      const String baseUrl = ApiConstants.baseUrl;
      const String apiUrl = '$baseUrl/api/updateAppUser';
      try {
        final response = await http.put(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(profileData),
        );
        print('Update response: ${response.body}');
        print('Update status code: ${response.statusCode}');
        if (response.statusCode == 401) {
          LogoutService.logout();
          return;
        }
        if (response.statusCode <= 209) {
          print('Profile updated successfully');
          // Save updated data to SharedPreferences
          // final prefs = await SharedPreferences.getInstance();
          // await prefs.setString('user_email', email);
          // if (_isEmailVerified) {
          //   await prefs.setBool('is_email_verified', true);
          // }

          _showSuccessDialog('Profile updated successfully!');
          Navigator.of(context).pop();
        } else {
          print(response.statusCode);
          _showErrorDialog('Failed to update profile. Please try again.');
        }
      } catch (e) {
        _showErrorDialog('Failed to update profile: $e');
      } finally {
        setState(() {
          _isUpdatingProfile = false;
        });
      }
    }
  }

  Future<void> _logoutUser() async {
    try {
      String logouturl = "${ApiConstants.baseUrl}/token/logout";
      var response = await http.get(Uri.parse(logouturl));
      if (response.statusCode <= 209) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreenF(false)),
          (route) => false,
        );
      } else {
        _showErrorDialog('Failed to logout');
      }
    } catch (error) {
      _showErrorDialog('Error occurred during logout: $error');
    }
  }

  Future<void> _logoutAllSessions() async {
    try {
      String logouturl = "${ApiConstants.baseUrl}/token/logout/allsessions";
      var response = await http.get(Uri.parse(logouturl));
      if (response.statusCode <= 209) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreenF(false)),
          (route) => false,
        );
      } else {
        _showErrorDialog('Failed to logout');
      }
    } catch (error) {
      _showErrorDialog('Error occurred during logout: $error');
    }
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email input field
        CustomTextFormField(
          controller: emailController,
          hintText: 'Email',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),

        // Email verification status and button
        Row(
          children: [
            if (_isEmailVerified)
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Email verified',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Email not verified',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(width: 12),
            if (!_isEmailVerified)
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: _isVerifying ? null : _sendOtp,
                  icon: _isVerifying
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(Icons.email, size: 16),
                  label: Text(
                    _isVerifying ? 'Sending...' : 'Verify',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
          ],
        ),

        // OTP section
        if (_isOtpSent && !_isEmailVerified)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: Colors.blue[600], size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Email Verification',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the 6-digit code sent to ${emailController.text.trim()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          controller: otpController,
                          hintText: 'Enter OTP',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter OTP';
                            }
                            if (value.trim().length < 4) {
                              return 'Invalid OTP';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isVerifying ? null : _verifyOtp,
                          icon: _isVerifying
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : Icon(Icons.verified, size: 18),
                          label: Text(
                            _isVerifying ? 'Verifying...' : 'Verify OTP',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _isVerifying
                            ? null
                            : () {
                                setState(() {
                                  _isOtpSent = false;
                                  otpController.clear();
                                });
                              },
                        icon: Icon(Icons.close, size: 16),
                        label: Text('Cancel'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: _isVerifying ? null : _sendOtp,
                        icon: Icon(Icons.refresh, size: 16),
                        label: Text('Resend OTP'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue[600],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _sendOtp() async {
    if (_userId == null) {
      _showErrorDialog(
          'User ID not found. Please refresh the page and try again.');
      return;
    }

    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showErrorDialog('Please enter an email address');
      return;
    }

    if (!email.contains('@')) {
      _showErrorDialog('Please enter a valid email address');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final response = await apiService.sendEmailOTP(_userId!, email);
      if (response != null) {
        setState(() {
          _isOtpSent = true;
        });
        _showSuccessDialog('OTP sent to $email');
      } else {
        _showErrorDialog('Failed to send OTP. Please try again.');
      }
    } catch (e) {
      String errorMessage = 'Error sending OTP';
      if (e.toString().contains('400')) {
        errorMessage = 'Invalid email address';
      } else if (e.toString().contains('429')) {
        errorMessage =
            'Too many requests. Please wait a moment before trying again.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error. Please try again later.';
      } else if (e.toString().contains('network') ||
          e.toString().contains('timeout')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else {
        errorMessage =
            'Error sending OTP: ${e.toString().replaceAll('Exception:', '').trim()}';
      }
      _showErrorDialog(errorMessage);
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_userId == null) {
      _showErrorDialog(
          'User ID not found. Please refresh the page and try again.');
      return;
    }

    final email = emailController.text.trim();
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      _showErrorDialog('Please enter OTP');
      return;
    }

    if (otp.length < 4) {
      _showErrorDialog('Please enter a valid OTP');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final response = await apiService.verifyEmailOTP(_userId!, email, otp);
      if (response != null) {
        // Check if verification was successful
        final message = response['msg']?.toString() ?? '';
        final status = response['status']?.toString() ?? '';

        if (message.toLowerCase().contains('otp verified') ||
            message.toLowerCase().contains('success') ||
            status.toLowerCase() == 'success') {
          setState(() {
            _isEmailVerified = true;
            _isOtpSent = false;
            _originalEmail = email;
          });

          // Save verification status
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_email_verified', true);
          await prefs.setString('user_email', email);

          _showSuccessDialog('Email verified successfully!');
          otpController.clear();
        } else {
          _showErrorDialog(
              message.isNotEmpty ? message : 'Invalid OTP. Please try again.');
        }
      } else {
        _showErrorDialog('Failed to verify OTP. Please try again.');
      }
    } catch (e) {
      String errorMessage = 'Error verifying OTP';
      if (e.toString().contains('400')) {
        errorMessage = 'Invalid OTP. Please check and try again.';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Authentication failed. Please login again.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error. Please try again later.';
      } else if (e.toString().contains('network') ||
          e.toString().contains('timeout')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else {
        errorMessage =
            'Error verifying OTP: ${e.toString().replaceAll('Exception:', '').trim()}';
      }
      _showErrorDialog(errorMessage);
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              const Text('Error'),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              const Text('Success'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[200],
        title: Text(
          "Edit Profile",
          style: CustomTextStyles.titleLargePoppinsBlack,
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: const Color(0xFF219ebc),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBarWidget(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 24),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : GestureDetector(
                    onTap: _uploadImageFile,
                    child: Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                              radius: 100,
                              backgroundImage: _imageBytes != null
                                  ? MemoryImage(_imageBytes!)
                                  : null
                              // : AssetImage(ImageConstant.editModel)
                              //     as ImageProvider,
                              ),
                          Positioned(
                            bottom: 0,
                            right: 5,
                            child: IconButton(
                              onPressed: _uploadImageFile,
                              icon: const Icon(Icons.camera_alt),
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormSection(
                    title: "Personal Information",
                    children: [
                      _buildFormField(
                        label: "Full Name",
                        controller: fullNameController,
                        hintText: 'Enter your full name',
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your full name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        label: "Pronouns",
                        controller: pronounsController,
                        hintText: 'e.g., He/Him, She/Her, They/Them',
                      ),
                      const SizedBox(height: 16),
                      // _buildFormField(
                      //   label: "Role",
                      //   controller: roleController,
                      //   hintText: 'Enter your role',
                      // ),
                      // const SizedBox(height: 16),
                      // _buildFormField(
                      //   label: "Department",
                      //   controller: departmentController,
                      //   hintText: 'Enter your department',
                      // ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildFormSection(
                    title: "Contact Information",
                    children: [
                      _buildFormField(
                        label: "Email",
                        controller: emailController,
                        hintText: 'Enter your email',
                        customWidget: _buildEmailField(),
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        label: "About Me",
                        controller: aboutMeController,
                        hintText: 'Tell us about yourself',
                        maxLines: 3,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons Section
                  _buildActionButtonsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(
      {required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
    Widget? customWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        if (customWidget != null)
          customWidget
        else
          CustomTextFormField(
            controller: controller,
            hintText: hintText,
            validator: validator,
            maxLines: maxLines,
          ),
      ],
    );
  }

  Widget _buildActionButtonsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Actions",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),

          // Update Profile Button
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isUpdatingProfile ? null : _updateProfile,
              icon: _isUpdatingProfile
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(Icons.save, size: 18),
              label: Text(
                _isUpdatingProfile ? 'Updating...' : 'Update Profile',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Upload Image Button
          SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _submitImage,
              icon: Icon(Icons.upload, size: 18),
              label: Text(
                'Upload Profile Image',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue[600],
                side: BorderSide(color: Colors.blue[600]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Divider
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 16),

          // Logout Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: _logoutUser,
                    icon: Icon(Icons.logout, size: 16),
                    label: Text(
                      'Logout',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange[600],
                      side: BorderSide(color: Colors.orange[600]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: _logoutAllSessions,
                    icon: Icon(Icons.logout, size: 16),
                    label: Text(
                      'Logout All',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[600],
                      side: BorderSide(color: Colors.red[600]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
