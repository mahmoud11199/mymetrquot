import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/trip.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2/backend';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  final http.Client _client;

  Future<Map<String, dynamic>> login(String username, String password) async {
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
    return body;
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/register.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Register failed: ${response.body}');
    }
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

  Future<Map<String, String>> _authHeaders({bool json = false}) async {
    final token = await _requireToken();
    return {
      if (json) 'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<int> createRideRequest(Map<String, dynamic> payload) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/create_ride_request.php'),
      headers: await _authHeaders(json: true),
      body: jsonEncode(payload),
    );
    if (response.statusCode != 201) {
      throw Exception('Create ride request failed: ${response.body}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['ride_request_id'] as num).toInt();
  }

  Future<List<Map<String, dynamic>>> fetchRideRequests() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/get_ride_requests.php'),
      headers: await _authHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Fetch ride requests failed: ${response.body}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['ride_requests'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<int> createOffer(Map<String, dynamic> payload) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/create_offer.php'),
      headers: await _authHeaders(json: true),
      body: jsonEncode(payload),
    );
    if (response.statusCode != 201) {
      throw Exception('Create offer failed: ${response.body}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['offer_id'] as num).toInt();
  }

  Future<List<Map<String, dynamic>>> fetchOffers(int rideRequestId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/get_offers.php?ride_request_id=$rideRequestId'),
      headers: await _authHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Fetch offers failed: ${response.body}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['offers'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<void> updateOfferStatus(int offerId, String status) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/update_offer_status.php'),
      headers: await _authHeaders(json: true),
      body: jsonEncode({'offer_id': offerId, 'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Update offer status failed: ${response.body}');
    }
  }

  Future<void> addTrip({
    required int riderId,
    required int driverId,
    required double fare,
    double distanceKm = 0,
    int durationSec = 0,
    int? rideRequestId,
    int? offerId,
    String status = 'created',
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/add_trip.php'),
      headers: await _authHeaders(json: true),
      body: jsonEncode({
        'rider_id': riderId,
        'driver_id': driverId,
        'fare': fare,
        'distance_km': distanceKm,
        'duration_sec': durationSec,
        'ride_request_id': rideRequestId,
        'offer_id': offerId,
        'status': status,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Add trip failed: ${response.body}');
    }
  }

  Future<List<Trip>> fetchTrips() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/get_trips.php'),
      headers: await _authHeaders(),
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

  Future<void> updateTripStatus(int tripId, String status) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/update_trip_status.php'),
      headers: await _authHeaders(json: true),
      body: jsonEncode({'trip_id': tripId, 'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Update trip failed: ${response.body}');
    }
  }

  Future<void> deleteTrip(int id) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/delete_trip.php'),
      headers: await _authHeaders(json: true),
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode != 200) {
      throw Exception('Delete trip failed: ${response.body}');
    }
  }

  Future<int> sendMessage({
    required int rideRequestId,
    required int receiverId,
    required String content,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/send_message.php'),
      headers: await _authHeaders(json: true),
      body: jsonEncode({
        'ride_request_id': rideRequestId,
        'receiver_id': receiverId,
        'content': content,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Send message failed: ${response.body}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['message_id'] as num).toInt();
  }

  Future<List<Map<String, dynamic>>> fetchMessages(int rideRequestId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/get_messages.php?ride_request_id=$rideRequestId'),
      headers: await _authHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Fetch messages failed: ${response.body}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['messages'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<void> submitRating({
    required int tripId,
    required int rateeId,
    required int score,
    String? comment,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/submit_rating.php'),
      headers: await _authHeaders(json: true),
      body: jsonEncode({
        'trip_id': tripId,
        'ratee_id': rateeId,
        'score': score,
        'comment': comment,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Submit rating failed: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final response = await _client.get(
      Uri.parse('$baseUrl/get_notifications.php'),
      headers: await _authHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Fetch notifications failed: ${response.body}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['notifications'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<void> markNotificationRead(int id) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/mark_notification_read.php'),
      headers: await _authHeaders(json: true),
      body: jsonEncode({'id': id}),
    );
    if (response.statusCode != 200) {
      throw Exception('Mark notification failed: ${response.body}');
    }
  }

  Future<void> updateLiveLocation({
    required int tripId,
    required double lat,
    required double lng,
    double speedKmh = 0,
    double heading = 0,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/update_location.php'),
      headers: await _authHeaders(json: true),
      body: jsonEncode({
        'trip_id': tripId,
        'lat': lat,
        'lng': lng,
        'speed_kmh': speedKmh,
        'heading': heading,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Location update failed: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchTripRoute(int tripId) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/get_trip_route.php?trip_id=$tripId'),
      headers: await _authHeaders(),
    );
    if (response.statusCode != 200) {
      throw Exception('Fetch route failed: ${response.body}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['route'] as List<dynamic>).cast<Map<String, dynamic>>();
  }
}
