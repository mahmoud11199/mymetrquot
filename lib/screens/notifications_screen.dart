import 'package:flutter/material.dart';

import '../services/api_client.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, ApiClient? apiClient})
      : _apiClient = apiClient;

  final ApiClient? _apiClient;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final ApiClient _apiClient;
  bool _loading = true;
  List<Map<String, dynamic>> _notifications = const [];

  @override
  void initState() {
    super.initState();
    _apiClient = widget._apiClient ?? ApiClient();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _loading = true);
    try {
      final notifications = await _apiClient.fetchNotifications();
      if (!mounted) return;
      setState(() => _notifications = notifications);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _markRead(int id) async {
    await _apiClient.markNotificationRead(id);
    await _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (_, index) {
        final item = _notifications[index];
        final read = (item['is_read'] ?? 0).toString() == '1';
        return Card(
          child: ListTile(
            leading: Icon(read ? Icons.done : Icons.notifications),
            title: Text((item['message'] ?? '').toString()),
            subtitle: Text('ID #${item['id']}'),
            trailing: read
                ? null
                : TextButton(
                    onPressed: () => _markRead((item['id'] as num).toInt()),
                    child: const Text('Mark read'),
                  ),
          ),
        );
      },
    );
  }
}
