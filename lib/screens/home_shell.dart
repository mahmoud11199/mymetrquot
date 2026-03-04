import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/notification_service.dart';
import '../services/permission_service.dart';
import 'admin_panel_screen.dart';
import 'home_screen.dart';
import 'notifications_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.user,
    required this.onLogout,
  });

  final User user;
  final VoidCallback onLogout;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _permissionService = PermissionService();
  final _notificationService = NotificationService();
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _setupPermissions();
    _notificationService.initialize();
  }

  Future<void> _setupPermissions() async {
    final messages = await _permissionService.requestCorePermissions();
    if (!mounted || messages.isEmpty) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messages.join(' | '))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(user: widget.user),
      const NotificationsScreen(),
      const AdminPanelScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('mymetrquot'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1976D2)),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text('Profile & Settings', style: TextStyle(color: Colors.white)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text('${widget.user.username} (${widget.user.role})'),
            ),
            const ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: widget.onLogout,
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: KeyedSubtree(key: ValueKey(_currentTab), child: screens[_currentTab]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (index) => setState(() => _currentTab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.map), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.notifications), label: 'Alerts'),
          NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
        ],
      ),
    );
  }
}
