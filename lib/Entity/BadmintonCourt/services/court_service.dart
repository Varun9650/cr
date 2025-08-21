import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/court_model.dart';

class CourtService {
  static const String baseUrl =
      'https://your-api-base-url.com/api'; // Replace with your actual API base URL

  // Get all courts
  static Future<List<Court>> getAllCourts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/court/court'),
        headers: {
          'Content-Type': 'application/json',
          // Add your authentication headers here
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Court.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load courts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching courts: $e');
    }
  }

  // Add new court
  static Future<Court> addCourt(Court court) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/court/court'),
        headers: {
          'Content-Type': 'application/json',
          // Add your authentication headers here
        },
        body: json.encode(court.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return Court.fromJson(data);
      } else {
        throw Exception('Failed to add court: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding court: $e');
    }
  }

  // Update court
  static Future<Court> updateCourt(Court court) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/court/court/${court.id}'),
        headers: {
          'Content-Type': 'application/json',
          // Add your authentication headers here
        },
        body: json.encode(court.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Court.fromJson(data);
      } else {
        throw Exception('Failed to update court: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating court: $e');
    }
  }

  // Delete court
  static Future<bool> deleteCourt(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/court/court/$id'),
        headers: {
          'Content-Type': 'application/json',
          // Add your authentication headers here
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting court: $e');
    }
  }
}
