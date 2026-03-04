import 'package:flutter/material.dart';

import '../services/api_client.dart';

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({super.key, ApiClient? apiClient}) : _apiClient = apiClient;

  final ApiClient? _apiClient;

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  late final ApiClient _apiClient;
  final _tripIdController = TextEditingController();
  final _rateeIdController = TextEditingController();
  int _riderStars = 0;
  int _driverStars = 0;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _apiClient = widget._apiClient ?? ApiClient();
  }

  @override
  void dispose() {
    _tripIdController.dispose();
    _rateeIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final tripId = int.tryParse(_tripIdController.text.trim());
    final rateeId = int.tryParse(_rateeIdController.text.trim());
    final score = _riderStars > 0 ? _riderStars : _driverStars;
    if (tripId == null || rateeId == null || score < 1) return;
    setState(() => _submitting = true);
    try {
      await _apiClient.submitRating(tripId: tripId, rateeId: rateeId, score: score);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted.')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Widget _starRow(int selected, ValueChanged<int> onSelect) {
    return Row(
      children: List.generate(5, (index) {
        final active = index < selected;
        return IconButton(
          onPressed: () => onSelect(index + 1),
          icon: AnimatedScale(
            duration: const Duration(milliseconds: 180),
            scale: active ? 1.2 : 1,
            child: Icon(
              active ? Icons.star : Icons.star_border,
              color: const Color(0xFFFFC107),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ratings')),
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
            TextField(
              controller: _rateeIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Ratee User ID'),
            ),
            Text('Rate your driver', style: Theme.of(context).textTheme.titleLarge),
            _starRow(_riderStars, (v) => setState(() => _riderStars = v)),
            const SizedBox(height: 16),
            Text('Driver rates rider', style: Theme.of(context).textTheme.titleLarge),
            _starRow(_driverStars, (v) => setState(() => _driverStars = v)),
            const Spacer(),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
