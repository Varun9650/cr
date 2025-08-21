import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import '../../../data/network/network_api_service.dart';
import '../../../resources/api_constants.dart';
import '../LogoutService/Logoutservice.dart';

class ApiServiceProfileManagement {
  final String baseUrl = ApiConstants.baseUrl;
  final Dio dio = Dio();
  final NetworkApiService networkApiService = NetworkApiService();

  Future<void> createFile(
      Uint8List fileBytes, String fileName, String token) async {
    try {
      String apiUrl = "$baseUrl/api/upload";

      const mimeType = 'image/jpeg'; // You can set the appropriate MIME type

      FormData formData = FormData.fromMap({
        'imageFile': MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      });

      Dio dio = Dio(); // Create a new Dio instance
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.post(apiUrl, data: formData);
      print('completed');

      if (response.statusCode == 200) {
        // Handle successful response
        print('File uploaded successfully');
      } else {
        print('Failed to upload file with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred during form submission: $error');
    }
  }

  String lookupMimeType(String filePath) {
    final ext = filePath.split('.').last;
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      // Add more cases for other file types as needed
      default:
        return 'application/octet-stream'; // Default MIME type
    }
  }

  Future<String> getImage(String token, int userId) async {
    try {
      dio.options.headers['Authorization'] = 'Bearer $token';

      print(userId);

      final response =
          await dio.get('$baseUrl/userId/retrieve-image?UserId=${userId}');
      print('response is        $response');
      if (response.statusCode == 401) {
        LogoutService.logout();
      }
      final String imageFile = response.data;
      print(imageFile);

      if (response.statusCode! <= 209) {
        if (imageFile == null) {
          String f = 'assets/images/userImage.avif';
          return f;
        } else {
          return imageFile;
        }
      } else {
        throw Exception('errrorrrrrr isssss $response.statusMessage');
      }
    } catch (e) {
      throw Exception('Unable to fetch image: $e');
    }
  }

  // Send OTP for email verification
  Future<Map<String, dynamic>?> sendEmailOTP(int userId, String email) async {
    try {
      String apiUrl = "$baseUrl/api/appuser/otp";

      final response = await networkApiService.getPostApiResponse(
        apiUrl,
        {
          'userId': userId,
          'email': email.toLowerCase().trim(),
        },
      );

      if (response != null) {
        print('OTP sent successfully: $response');
        return response;
      } else {
        print('Failed to send OTP. Response was null.');
        return null;
      }
    } catch (error) {
      print('Error occurred during OTP sending: $error');
      return null;
    }
  }

  // Verify OTP for email verification
  Future<Map<String, dynamic>?> verifyEmailOTP(
      int userId, String email, String otp) async {
    try {
      String apiUrl = "$baseUrl/api/appuser/otp_verification";

      final response = await networkApiService.getPostApiResponse(
        apiUrl,
        {
          'userId': userId,
          'email': email.toLowerCase().trim(),
          'otp': otp,
        },
      );

      print('response is        $response');
      if (response != null) {
        print('OTP verification response: $response');
        return response;
      } else {
        print('Failed to verify OTP. Response was null.');
        return null;
      }
    } catch (error) {
      print('Error occurred during OTP verification: $error');
      return null;
    }
  }
}
