import 'package:flutter/material.dart';

class TripLiveScreen extends StatefulWidget {
  const TripLiveScreen({super.key});

  @override
  State<TripLiveScreen> createState() => _TripLiveScreenState();
}

class _TripLiveScreenState extends State<TripLiveScreen> {
  final statuses = ['accepted', 'started', 'ended'];
  int _index = 0;

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
              onPressed: _index < statuses.length - 1
                  ? () => setState(() => _index++)
                  : null,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Advance Status'),
            ),
          ],
        ),
      ),
    );
  }
}
