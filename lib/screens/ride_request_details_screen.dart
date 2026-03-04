import 'package:flutter/material.dart';

import '../services/api_client.dart';

class RideRequestDetailsScreen extends StatefulWidget {
  const RideRequestDetailsScreen({super.key, ApiClient? apiClient})
      : _apiClient = apiClient;

  final ApiClient? _apiClient;

  @override
  State<RideRequestDetailsScreen> createState() => _RideRequestDetailsScreenState();
}

class _RideRequestDetailsScreenState extends State<RideRequestDetailsScreen> {
  late final ApiClient _apiClient;
  final _rideRequestIdController = TextEditingController();
  final _receiverIdController = TextEditingController();
  final _fareController = TextEditingController(text: '80');
  final _riderIdController = TextEditingController();
  final _driverIdController = TextEditingController();
  final _chatController = TextEditingController();

  List<Map<String, dynamic>> _offers = const [];
  List<Map<String, dynamic>> _messages = const [];
  List<Map<String, dynamic>> _rideRequests = const [];

  @override
  void initState() {
    super.initState();
    _apiClient = widget._apiClient ?? ApiClient();
    _loadRideRequests();
  }

  @override
  void dispose() {
    _rideRequestIdController.dispose();
    _receiverIdController.dispose();
    _fareController.dispose();
    _riderIdController.dispose();
    _driverIdController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  int? get _rideRequestId => int.tryParse(_rideRequestIdController.text.trim());

  Future<void> _loadRideRequests() async {
    final rideRequests = await _apiClient.fetchRideRequests();
    if (!mounted) return;
    setState(() => _rideRequests = rideRequests);
  }

  Future<void> _loadOffers() async {
    if (_rideRequestId == null) return;
    final offers = await _apiClient.fetchOffers(_rideRequestId!);
    if (!mounted) return;
    setState(() => _offers = offers);
  }

  Future<void> _sendMessage() async {
    final receiverId = int.tryParse(_receiverIdController.text.trim());
    final content = _chatController.text.trim();
    if (_rideRequestId == null || receiverId == null || content.isEmpty) return;
    await _apiClient.sendMessage(
      rideRequestId: _rideRequestId!,
      receiverId: receiverId,
      content: content,
    );
    _chatController.clear();
    await _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (_rideRequestId == null) return;
    final messages = await _apiClient.fetchMessages(_rideRequestId!);
    if (!mounted) return;
    setState(() => _messages = messages);
  }

  Future<void> _createOffer() async {
    final fare = double.tryParse(_fareController.text.trim());
    if (_rideRequestId == null || fare == null) return;
    await _apiClient.createOffer({'ride_request_id': _rideRequestId, 'proposed_fare': fare});
    await _loadOffers();
  }

  Future<void> _acceptOffer(Map<String, dynamic> offer) async {
    final riderId = int.tryParse(_riderIdController.text.trim());
    final driverId = int.tryParse(_driverIdController.text.trim());
    if (riderId == null || driverId == null) return;
    await _apiClient.updateOfferStatus((offer['id'] as num).toInt(), 'accepted');
    await _apiClient.addTrip(
      riderId: riderId,
      driverId: driverId,
      fare: (offer['proposed_fare'] as num).toDouble(),
      rideRequestId: _rideRequestId,
      offerId: (offer['id'] as num).toInt(),
      status: 'driver_arriving',
    );
    await _loadOffers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride Request Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _rideRequestIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Ride Request ID'),
            ),
            TextField(
              controller: _receiverIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Receiver ID (for chat)'),
            ),
            TextField(
              controller: _riderIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Rider ID'),
            ),
            TextField(
              controller: _driverIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Driver ID'),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(onPressed: _loadRideRequests, child: const Text('Refresh Requests')),
                OutlinedButton(onPressed: _loadOffers, child: const Text('Refresh Offers')),
                OutlinedButton(onPressed: _loadMessages, child: const Text('Refresh Chat')),
              ],
            ),
            Text('Ride Requests', style: Theme.of(context).textTheme.titleLarge),
            ..._rideRequests.map((req) => ListTile(title: Text('Request #${req['id']}'))),
            const Divider(),
            Text('Driver Offers', style: Theme.of(context).textTheme.titleLarge),
            TextField(
              controller: _fareController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Proposed fare'),
            ),
            FilledButton(onPressed: _createOffer, child: const Text('Create Offer')),
            ..._offers.map(
              (offer) => Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('Offer #${offer['id']} - ${offer['proposed_fare']} EGP'),
                  subtitle: Text('Status: ${offer['status']}'),
                  trailing: FilledButton(
                    onPressed: () => _acceptOffer(offer),
                    child: const Text('Accept'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Negotiation Chat', style: Theme.of(context).textTheme.titleLarge),
            ..._messages.map(
              (message) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text((message['content'] ?? '').toString()),
                ),
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
