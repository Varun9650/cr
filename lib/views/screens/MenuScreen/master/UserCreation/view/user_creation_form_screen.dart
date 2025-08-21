import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../viewmodels/user_creation_view_model.dart';
import '../models/user_model.dart';

class UserCreationFormScreen extends StatefulWidget {
  final AppUserMin? user;
  const UserCreationFormScreen({Key? key, this.user}) : super(key: key);

  @override
  State<UserCreationFormScreen> createState() => _UserCreationFormScreenState();
}

class _UserCreationFormScreenState extends State<UserCreationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  String _gender = 'Male';

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _emailController.text = widget.user!.email ?? '';
      _fullNameController.text = widget.user!.fullName ?? '';
      _gender = widget.user!.gender ?? 'Male';
      _mobileController.text = widget.user!.mobileNumber ?? '';
    } else {
      _passwordController.text = '123456';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _fullNameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;
    return ChangeNotifierProvider(
      create: (_) => UserCreationViewModel(),
      child: Builder(builder: (context) {
        final vm = Provider.of<UserCreationViewModel>(context);
        // If editing, disable email verify toggle and OTP section
        final verificationEnabled = !isEditing && vm.emailVerifyToggle;
        return Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF264653),
            elevation: 0,
            title: Text(
              isEditing ? 'Edit User' : 'Add User',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderCard(isEditing),
                  const SizedBox(height: 16),
                  _buildFormCard(vm, isEditing, verificationEnabled),
                  const SizedBox(height: 16),
                  _buildActionButtons(vm, isEditing, verificationEnabled),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeaderCard(bool isEditing) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_add,
                color: Colors.blue,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Edit User Details' : 'Create New User',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEditing
                        ? 'Update user information'
                        : 'Verify email or create directly',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(
      UserCreationViewModel vm, bool isEditing, bool verificationEnabled) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Email Verification',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Switch(
                  value: isEditing ? false : vm.emailVerifyToggle,
                  onChanged: isEditing
                      ? null
                      : (v) {
                          vm.setEmailVerifyToggle(v);
                        },
                  activeColor: Colors.green,
                  activeTrackColor: Colors.green.withOpacity(0.3),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.withOpacity(0.3),
                )
              ],
            ),
            const SizedBox(height: 16),
            _textField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter email',
              icon: Icons.email,
              enabled: !isEditing, // don't allow email edit
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email required';
                if (!v.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: 12),
            if (!isEditing)
              _textField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter password',
                icon: Icons.password,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password required';
                  if (v.length < 6)
                    return 'Password must be at least 6 characters';
                  return null;
                },
              ),
            if (!isEditing) const SizedBox(height: 12),
            if (verificationEnabled) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: vm.isLoading
                          ? null
                          : () async {
                              if (_emailController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('Please enter email first'),
                                  backgroundColor: Colors.orange,
                                ));
                                return;
                              }
                              final ok = await vm
                                  .sendOtp(_emailController.text.trim());
                              if (ok) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('OTP sent successfully'),
                                  backgroundColor: Colors.green,
                                ));
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      vm.formError ?? 'Failed to send OTP'),
                                  backgroundColor: Colors.red,
                                ));
                              }
                            },
                      icon: vm.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send),
                      label: Text(vm.isLoading ? 'Sending...' : 'Send OTP',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF264653),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (vm.otpSent)
                    ElevatedButton(
                      onPressed: vm.isLoading
                          ? null
                          : () async {
                              await vm.resendOtp(_emailController.text.trim());
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(vm.formError == null
                                    ? 'OTP resent successfully'
                                    : vm.formError!),
                                backgroundColor: vm.formError == null
                                    ? Colors.green
                                    : Colors.red,
                              ));
                            },
                      child: Text(
                        vm.isLoading ? 'Resending...' : 'Resend',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _textField(
                controller: _otpController,
                label: 'OTP',
                hint: 'Enter OTP',
                icon: Icons.password,
                enabled: vm.otpSent && !vm.otpVerified && !vm.isLoading,
                validator: (v) {
                  if (!verificationEnabled) return null;
                  if (!vm.otpSent) return null;
                  if (vm.otpVerified) return null;
                  if (v == null || v.trim().isEmpty) return 'OTP required';
                  if (v.length < 4) return 'Invalid OTP';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: (vm.otpSent && !vm.otpVerified && !vm.isLoading)
                      ? () async {
                          if (_otpController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Please enter OTP first'),
                              backgroundColor: Colors.orange,
                            ));
                            return;
                          }
                          final ok = await vm.verifyOtp(
                              _emailController.text.trim(),
                              _otpController.text.trim());
                          if (ok) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('OTP verified successfully'),
                              backgroundColor: Colors.green,
                            ));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text(vm.formError ?? 'Failed to verify OTP'),
                              backgroundColor: Colors.red,
                            ));
                          }
                        }
                      : null,
                  icon: vm.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.verified),
                  label: Text(
                    vm.isLoading ? 'Verifying...' : 'Verify OTP',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (vm.otpVerified)
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 18),
                    const SizedBox(width: 6),
                    Text('Email verified',
                        style: GoogleFonts.poppins(
                            color: Colors.green, fontWeight: FontWeight.w600)),
                  ],
                ),
              const SizedBox(height: 16),
            ],

            // Details section
            _textField(
              controller: _fullNameController,
              label: 'Full Name',
              hint: 'Enter full name',
              icon: Icons.person,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Full name required';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _genderDropdown(),
            const SizedBox(height: 12),
            if (!verificationEnabled) // direct flow asks for mobile
              _textField(
                controller: _mobileController,
                label: 'Mobile Number',
                hint: 'Enter mobile number',
                icon: Icons.phone,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (!verificationEnabled) {
                    if (v == null || v.trim().isEmpty) return 'Mobile required';
                  }
                  return null;
                },
              ),

            if (vm.formError != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        vm.formError!,
                        style: GoogleFonts.poppins(
                            color: Colors.red, fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.close, color: Colors.red, size: 18),
                      onPressed: () => vm.clearErrors(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _genderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender',
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _gender,
          items: const [
            DropdownMenuItem(value: 'Male', child: Text('Male')),
            DropdownMenuItem(value: 'Female', child: Text('Female')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
          ],
          onChanged: (v) => setState(() => _gender = v ?? 'Male'),
          dropdownColor: const Color(0xFF34495E),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF34495E),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          ),
          iconEnabledColor: Colors.white,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      UserCreationViewModel vm, bool isEditing, bool verificationEnabled) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: vm.isLoading ? null : () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Cancel',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: vm.isLoading
                ? null
                : () async {
                    if (!_formKey.currentState!.validate()) return;

                    if (isEditing) {
                      final ok = await vm.updateUser(
                        userId: widget.user!.id!,
                        fullName: _fullNameController.text.trim(),
                        gender: _gender,
                        mobileNumber: _mobileController.text.trim().isEmpty
                            ? null
                            : _mobileController.text.trim(),
                      );
                      if (ok && mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('User updated successfully'),
                          backgroundColor: Colors.green,
                        ));
                        Navigator.pop(context);
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text(vm.formError ?? 'Failed to update user'),
                          backgroundColor: Colors.red,
                        ));
                      }
                    } else {
                      final ok = await vm.addUser(
                        email: _emailController.text.trim(),
                        fullName: _fullNameController.text.trim(),
                        gender: _gender,
                        mobileNumber: _mobileController.text.trim().isEmpty
                            ? null
                            : _mobileController.text.trim(),
                        password: _passwordController.text.trim(),
                      );
                      if (ok && mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('User created successfully'),
                          backgroundColor: Colors.green,
                        ));
                        Navigator.pop(context);
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text(vm.formError ?? 'Failed to create user'),
                          backgroundColor: Colors.red,
                        ));
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF264653),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: vm.isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEditing ? 'Updating...' : 'Creating...',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  )
                : Text(
                    isEditing ? 'Update' : 'Save',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          validator: validator,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                GoogleFonts.poppins(fontSize: 16, color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFF34495E),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue, width: 2)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
