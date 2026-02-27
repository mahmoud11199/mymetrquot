class Trip {
  const Trip({
    required this.id,
    required this.distance,
    required this.duration,
    required this.fare,
    required this.date,
    this.status,
    this.riderId,
    this.driverId,
  });

  final int id;
  final double distance;
  final int duration;
  final double fare;
  final String date;
  final String? status;
  final int? riderId;
  final int? driverId;

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: (json['id'] as num).toInt(),
      distance: ((json['distance_km'] ?? json['distance']) as num?)?.toDouble() ?? 0,
      duration: ((json['duration_sec'] ?? json['duration']) as num?)?.toInt() ?? 0,
      fare: (json['fare'] as num).toDouble(),
      date: (json['created_at'] ?? json['date'] ?? '').toString(),
      status: json['status'] as String?,
      riderId: (json['rider_id'] as num?)?.toInt(),
      driverId: (json['driver_id'] as num?)?.toInt(),
    );
  }
}
