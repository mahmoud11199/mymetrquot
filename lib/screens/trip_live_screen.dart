import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../services/api_client.dart';

class TripLiveScreen extends StatefulWidget {
  const TripLiveScreen({super.key, this.apiClient});

  final ApiClient? apiClient;

  @override
  State<TripLiveScreen> createState() => _TripLiveScreenState();
}

class _TripLiveScreenState extends State<TripLiveScreen> {
  final statuses = ['driver_arriving', 'in_progress', 'completed'];
  final _tripIdController = TextEditingController();
  late final ApiClient _apiClient;
  int _index = 0;
  bool _isSubmitting = false;
  bool _isLoadingTrips = false;
  List<Trip> _trips = const [];

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClient ?? ApiClient();
    _loadTrips();
  }

  @override
  void dispose() {
    _tripIdController.dispose();
    super.dispose();
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoadingTrips = true);
    try {
      final trips = await _apiClient.fetchTrips();
      if (!mounted) {
        return;
      }
      setState(() => _trips = trips);
    } finally {
      if (mounted) {
        setState(() => _isLoadingTrips = false);
      }
    }
  }

  Future<void> _advanceStatus() async {
    final tripId = int.tryParse(_tripIdController.text.trim());
    if (tripId == null || tripId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Trip ID.')),
      );
      return;
    }

    if (_index >= statuses.length - 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip already reached final status.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final nextIndex = _index + 1;
    try {
      await _apiClient.updateTripStatus(tripId, statuses[nextIndex]);
      if (!mounted) return;
      setState(() => _index = nextIndex);
      await _loadTrips();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trip status updated to ${statuses[nextIndex]}.')),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().contains('failed')
          ? 'Connection error while updating trip status.'
          : 'Invalid trip status request. Please verify trip id/state.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$message ($e)')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.orange, Colors.blue, Colors.green];
    final progress = (_index + 1) / statuses.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Live Status')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _tripIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Trip ID'),
            ),
            const SizedBox(height: 12),
            Text('Current Status', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors[_index].withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors[_index]),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_taxi, color: colors[_index]),
                  const SizedBox(width: 8),
                  Text(statuses[_index].toUpperCase()),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 500),
              builder: (_, value, __) => LinearProgressIndicator(value: value),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _advanceStatus,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: const Text('Advance Status'),
            ),
            const SizedBox(height: 20),
            Text('Trips from API', style: Theme.of(context).textTheme.titleLarge),
            if (_isLoadingTrips)
              const CircularProgressIndicator()
            else
              Expanded(
                child: ListView(
                  children: _trips
                      .map(
                        (trip) => ListTile(
                          title: Text('Trip #${trip.id}'),
                          subtitle: Text('Status: ${trip.status ?? 'unknown'}'),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
