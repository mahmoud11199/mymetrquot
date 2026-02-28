import 'package:flutter/material.dart';

class RideRequestDetailsScreen extends StatefulWidget {
  const RideRequestDetailsScreen({super.key});

  @override
  State<RideRequestDetailsScreen> createState() => _RideRequestDetailsScreenState();
}

class _RideRequestDetailsScreenState extends State<RideRequestDetailsScreen> {
  final _chatController = TextEditingController();
  final _chatListKey = GlobalKey<AnimatedListState>();
  final List<String> _messages = [
    'Driver: I can pick you up in 5 minutes.',
    'Rider: Can we settle at 65 EGP?',
  ];

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) {
      return;
    }
    final message = 'You: ${_chatController.text.trim()}';
    _messages.add(message);
    _chatListKey.currentState?.insertItem(_messages.length - 1);
    _chatController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride Request Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Driver Offers', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...List.generate(3, (index) {
              final fare = 60 + (index * 5);
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('Driver #${index + 1} - $fare EGP'),
                  subtitle: const Text('ETA 4-8 min'),
                  trailing: FilledButton(
                    onPressed: () {},
                    child: const Text('Accept'),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            Text('Negotiation Chat', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Expanded(
              child: AnimatedList(
                key: _chatListKey,
                initialItemCount: _messages.length,
                itemBuilder: (_, index, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.25, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(
                      opacity: animation,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(_messages[index]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: const InputDecoration(
                      hintText: 'Type a counter offer...',
                    ),
                  ),
                ),
                IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
