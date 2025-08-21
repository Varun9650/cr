import 'dart:io';
import 'package:cricyard/main.dart';
import 'package:cricyard/providers/token_manager.dart';
import 'package:cricyard/views/screens/Login%20Screen/view/login_screen_f.dart';
import 'package:dio/dio.dart';
import '../exceptions/app_exceptions.dart';
import 'base_network_service.dart';
import 'package:flutter/material.dart';
// You should have a global navigator key in your app, e.g. in main.dart:
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// and use it in MaterialApp(navigatorKey: navigatorKey, ...)

class NetworkApiService extends BaseNetworkService {
  final Dio _dio = Dio();

  NetworkApiService() {
    // Optionally configure Dio, e.g. add interceptors
    _dio.options.connectTimeout = const Duration(seconds: 90);
    _dio.options.receiveTimeout = const Duration(seconds: 90);
  }

  @override
  Future<dynamic> getGetApiResponse(String? url) async {
    try {
      final token = await TokenManager.getToken();

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // Add other headers if needed
      };
      final response = await _dio.get(
        url!,
        options: Options(headers: headers),
      );
      // print('url is $url anf resp is $response');
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } catch (e) {
      throw FetchDataException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<dynamic> getPostApiResponse(String? url, dynamic body) async {
    try {
      print("Token Value:  ");
      final token = await TokenManager.getToken();
      print('$token,  and body: $body');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // Add other headers if needed
      };
      final response = await _dio.post(
        url!,
        data: body,
        options: Options(headers: headers),
      );
      print('url is $url and resp is $response');
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } catch (e) {
      throw FetchDataException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<dynamic> getPutApiResponse(String? url, dynamic body) async {
    try {
      final token = await TokenManager.getToken();

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // Add other headers if needed
      };
      final response = await _dio.put(
        url!,
        data: body,
        options: Options(headers: headers),
      );
      print('url is $url and resp is $response');
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } catch (e) {
      print('Error in getPutApiResponse: $e');
      throw FetchDataException('An unexpected error occurred: $e');
    }
  }

  @override
  Future<dynamic> getDeleteApiResponse(String? url) async {
    try {
      final token = await TokenManager.getToken();

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // Add other headers if needed
      };
      final response = await _dio.delete(
        url!,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } catch (e) {
      throw FetchDataException('An unexpected error occurred: $e');
    }
  }

  dynamic _handleResponse(Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          // print('response data is $response');
          // Handle empty body
          if (response.data == null || response.data.toString().isEmpty) {
            return null;
          }
          return response.data;
        } catch (e) {
          throw FetchDataException('Error parsing response: $e');
        }
      case 400:
        throw BadRequestException('Bad request: ${response.data}');
      case 401:
        // Show message and redirect to login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = navigatorKey.currentContext;
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login expired. Please login again.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
            // Remove all previous routes and push login
            {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const LoginScreenF(false)),
                (route) => false, // Remove all routes from the stack
              );
            }
          }
        });
        throw UnauthorizedException('Unauthorized request: ${response.data}');
      case 403:
        throw ForbiddenException('Forbidden request: ${response.data}');
      case 404:
        throw NotFoundException('Not found: ${response.data}');
      case 500:
        throw InternalServerErrorException('Server error: ${response.data}');
      default:
        throw FetchDataException(
            'Error while communicating with server: ${response.statusCode}');
    }
  }

  dynamic _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw FetchDataException("Request timed out.");
      case DioExceptionType.badResponse:
        return _handleResponse(error.response!);
      case DioExceptionType.cancel:
        throw FetchDataException("Request was cancelled.");
      case DioExceptionType.connectionError:
        throw FetchDataException("Connection failed due to internet issue.");
      default:
        throw FetchDataException("Unexpected error occurred.");
    }
  }

  // File upload method
  Future<dynamic> uploadFile(String url, dynamic file) async {
    try {
      final token = await TokenManager.getToken();

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      };

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path,
            filename: file.path.split('/').last),
      });

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: headers),
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    } catch (e) {
      throw FetchDataException('An unexpected error occurred: $e');
    }
  }
}
