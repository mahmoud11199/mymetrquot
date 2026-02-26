import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'fare_calculator.dart';

void main() {
  runApp(const TaxiMeterApp());
}

class TaxiMeterApp extends StatelessWidget {
  const TaxiMeterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Taxi Meter',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const TaxiMeterPage(),
    );
  }
}

class TaxiMeterPage extends StatefulWidget {
  const TaxiMeterPage({super.key});

  @override
  State<TaxiMeterPage> createState() => _TaxiMeterPageState();
}

class _TaxiMeterPageState extends State<TaxiMeterPage> {
  static const _fareCalculator = FareCalculator();

  Timer? _timer;
  StreamSubscription<Position>? _positionSubscription;

  Duration _elapsed = Duration.zero;
  double _distanceKm = 0;
  double _fare = _fareCalculator.baseFare;

  bool _isRunning = false;
  Position? _lastPosition;
  String _statusMessage = 'Press Start to begin trip.';

  @override
  void dispose() {
    _timer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startMeter() async {
    if (_isRunning) {
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _updateStatus('Location services are disabled.');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _updateStatus('Location permission is denied.');
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed += const Duration(seconds: 1);
        _recalculateFare();
      });
    });

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen((position) {
      if (_lastPosition != null) {
        final traveledMeters = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        setState(() {
          _distanceKm += traveledMeters / 1000;
          _lastPosition = position;
          _recalculateFare();
        });
      } else {
        _lastPosition = position;
      }
    });

    setState(() {
      _isRunning = true;
      _statusMessage = 'Trip running...';
    });
  }

  void _pauseMeter() {
    if (!_isRunning) {
      return;
    }

    _timer?.cancel();
    _timer = null;
    _positionSubscription?.cancel();
    _positionSubscription = null;

    setState(() {
      _isRunning = false;
      _statusMessage = 'Trip paused.';
    });
  }

  void _resetMeter() {
    _timer?.cancel();
    _positionSubscription?.cancel();

    setState(() {
      _timer = null;
      _positionSubscription = null;
      _elapsed = Duration.zero;
      _distanceKm = 0;
      _fare = _fareCalculator.baseFare;
      _isRunning = false;
      _lastPosition = null;
      _statusMessage = 'Press Start to begin trip.';
    });
  }

  void _recalculateFare() {
    _fare = _fareCalculator.calculateFare(
      elapsed: _elapsed,
      distanceKm: _distanceKm,
    );
  }

  void _updateStatus(String message) {
    setState(() {
      _statusMessage = message;
    });
  }

  String get _formattedTime {
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes.remainder(60);
    final seconds = _elapsed.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Taxi Meter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(
              '${_fare.toStringAsFixed(2)} EGP',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow(label: 'Elapsed Time', value: _formattedTime),
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: 'Distance',
                      value: '${_distanceKm.toStringAsFixed(2)} km',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _startMeter,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                ),
                ElevatedButton.icon(
                  onPressed: _pauseMeter,
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                ),
                OutlinedButton.icon(
                  onPressed: _resetMeter,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
