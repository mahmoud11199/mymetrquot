import 'package:flutter/material.dart';

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({super.key});

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  int _riderStars = 0;
  int _driverStars = 0;

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
            Text('Rate your driver', style: Theme.of(context).textTheme.titleLarge),
            _starRow(_riderStars, (v) => setState(() => _riderStars = v)),
            const SizedBox(height: 16),
            Text('Driver rates rider', style: Theme.of(context).textTheme.titleLarge),
            _starRow(_driverStars, (v) => setState(() => _driverStars = v)),
            const Spacer(),
            FilledButton(
              onPressed: () {},
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
