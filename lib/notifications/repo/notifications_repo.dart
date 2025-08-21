import 'package:cricyard/data/network/base_network_service.dart';
import 'package:cricyard/data/network/network_api_service.dart';
import 'package:cricyard/resources/api_constants.dart';

class NotificationsRepo {
  final BaseNetworkService _networkService = NetworkApiService();

  Future<dynamic> getUnseenNotifications(dynamic headers) async {
    try {
      final response = await _networkService
          .getGetApiResponse(ApiConstants.getUnseenNotifications);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getSeenNotifications(dynamic headers, dynamic id) async {
    final uri = Uri.parse("${ApiConstants.getSeenNotifications}/$id");
    try {
      final response = await _networkService.getGetApiResponse(uri.toString());
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getNotifications() async {
    try {
      final response = await _networkService
          .getGetApiResponse(ApiConstants.getNotifications);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getAllReadableNotifications(dynamic queryParam) async {
    try {
      // Construct the URI with the flag as a query parameter
      final uri = Uri.parse(ApiConstants.getAllReadableNotifications)
          .replace(queryParameters: queryParam);

      // Make the API request
      final response = await _networkService.getGetApiResponse(uri.toString());

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> markAllAsRead(dynamic headers) async {
    try {
      final response = await _networkService.getPutApiResponse(
          ApiConstants.updateToMarkReadAllNotifications, null);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> markSingleAsRead(dynamic headers, dynamic id) async {
    try {
      final response = await _networkService.getPutApiResponse(
          "${ApiConstants.markSingleNotificationRead}/$id", null);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Mark a notification as read using the new API endpoint
  Future<dynamic> markNotificationAsRead(String notificationId) async {
    try {
      final response = await _networkService.getPutApiResponse(
          "${ApiConstants.baseUrl}/token/notification/get_notification/read/$notificationId",
          null);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Accept a notification
  Future<dynamic> acceptNotification(String notificationId) async {
    try {
      final response = await _networkService.getPutApiResponse(
          "${ApiConstants.baseUrl}/notification/get_notification/accept/$notificationId",
          null);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Ignore a notification
  Future<dynamic> ignoreNotification(String notificationId) async {
    try {
      final response = await _networkService.getPutApiResponse(
          "${ApiConstants.baseUrl}/notification/get_notification/ignored/$notificationId",
          null);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
