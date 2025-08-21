import 'package:cricyard/resources/api_constants.dart';
import 'package:cricyard/data/network/network_api_service.dart';

import '../models/user_model.dart';

class UserCreationRepository {
  final NetworkApiService _net = NetworkApiService();
  String get _base => ApiConstants.baseUrl;

  Future<List<AppUserMin>> getAllUsers() async {
    try {
      final res =
          await _net.getGetApiResponse(ApiConstants.getUsersForRoleMgmt);
      final list = (res as List).cast<Map<String, dynamic>>();
      return list.map((e) => AppUserMin.fromJson(e)).toList();
    } catch (e) {
      throw _formatError('Failed to load users', e);
    }
  }

  Future<Map<String, dynamic>> sendEmailOtp(String email) async {
    try {
      final body = {'email': email};
      final res =
          await _net.getPostApiResponse('$_base/token/user/send_email', body);
      return (res as Map).cast<String, dynamic>();
    } catch (e) {
      throw _formatError('Failed to send OTP', e);
    }
  }

  Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      final res = await _net
          .getPostApiResponse('$_base/token/user/resend_otp?email=$email', {});
      return (res as Map).cast<String, dynamic>();
    } catch (e) {
      throw _formatError('Failed to send OTP', e);
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final res = await _net.getPostApiResponse(
          '$_base/token/user/otp_verification?email=$email&otp=$otp', {});
      return (res as Map).cast<String, dynamic>();
    } catch (e) {
      throw _formatError('Failed to verify OTP', e);
    }
  }

  Future<Map<String, dynamic>> addUserWithVerification({
    required String email,
    required String fullName,
    required String gender,
    String? password,
  }) async {
    try {
      final reg = {
        'email': email,
        'fullName': fullName,
        'gender': gender,
        if (password != null && password.isNotEmpty) 'new_password': password,
        if (password != null && password.isNotEmpty)
          'confirm_password': password,
      };
      final res = await _net.getPostApiResponse('$_base/api/add', reg);
      return (res as Map).cast<String, dynamic>();
    } catch (e) {
      throw _formatError('Failed to create user with verification', e);
    }
  }

  Future<Map<String, dynamic>> addUserDirect({
    required String email,
    required String fullName,
    required String gender,
    String? mobileNumber,
    String? password,
  }) async {
    try {
      final reg = {
        'email': email,
        'fullName': fullName,
        'gender': gender,
        if (mobileNumber != null && mobileNumber.isNotEmpty)
          'mob_no': int.tryParse(mobileNumber),
        if (password != null && password.isNotEmpty) 'new_password': password,
        if (password != null && password.isNotEmpty)
          'confirm_password': password,
      }..removeWhere((k, v) => v == null);
      final res = await _net.getPostApiResponse('$_base/api/add', reg);
      return (res as Map).cast<String, dynamic>();
    } catch (e) {
      throw _formatError('Failed to create user directly', e);
    }
  }

  Future<Map<String, dynamic>> updateUser({
    required int userId,
    required AppUserMin user,
  }) async {
    try {
      final res = await _net.getPutApiResponse(
          '$_base/api/updateAppUserDto/$userId', user.toUpdateJson());
      return (res as Map).cast<String, dynamic>();
    } catch (e) {
      throw _formatError('Failed to update user', e);
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      final res =
          await _net.getDeleteApiResponse('$_base/api/delete_usr/$userId');
      if (res is Map &&
          (res['msg']?.toString().toLowerCase().contains('deleted') ?? false))
        return true;
      return true; // if backend returns empty body
    } catch (e) {
      throw _formatError('Failed to delete user', e);
    }
  }

  String _formatError(String operation, dynamic error) {
    String errorMessage = error.toString();

    // Handle different error types
    if (errorMessage.contains('400') || errorMessage.contains('Bad Request')) {
      return 'Invalid request data. Please check your input and try again.';
    } else if (errorMessage.contains('401') ||
        errorMessage.contains('Unauthorized')) {
      return 'Authentication failed. Please login again.';
    } else if (errorMessage.contains('403') ||
        errorMessage.contains('Forbidden')) {
      return 'You do not have permission to perform this action.';
    } else if (errorMessage.contains('404') ||
        errorMessage.contains('Not Found')) {
      return 'The requested resource was not found.';
    } else if (errorMessage.contains('409') ||
        errorMessage.contains('Conflict')) {
      return 'User with this email already exists.';
    } else if (errorMessage.contains('422') ||
        errorMessage.contains('Unprocessable Entity')) {
      return 'Invalid data provided. Please check your input.';
    } else if (errorMessage.contains('500') ||
        errorMessage.contains('Internal Server Error')) {
      return 'Server error occurred. Please try again later.';
    } else if (errorMessage.contains('timeout') ||
        errorMessage.contains('Timeout')) {
      return 'Request timed out. Please check your internet connection and try again.';
    } else if (errorMessage.contains('network') ||
        errorMessage.contains('Network')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorMessage.contains('SocketException')) {
      return 'Unable to connect to server. Please check your internet connection.';
    } else if (errorMessage.contains('FormatException')) {
      return 'Invalid response format from server.';
    } else {
      // Extract meaningful error message from response if available
      if (errorMessage.contains('{') && errorMessage.contains('}')) {
        try {
          // Try to parse JSON error response
          final startIndex = errorMessage.indexOf('{');
          final endIndex = errorMessage.lastIndexOf('}') + 1;
          final jsonStr = errorMessage.substring(startIndex, endIndex);
          // You could parse this JSON to extract specific error messages
          return 'Server error: ${errorMessage.substring(0, startIndex).trim()}';
        } catch (e) {
          return '$operation failed: ${errorMessage.replaceAll('Exception:', '').trim()}';
        }
      }
      return '$operation failed: ${errorMessage.replaceAll('Exception:', '').trim()}';
    }
  }
}
