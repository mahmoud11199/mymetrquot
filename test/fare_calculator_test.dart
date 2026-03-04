import 'package:flutter_test/flutter_test.dart';
import 'package:mymetrquot/fare_calculator.dart';

void main() {
  group('FareCalculator', () {
    test('calculates fare from base + distance + elapsed minutes', () {
      const calculator = FareCalculator(
        baseFare: 8,
        perKilometerRate: 2.5,
        perMinuteRate: 1,
      );

      final fare = calculator.calculateFare(
        elapsed: const Duration(minutes: 10),
        distanceKm: 4,
      );

      expect(fare, 28);
    });

    test('supports fractional minutes when elapsed is in seconds', () {
      const calculator = FareCalculator(
        baseFare: 5,
        perKilometerRate: 3,
        perMinuteRate: 0.5,
      );

      final fare = calculator.calculateFare(
        elapsed: const Duration(seconds: 90),
        distanceKm: 2,
      );

      expect(fare, closeTo(11.75, 0.0001));
    });

    test('returns base fare when no time and no distance', () {
      const calculator = FareCalculator(baseFare: 12);

      final fare = calculator.calculateFare(
        elapsed: Duration.zero,
        distanceKm: 0,
      );

      expect(fare, 12);
    });
  });
}
