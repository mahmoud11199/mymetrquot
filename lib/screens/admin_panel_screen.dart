import 'package:flutter/material.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = const [
      ('Active Riders', '124', Icons.people),
      ('Active Drivers', '53', Icons.drive_eta),
      ('Trips Today', '231', Icons.route),
      ('Open Disputes', '7', Icons.report_problem),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (_, index) {
        final tile = tiles[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(tile.$3, color: const Color(0xFF1976D2)),
                const Spacer(),
                Text(tile.$2, style: Theme.of(context).textTheme.headlineSmall),
                Text(tile.$1),
              ],
            ),
          ),
        );
      },
    );
  }
}
