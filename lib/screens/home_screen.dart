import 'dart:math';

import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import 'ratings_screen.dart';
import 'ride_request_details_screen.dart';
import 'trip_live_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.user, ApiClient? apiClient})
      : _apiClient = apiClient;

  final User user;
  final ApiClient? _apiClient;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _fareController = TextEditingController(text: '50');
  late final ApiClient _apiClient;
  late final AnimationController _markerController;
  bool _requestPlaced = false;
  bool _isSubmittingRideRequest = false;
  bool _isLoadingTrips = false;
  List<Trip> _trips = const [];

  @override
  void initState() {
    super.initState();
    _apiClient = widget._apiClient ?? ApiClient();
    _markerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoadingTrips = true);
    try {
      final trips = await _apiClient.fetchTrips();
      if (!mounted) return;
      setState(() => _trips = trips);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load trips.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingTrips = false);
      }
    }
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _fareController.dispose();
    _markerController.dispose();
    super.dispose();
  }

  void _openWithTransition(Widget screen) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, animation, __) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.15, 0),
            end: Offset.zero,
          ).animate(animation),
          child: screen,
        ),
      ),
    ));
  }

  Future<void> _createRideRequest() async {
    final pickup = _pickupController.text.trim();
    final dropoff = _dropoffController.text.trim();
    final fare = double.tryParse(_fareController.text.trim());

    if (pickup.isEmpty || dropoff.isEmpty || fare == null || fare <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide pickup, dropoff, and a valid fare.'),
        ),
      );
      return;
    }

    setState(() => _isSubmittingRideRequest = true);
    try {
      await _apiClient.createRideRequest({
        'pickup_lat': 30.0444,
        'pickup_lng': 31.2357,
        'dropoff_lat': 30.0131,
        'dropoff_lng': 31.2089,
        'pickup_address': pickup,
        'dropoff_address': dropoff,
        'estimated_fare': fare,
      });
      if (!mounted) return;
      setState(() => _requestPlaced = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ride request sent successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().contains('failed')
          ? 'Connection error while sending ride request.'
          : 'Invalid request data. Please review your entries.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$message ($e)')));
    } finally {
      if (mounted) {
        setState(() => _isSubmittingRideRequest = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Home Map', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: Card(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xFFBBDEFB),
                      alignment: Alignment.center,
                      child: const Icon(Icons.map, size: 80, color: Color(0xFF1976D2)),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _markerController,
                    builder: (_, __) {
                      final lift = sin(_markerController.value * pi) * 8;
                      return Stack(
                        children: [
                          Positioned(
                            top: 70 - lift,
                            left: 70,
                            child: const Icon(Icons.location_pin, color: Colors.green, size: 34),
                          ),
                          Positioned(
                            top: 130 - lift,
                            right: 80,
                            child: const Icon(Icons.location_pin, color: Colors.red, size: 34),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          TextField(
            controller: _pickupController,
            decoration: const InputDecoration(labelText: 'Pickup location'),
          ),
          TextField(
            controller: _dropoffController,
            decoration: const InputDecoration(labelText: 'Dropoff location'),
          ),
          TextField(
            controller: _fareController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Proposed fare (EGP)'),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _isSubmittingRideRequest ? null : _createRideRequest,
            icon: _isSubmittingRideRequest
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.local_taxi),
            label: const Text('Create Ride Request'),
          ),
          if (_requestPlaced)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Ride request created and sent to backend successfully.'),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Trips', style: Theme.of(context).textTheme.titleLarge),
              IconButton(onPressed: _loadTrips, icon: const Icon(Icons.refresh)),
            ],
          ),
          if (_isLoadingTrips)
            const Center(child: CircularProgressIndicator())
          else if (_trips.isEmpty)
            const Text('No trips available yet.')
          else
            ..._trips.map(
              (trip) => Card(
                child: ListTile(
                  title: Text('Trip #${trip.id} • ${trip.fare.toStringAsFixed(2)} EGP'),
                  subtitle: Text('Status: ${trip.status ?? 'unknown'}'),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _openWithTransition(const RideRequestDetailsScreen()),
                icon: const Icon(Icons.chat),
                label: const Text('Offers & Chat'),
              ),
              OutlinedButton.icon(
                onPressed: () => _openWithTransition(const TripLiveScreen()),
                icon: const Icon(Icons.route),
                label: const Text('Trip Live'),
              ),
              OutlinedButton.icon(
                onPressed: () => _openWithTransition(const RatingsScreen()),
                icon: const Icon(Icons.star),
                label: const Text('Ratings'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
