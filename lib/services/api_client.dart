import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/trip.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'http://localhost/backend';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  final http.Client _client;

  Future<void> login(String username, String password) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Login failed: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final token = body['token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Token missing from login response');
    }

    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<String> _requireToken() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) {
      throw Exception('You must log in first.');
    }

    return token;
  }

  Future<void> addTrip({
    required double distance,
    required int duration,
    required double fare,
    required String date,
  }) async {
    final token = await _requireToken();
    final response = await _client.post(
      Uri.parse('$baseUrl/add_trip.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'distance': distance,
        'duration': duration,
        'fare': fare,
        'date': date,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Add trip failed: ${response.body}');
    }
  }

  Future<List<Trip>> fetchTrips() async {
    final token = await _requireToken();
    final response = await _client.get(
      Uri.parse('$baseUrl/get_trips.php'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Fetch trips failed: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final trips = (body['trips'] as List<dynamic>)
        .map((trip) => Trip.fromJson(trip as Map<String, dynamic>))
        .toList();

    return trips;
  }

  Future<void> deleteTrip(int id) async {
    final token = await _requireToken();
    final response = await _client.post(
      Uri.parse('$baseUrl/delete_trip.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode != 200) {
      throw Exception('Delete trip failed: ${response.body}');
    }
  }
}
