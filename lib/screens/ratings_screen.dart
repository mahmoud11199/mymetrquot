import 'package:flutter/material.dart';

import '../services/api_client.dart';

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({super.key, this.apiClient});

  final ApiClient? apiClient;

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  final _tripIdController = TextEditingController(text: '1');
  final _rateeIdController = TextEditingController(text: '2');
  late final ApiClient _apiClient;
  int _riderStars = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClient ?? ApiClient();
  }

  @override
  void dispose() {
    _tripIdController.dispose();
    _rateeIdController.dispose();
    super.dispose();
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

  Future<void> _submit() async {
    final tripId = int.tryParse(_tripIdController.text.trim()) ?? 0;
    final rateeId = int.tryParse(_rateeIdController.text.trim()) ?? 0;
    if (tripId <= 0 || rateeId <= 0 || _riderStars <= 0) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _apiClient.submitRating(
        tripId: tripId,
        rateeId: rateeId,
        score: _riderStars,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted successfully.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
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
              decoration: const InputDecoration(labelText: 'Ratee user ID'),
            ),
            Text('Rate your driver', style: Theme.of(context).textTheme.titleLarge),
            _starRow(_riderStars, (v) => setState(() => _riderStars = v)),
            const Spacer(),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
