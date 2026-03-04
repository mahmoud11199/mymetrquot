import 'package:flutter_test/flutter_test.dart';
import 'package:mymetrquot/models/trip.dart';

void main() {
  group('Trip.fromJson', () {
    test('parses canonical backend keys', () {
      final trip = Trip.fromJson({
        'id': 1,
        'distance_km': 11.3,
        'duration_sec': 900,
        'fare': 45.5,
        'created_at': '2026-01-01 12:00:00',
        'status': 'accepted',
        'rider_id': 20,
        'driver_id': 30,
      });

      expect(trip.id, 1);
      expect(trip.distance, 11.3);
      expect(trip.duration, 900);
      expect(trip.fare, 45.5);
      expect(trip.date, '2026-01-01 12:00:00');
      expect(trip.status, 'accepted');
      expect(trip.riderId, 20);
      expect(trip.driverId, 30);
    });

    test('falls back to alternative keys and defaults', () {
      final trip = Trip.fromJson({
        'id': 2,
        'distance': 3,
        'duration': 120,
        'fare': 12,
        'date': '2026-02-02',
      });

      expect(trip.id, 2);
      expect(trip.distance, 3);
      expect(trip.duration, 120);
      expect(trip.fare, 12);
      expect(trip.date, '2026-02-02');
      expect(trip.status, isNull);
      expect(trip.riderId, isNull);
      expect(trip.driverId, isNull);
    });

    test('uses zero defaults when distance and duration are absent', () {
      final trip = Trip.fromJson({
        'id': 3,
        'fare': 10,
      });

      expect(trip.distance, 0);
      expect(trip.duration, 0);
      expect(trip.date, '');
    });
  });
}
