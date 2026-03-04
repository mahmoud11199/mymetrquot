import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymetrquot/models/trip.dart';
import 'package:mymetrquot/models/user.dart';
import 'package:mymetrquot/screens/home_screen.dart';
import 'package:mymetrquot/screens/notifications_screen.dart';
import 'package:mymetrquot/screens/ratings_screen.dart';
import 'package:mymetrquot/screens/ride_request_details_screen.dart';
import 'package:mymetrquot/screens/trip_live_screen.dart';
import 'package:mymetrquot/services/api_client.dart';

class FakeApiClient extends ApiClient {
  final List<Trip> trips;
  final List<Map<String, dynamic>> notifications;
  final List<Map<String, dynamic>> offers;
  final List<Map<String, dynamic>> messages;

  int createdRideRequests = 0;
  int createdOffers = 0;
  int sentMessages = 0;
  int updatedTripStatuses = 0;
  int submittedRatings = 0;

  FakeApiClient({
    this.trips = const [],
    this.notifications = const [],
    this.offers = const [],
    this.messages = const [],
  });

  @override
  Future<List<Trip>> fetchTrips() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return trips;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return notifications;
  }

  @override
  Future<void> markNotificationRead(int id) async {}

  @override
  Future<int> createRideRequest(Map<String, dynamic> payload) async {
    createdRideRequests++;
    return 10;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchOffers(int rideRequestId) async => offers;

  @override
  Future<int> createOffer(Map<String, dynamic> payload) async {
    createdOffers++;
    return 99;
  }

  @override
  Future<void> updateOfferStatus(int offerId, String status) async {}

  @override
  Future<void> addTrip({
    required int riderId,
    required int driverId,
    required double fare,
    double distanceKm = 0,
    int durationSec = 0,
    int? rideRequestId,
    int? offerId,
    String status = 'created',
  }) async {}

  @override
  Future<List<Map<String, dynamic>>> fetchMessages(int rideRequestId) async => messages;

  @override
  Future<int> sendMessage({
    required int rideRequestId,
    required int receiverId,
    required String content,
  }) async {
    sentMessages++;
    return 50;
  }

  @override
  Future<void> updateTripStatus(int tripId, String status) async {
    updatedTripStatuses++;
  }

  @override
  Future<void> submitRating({
    required int tripId,
    required int rateeId,
    required int score,
    String? comment,
  }) async {
    submittedRatings++;
  }
}

void main() {
  setUpAll(() async {
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://example.com/backend');
  });

  testWidgets('trips and notifications screens render API data after fetch', (tester) async {
    final fakeApiClient = FakeApiClient(
      trips: const [
        Trip(id: 7, distance: 4, duration: 360, fare: 80, date: '2024-01-01', status: 'completed'),
      ],
      notifications: const [
        {'id': 1, 'title': 'Trip update', 'body': 'Your driver arrived'},
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          user: const User(id: 1, username: 'rider', role: 'rider'),
          apiClient: fakeApiClient,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.textContaining('Trip #7'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(home: NotificationsScreen(apiClient: fakeApiClient)),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Trip update'), findsOneWidget);
    expect(find.text('Your driver arrived'), findsOneWidget);
  });

  testWidgets('full lifecycle flow calls API and updates UI handling', (tester) async {
    final fakeApiClient = FakeApiClient(
      offers: const [
        {'id': 8, 'driver_id': 3, 'proposed_fare': 75, 'status': 'pending'},
      ],
      messages: const [
        {'sender_id': 3, 'content': 'Can pick up in 5 min'},
      ],
      trips: const [
        Trip(id: 8, distance: 2, duration: 120, fare: 75, date: '2024-02-01', status: 'driver_arriving'),
      ],
    );

    await tester.pumpWidget(MaterialApp(home: RideRequestDetailsScreen(apiClient: fakeApiClient)));
    await tester.pumpAndSettle();

    expect(find.textContaining('Driver #3'), findsOneWidget);
    expect(find.textContaining('Can pick up in 5 min'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'Deal');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();
    expect(fakeApiClient.sentMessages, 1);

    await tester.tap(find.text('Create Offer'));
    await tester.pumpAndSettle();
    expect(fakeApiClient.createdOffers, 1);

    await tester.pumpWidget(MaterialApp(home: TripLiveScreen(apiClient: fakeApiClient)));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Trip ID'), '8');
    await tester.tap(find.text('Advance Status'));
    await tester.pumpAndSettle();
    expect(fakeApiClient.updatedTripStatuses, 1);

    await tester.pumpWidget(MaterialApp(home: RatingsScreen(apiClient: fakeApiClient)));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.star_border).first);
    await tester.tap(find.text('Submit Feedback'));
    await tester.pumpAndSettle();
    expect(fakeApiClient.submittedRatings, 1);
  });
}
