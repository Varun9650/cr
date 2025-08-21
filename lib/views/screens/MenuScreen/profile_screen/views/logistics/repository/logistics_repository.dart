import '../../../../../../../data/network/network_api_service.dart';
import '../../../../../../../resources/api_constants.dart';
import '../models/logistics_model.dart';

class LogisticsRepository {
  final NetworkApiService _networkApiService = NetworkApiService();

  Future<LogisticsData> fetchLogisticsData() async {
    try {
      final response = await _networkApiService.getGetApiResponse(
        ApiConstants.getParticipantLogistics,
      );

      print('Response from API for logistics : $response');
      if (response is Map<String, dynamic>) {
        return LogisticsData.fromJson(response);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw Exception('Failed to fetch logistics data: $e');
    }
  }
}
