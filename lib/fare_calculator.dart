class FareCalculator {
  const FareCalculator({
    this.baseFare = 10,
    this.perKilometerRate = 3,
    this.perMinuteRate = 0.5,
  });

  final double baseFare;
  final double perKilometerRate;
  final double perMinuteRate;

  double calculateFare({
    required Duration elapsed,
    required double distanceKm,
  }) {
    final minutes = elapsed.inSeconds / 60;
    final distanceCharge = distanceKm * perKilometerRate;
    final timeCharge = minutes * perMinuteRate;

    return baseFare + distanceCharge + timeCharge;
  }
}
