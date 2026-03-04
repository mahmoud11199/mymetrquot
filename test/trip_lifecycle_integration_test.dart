import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mymetrquot/models/user.dart';
import 'package:mymetrquot/screens/home_screen.dart';
import 'package:mymetrquot/screens/notifications_screen.dart';
import 'package:mymetrquot/services/api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const storageChannel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final storage = <String, String>{};

  setUp(() async {
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.com/backend');
    storage.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, (MethodCall call) async {
      final key = (call.arguments as Map<dynamic, dynamic>)['key'] as String;
      switch (call.method) {
        case 'write':
          storage[key] = (call.arguments as Map<dynamic, dynamic>)['value'] as String;
          return null;
        case 'read':
          return storage[key];
        case 'delete':
          storage.remove(key);
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, null);
  });

  test('full trip lifecycle API integration flow', () async {
    final client = MockClient((request) async {
      final path = request.url.path;
      if (path.endsWith('/login.php')) {
        return http.Response(
          jsonEncode({
            'token': 'token-123',
            'user': {'id': 1, 'username': 'rider1', 'role': 'rider'},
          }),
          200,
        );
      }
      if (path.endsWith('/create_ride_request.php')) {
        return http.Response(jsonEncode({'ride_request_id': 11}), 201);
      }
      if (path.endsWith('/create_offer.php')) {
        return http.Response(jsonEncode({'offer_id': 22}), 201);
      }
      if (path.endsWith('/send_message.php')) {
        return http.Response(jsonEncode({'message_id': 33}), 201);
      }
      if (path.endsWith('/get_messages.php')) {
        return http.Response(
          jsonEncode({
            'messages': [
              {'id': 33, 'content': 'Deal at 70?'}
            ]
          }),
          200,
        );
      }
      if (path.endsWith('/add_trip.php')) {
        return http.Response(jsonEncode({'trip_id': 44}), 201);
      }
      if (path.endsWith('/update_trip_status.php')) {
        return http.Response(jsonEncode({'ok': true}), 200);
      }
      if (path.endsWith('/submit_rating.php')) {
        return http.Response(jsonEncode({'rating_id': 55}), 201);
      }
      throw Exception('Unhandled request: ${request.url}');
    });

    final apiClient = ApiClient(client: client);

    final loginResponse = await apiClient.login('rider1', 'pass');
    expect(loginResponse['token'], 'token-123');

    final requestId = await apiClient.createRideRequest({
      'pickup_lat': 1,
      'pickup_lng': 2,
      'dropoff_lat': 3,
      'dropoff_lng': 4,
      'pickup_address': 'A',
      'dropoff_address': 'B',
      'estimated_fare': 70,
    });
    expect(requestId, 11);

    final offerId = await apiClient.createOffer({'ride_request_id': requestId, 'proposed_fare': 70});
    expect(offerId, 22);

    final messageId = await apiClient.sendMessage(
      rideRequestId: requestId,
      receiverId: 2,
      content: 'Deal at 70?',
    );
    expect(messageId, 33);

    final messages = await apiClient.fetchMessages(requestId);
    expect(messages, isNotEmpty);

    await apiClient.addTrip(riderId: 1, driverId: 2, fare: 70, rideRequestId: requestId, offerId: offerId);
    await apiClient.updateTripStatus(44, 'completed');
    await apiClient.submitRating(tripId: 44, rateeId: 2, score: 5, comment: 'Great trip');
  });

  testWidgets('UI handling: trips and notifications are rendered', (tester) async {
    final client = MockClient((request) async {
      final path = request.url.path;
      if (path.endsWith('/login.php')) {
        return http.Response(
          jsonEncode({
            'token': 'token-123',
            'user': {'id': 1, 'username': 'rider1', 'role': 'rider'},
          }),
          200,
        );
      }
      if (path.endsWith('/get_trips.php')) {
        return http.Response(
          jsonEncode({
            'trips': [
              {'id': 1, 'distance_km': 2.5, 'duration_sec': 600, 'fare': 40, 'status': 'created'}
            ]
          }),
          200,
        );
      }
      if (path.endsWith('/get_notifications.php')) {
        return http.Response(
          jsonEncode({
            'notifications': [
              {'id': 99, 'message': 'Offer received', 'is_read': 0}
            ]
          }),
          200,
        );
      }
      if (path.endsWith('/mark_notification_read.php')) {
        return http.Response(jsonEncode({'ok': true}), 200);
      }
      throw Exception('Unhandled request: ${request.url}');
    });

    final apiClient = ApiClient(client: client);
    await apiClient.login('rider1', 'pass');

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          user: const User(id: 1, username: 'rider1', role: 'rider'),
          apiClient: apiClient,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Trip #1'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(home: NotificationsScreen(apiClient: apiClient)));
    await tester.pumpAndSettle();
    expect(find.text('Offer received'), findsOneWidget);
  });
}
