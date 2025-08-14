import 'package:cricyard/data/network/network_api_service.dart';
import '/resources/api_constants.dart';
import '../model/notification_model.dart';

class NotificationRepository {
  final NetworkApiService _networkApiService = NetworkApiService();

  /// Get notifications by user ID
  Future<List<NotificationModel>> getByUserId() async {
    try {
      final response = await _networkApiService.getGetApiResponse(
        '${ApiConstants.baseUrl}/notification/get_notification/userId',
      );

      if (response is List) {
        final entities = response.cast<Map<String, dynamic>>();
        return entities
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Invalid response format: expected List, got ${response.runtimeType}');
      }
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  /// Get notifications with pagination
  Future<List<NotificationModel>> getAllWithPagination(
      String token, int page, int size) async {
    try {
      final response = await _networkApiService.getGetApiResponse(
        '${ApiConstants.baseUrl}/notification/get_notification/getall/page?page=$page&size=$size',
      );

      if (response is Map<String, dynamic> && response.containsKey('content')) {
        final entities =
            (response['content'] as List).cast<Map<String, dynamic>>();
        return entities
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Invalid response format: expected Map with content, got ${response.runtimeType}');
      }
    } catch (e) {
      throw Exception('Failed to get notifications with pagination: $e');
    }
  }

  /// Accept a notification
  Future<void> acceptNotification(int notificationId) async {
    try {
      await _networkApiService.getPutApiResponse(
        '${ApiConstants.baseUrl}/notification/get_notification/accept/$notificationId',
        {},
      );
    } catch (e) {
      throw Exception('Failed to accept notification: $e');
    }
  }

  /// Ignore a notification
  Future<void> ignoreNotification(int notificationId) async {
    try {
      await _networkApiService.getPutApiResponse(
        '${ApiConstants.baseUrl}/notification/get_notification/ignored/$notificationId',
        {},
      );
    } catch (e) {
      throw Exception('Failed to ignore notification: $e');
    }
  }
}
