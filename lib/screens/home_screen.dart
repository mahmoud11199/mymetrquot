import 'dart:math';

import 'package:flutter/material.dart';

import 'ratings_screen.dart';
import 'ride_request_details_screen.dart';
import 'trip_live_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.role});

  final String role;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _fareController = TextEditingController(text: '50');
  late final AnimationController _markerController;
  bool _requestPlaced = false;

  @override
  void initState() {
    super.initState();
    _markerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
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
            onPressed: () => setState(() => _requestPlaced = true),
            icon: const Icon(Icons.local_taxi),
            label: const Text('Create Ride Request'),
          ),
          if (_requestPlaced)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Ride request created with animated markers.'),
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
