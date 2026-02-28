import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      'Offer received for your ride request.',
      'Trip started by driver Ahmed.',
      'Please rate your last trip.',
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (_, index) => Card(
        child: ListTile(
          leading: const Icon(Icons.notifications),
          title: Text(notifications[index]),
          subtitle: Text('Just now • #${index + 1}'),
        ),
      ),
    );
  }
}
