import 'package:flutter_test/flutter_test.dart';
import 'package:mymetrquot/fare_calculator.dart';

void main() {
  group('FareCalculator', () {
    const calculator = FareCalculator(
      baseFare: 10,
      perKilometerRate: 3,
      perMinuteRate: 0.5,
    );

    test('starts from base fare when no travel data is present', () {
      final fare = calculator.calculateFare(
        elapsed: Duration.zero,
        distanceKm: 0,
      );

      expect(fare, 10);
    });

    test('adds time and distance charges accurately', () {
      final fare = calculator.calculateFare(
        elapsed: const Duration(minutes: 10),
        distanceKm: 2.5,
      );

      expect(fare, 22.5);
    });

    test('supports partial minutes based on seconds', () {
      final fare = calculator.calculateFare(
        elapsed: const Duration(seconds: 90),
        distanceKm: 1,
      );

      expect(fare, 13.75);
    });
  });
}
