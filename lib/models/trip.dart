class Trip {
  const Trip({
    required this.id,
    required this.distance,
    required this.duration,
    required this.fare,
    required this.date,
  });

  final int id;
  final double distance;
  final int duration;
  final double fare;
  final String date;

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: (json['id'] as num).toInt(),
      distance: (json['distance'] as num).toDouble(),
      duration: (json['duration'] as num).toInt(),
      fare: (json['fare'] as num).toDouble(),
      date: json['date'] as String,
    );
  }
}
