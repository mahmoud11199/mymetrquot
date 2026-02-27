<?php

declare(strict_types=1);
require_once __DIR__ . '/utils.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(['error' => 'Method not allowed'], 405);
}
$user = requireAuth();
requireRole($user, ['driver', 'admin']);
$input = readJsonBody();
$rideRequestId = (int) ($input['ride_request_id'] ?? 0);
$fare = (float) ($input['proposed_fare'] ?? 0);
if ($rideRequestId <= 0 || $fare <= 0) {
    sendJson(['error' => 'Invalid offer payload'], 400);
}
$stmt = getConnection()->prepare(
    'INSERT INTO Offers (ride_request_id, driver_id, proposed_fare, message, status) VALUES (:ride_request_id, :driver_id, :proposed_fare, :message, :status)'
);
$stmt->execute([
    'ride_request_id' => $rideRequestId,
    'driver_id' => (int) $user['sub'],
    'proposed_fare' => $fare,
    'message' => $input['message'] ?? null,
    'status' => 'pending',
]);
$offerId = (int) getConnection()->lastInsertId();
getConnection()->prepare('UPDATE RideRequests SET status = :status WHERE id = :id')->execute(['status' => 'offered', 'id' => $rideRequestId]);
writeAuditLog((int) $user['sub'], 'offer.create', 'Offers', $offerId);
sendJson(['offer_id' => $offerId], 201);
