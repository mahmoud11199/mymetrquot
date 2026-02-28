import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onAuthenticated});

  final ValueChanged<String> onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _registerMode = false;
  String _selectedRole = 'rider';
  int _onboardingPage = 0;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingCards = [
      _OnboardingCard(
        icon: Icons.map,
        title: 'Smart Fare Proposals',
        subtitle: 'Pick pickup/dropoff and negotiate transparently.',
      ),
      _OnboardingCard(
        icon: Icons.chat,
        title: 'Live Negotiation',
        subtitle: 'Chat in-app with drivers before accepting an offer.',
      ),
      _OnboardingCard(
        icon: Icons.notifications,
        title: 'Trip Notifications',
        subtitle: 'Stay updated with trip state changes and alerts.',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to mymetrquot',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'A fair and flexible ride experience for riders and drivers.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 170,
                child: PageView.builder(
                  itemCount: onboardingCards.length,
                  onPageChanged: (index) => setState(() => _onboardingPage = index),
                  itemBuilder: (_, index) => onboardingCards[index],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingCards.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _onboardingPage == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _onboardingPage == index
                          ? const Color(0xFF1976D2)
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Login')),
                  ButtonSegment(value: true, label: Text('Register')),
                ],
                selected: {_registerMode},
                onSelectionChanged: (selection) {
                  setState(() => _registerMode = selection.first);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              if (_registerMode)
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 12),
              Text('Select role', style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 10,
                children: ['rider', 'driver'].map((role) {
                  final selected = _selectedRole == role;
                  return ChoiceChip(
                    selected: selected,
                    label: Text(role),
                    onSelected: (_) => setState(() => _selectedRole = role),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              _PressableActionButton(
                label: _registerMode ? 'Create Account' : 'Continue',
                icon: _registerMode ? Icons.person_add : Icons.login,
                onPressed: () => widget.onAuthenticated(_selectedRole),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 34, color: const Color(0xFF1976D2)),
            const SizedBox(height: 10),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}

class _PressableActionButton extends StatefulWidget {
  const _PressableActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<_PressableActionButton> createState() => _PressableActionButtonState();
}

class _PressableActionButtonState extends State<_PressableActionButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapCancel: () => setState(() => _scale = 1),
      onTapUp: (_) {
        setState(() => _scale = 1);
        widget.onPressed();
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 110),
        scale: _scale,
        child: FilledButton.icon(
          onPressed: widget.onPressed,
          icon: Icon(widget.icon),
          label: Text(widget.label),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        ),
      ),
    );
  }
}
