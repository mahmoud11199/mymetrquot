import 'package:flutter/material.dart';

import '../services/api_client.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, this.apiClient});

  final ApiClient? apiClient;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final ApiClient _apiClient;
  bool _isLoading = false;
  List<Map<String, dynamic>> _notifications = const [];

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClient ?? ApiClient();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await _apiClient.fetchNotifications();
      if (!mounted) {
        return;
      }
      setState(() => _notifications = notifications);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _markRead(int id) async {
    await _apiClient.markNotificationRead(id);
    await _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (_, index) {
        final notification = _notifications[index];
        final id = (notification['id'] as num?)?.toInt() ?? 0;
        return Card(
          child: ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(notification['title']?.toString() ?? 'Notification'),
            subtitle: Text(notification['body']?.toString() ?? ''),
            trailing: IconButton(
              onPressed: id == 0 ? null : () => _markRead(id),
              icon: const Icon(Icons.done),
            ),
          ),
        );
      },
    );
  }
}
