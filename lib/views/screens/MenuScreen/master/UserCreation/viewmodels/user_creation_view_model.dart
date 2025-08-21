import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../repositories/user_creation_repository.dart';

class UserCreationViewModel extends ChangeNotifier {
  final UserCreationRepository _repo = UserCreationRepository();

  // List state
  List<AppUserMin> _users = [];
  List<AppUserMin> _filteredUsers = [];
  bool _loading = false;
  String? _error;
  String _searchQuery = '';

  List<AppUserMin> get users => _users;
  List<AppUserMin> get filteredUsers => _filteredUsers;
  bool get isLoading => _loading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  // Form + OTP state
  bool emailVerifyToggle = true;
  bool otpSent = false;
  bool otpVerified = false;
  String? formError;

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterUsers();
    notifyListeners();
  }

  void _filterUsers() {
    if (_searchQuery.trim().isEmpty) {
      _filteredUsers = List.from(_users);
    } else {
      final query = _searchQuery.toLowerCase().trim();
      _filteredUsers = _users.where((user) {
        return (user.fullName?.toLowerCase().contains(query) ?? false) ||
            (user.email?.toLowerCase().contains(query) ?? false) ||
            (user.mobileNumber?.toLowerCase().contains(query) ?? false) ||
            (user.gender?.toLowerCase().contains(query) ?? false) ||
            (user.isEmailVerified == true && 'verified'.contains(query)) ||
            (user.isEmailVerified == false && 'unverified'.contains(query)) ||
            (user.isEmailVerified == false && 'pending'.contains(query));
      }).toList();
    }
  }

  void setEmailVerifyToggle(bool value) {
    emailVerifyToggle = value;
    // Reset OTP state when toggling
    otpSent = false;
    otpVerified = false;
    formError = null;
    notifyListeners();
  }

  void clearErrors() {
    _error = null;
    formError = null;
    notifyListeners();
  }

  Future<void> loadUsers() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _users = await _repo.getAllUsers();
      _filterUsers(); // Apply current search filte
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> sendOtp(String email) async {
    if (email.trim().isEmpty) {
      formError = 'Please enter a valid email address';
      notifyListeners();
      return false;
    }

    formError = null;
    notifyListeners();
    try {
      final res = await _repo.sendEmailOtp(email.trim());
      otpSent = true;
      return true;
    } catch (e) {
      formError = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> resendOtp(String email) async {
    if (email.trim().isEmpty) {
      formError = 'Please enter a valid email address';
      notifyListeners();
      return false;
    }

    try {
      await _repo.resendOtp(email.trim());
      otpSent = true;
      return true;
    } catch (e) {
      formError = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    if (email.trim().isEmpty) {
      formError = 'Please enter a valid email address';
      notifyListeners();
      return false;
    }

    if (otp.trim().isEmpty) {
      formError = 'Please enter the OTP';
      notifyListeners();
      return false;
    }

    formError = null;
    notifyListeners();
    try {
      final res = await _repo.verifyOtp(email.trim(), otp.trim());
      otpVerified = true;
      return true;
    } catch (e) {
      formError = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> addUser({
    required String email,
    required String fullName,
    required String gender,
    String? mobileNumber,
    String? password,
  }) async {
    // Validate required fields
    if (email.trim().isEmpty) {
      formError = 'Email is required';
      notifyListeners();
      return false;
    }

    if (fullName.trim().isEmpty) {
      formError = 'Full name is required';
      notifyListeners();
      return false;
    }

    if (gender.trim().isEmpty) {
      formError = 'Gender is required';
      notifyListeners();
      return false;
    }

    if (password != null &&
        password.trim().isNotEmpty &&
        password.trim().length < 6) {
      formError = 'Password must be at least 6 characters long';
      notifyListeners();
      return false;
    }

    formError = null;
    notifyListeners();
    try {
      if (emailVerifyToggle) {
        // Requires verified
        if (!otpVerified) {
          formError = 'Please verify email via OTP before creating user';
          notifyListeners();
          return false;
        }
        await _repo.addUserWithVerification(
          email: email.trim(),
          fullName: fullName.trim(),
          gender: gender.trim(),
          password: password?.trim(),
        );
      } else {
        await _repo.addUserDirect(
          email: email.trim(),
          fullName: fullName.trim(),
          gender: gender.trim(),
          mobileNumber: mobileNumber?.trim(),
          password: password?.trim(),
        );
      }
      await loadUsers();
      return true;
    } catch (e) {
      formError = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updateUser({
    required int userId,
    required String fullName,
    required String gender,
    String? mobileNumber,
  }) async {
    // Validate required fields
    if (fullName.trim().isEmpty) {
      formError = 'Full name is required';
      notifyListeners();
      return false;
    }

    if (gender.trim().isEmpty) {
      formError = 'Gender is required';
      notifyListeners();
      return false;
    }

    formError = null;
    notifyListeners();
    try {
      final user = AppUserMin(
          id: userId,
          fullName: fullName.trim(),
          gender: gender.trim(),
          mobileNumber: mobileNumber?.trim());
      await _repo.updateUser(userId: userId, user: user);
      await loadUsers();
      return true;
    } catch (e) {
      formError = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      final ok = await _repo.deleteUser(userId);
      await loadUsers();
      return ok;
    } catch (e) {
      formError = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }
}
