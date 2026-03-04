import 'package:flutter/material.dart';

import '../services/api_client.dart';

class RideRequestDetailsScreen extends StatefulWidget {
  const RideRequestDetailsScreen({super.key, this.apiClient});

  final ApiClient? apiClient;

  @override
  State<RideRequestDetailsScreen> createState() => _RideRequestDetailsScreenState();
}

class _RideRequestDetailsScreenState extends State<RideRequestDetailsScreen> {
  final _chatController = TextEditingController();
  final _rideRequestIdController = TextEditingController(text: '1');
  final _receiverIdController = TextEditingController(text: '2');
  final _fareController = TextEditingController(text: '70');
  late final ApiClient _apiClient;

  bool _loading = false;
  List<Map<String, dynamic>> _offers = const [];
  List<Map<String, dynamic>> _messages = const [];

  @override
  void initState() {
    super.initState();
    _apiClient = widget.apiClient ?? ApiClient();
    _loadData();
  }

  @override
  void dispose() {
    _chatController.dispose();
    _rideRequestIdController.dispose();
    _receiverIdController.dispose();
    _fareController.dispose();
    super.dispose();
  }

  int get _rideRequestId => int.tryParse(_rideRequestIdController.text.trim()) ?? 0;

  Future<void> _loadData() async {
    if (_rideRequestId <= 0) {
      return;
    }
    setState(() => _loading = true);
    try {
      final offers = await _apiClient.fetchOffers(_rideRequestId);
      final messages = await _apiClient.fetchMessages(_rideRequestId);
      if (!mounted) {
        return;
      }
      setState(() {
        _offers = offers;
        _messages = messages;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load offers/chat for this request.')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _sendMessage() async {
    final message = _chatController.text.trim();
    final receiverId = int.tryParse(_receiverIdController.text.trim()) ?? 0;
    if (message.isEmpty || receiverId <= 0 || _rideRequestId <= 0) {
      return;
    }

    await _apiClient.sendMessage(
      rideRequestId: _rideRequestId,
      receiverId: receiverId,
      content: message,
    );
    _chatController.clear();
    await _loadData();
  }

  Future<void> _createOffer() async {
    final fare = double.tryParse(_fareController.text.trim()) ?? 0;
    if (_rideRequestId <= 0 || fare <= 0) {
      return;
    }

    await _apiClient.createOffer({
      'ride_request_id': _rideRequestId,
      'proposed_fare': fare,
      'message': 'Offer from UI',
    });
    await _loadData();
  }

  Future<void> _acceptOffer(int offerId) async {
    await _apiClient.updateOfferStatus(offerId, 'accepted');
    await _apiClient.addTrip(
      riderId: 1,
      driverId: 2,
      fare: double.tryParse(_fareController.text.trim()) ?? 50,
      rideRequestId: _rideRequestId,
      offerId: offerId,
      status: 'driver_arriving',
    );
    await _loadData();
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
            TextField(
              controller: _rideRequestIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Ride Request ID'),
              onSubmitted: (_) => _loadData(),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fareController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Offer fare'),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _createOffer, child: const Text('Create Offer')),
              ],
            ),
            const SizedBox(height: 8),
            Text('Driver Offers', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (_loading)
              const LinearProgressIndicator()
            else if (_offers.isEmpty)
              const Text('No offers found.')
            else
              ..._offers.map(
                (offer) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text('Driver #${offer['driver_id']} - ${offer['proposed_fare']} EGP'),
                    subtitle: Text('Status: ${offer['status'] ?? 'pending'}'),
                    trailing: FilledButton(
                      onPressed: () => _acceptOffer((offer['id'] as num).toInt()),
                      child: const Text('Accept'),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text('Negotiation Chat', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Expanded(
              child: _messages.isEmpty
                  ? const Center(child: Text('No messages yet.'))
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (_, index) {
                        final message = _messages[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'User ${message['sender_id']}: ${message['content']}',
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
                    controller: _receiverIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Receiver ID'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _chatController,
                    decoration: const InputDecoration(hintText: 'Type a counter offer...'),
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
