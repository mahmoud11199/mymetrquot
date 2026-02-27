<?php

declare(strict_types=1);
require_once __DIR__ . '/utils.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(['error' => 'Method not allowed'], 405);
}
$user = requireAuth();
requireRole($user, ['rider', 'admin']);
$input = readJsonBody();
$stmt = getConnection()->prepare(
    'INSERT INTO RideRequests (rider_id, pickup_lat, pickup_lng, dropoff_lat, dropoff_lng, pickup_address, dropoff_address, estimated_fare, status)
     VALUES (:rider_id, :pickup_lat, :pickup_lng, :dropoff_lat, :dropoff_lng, :pickup_address, :dropoff_address, :estimated_fare, :status)'
);
$stmt->execute([
    'rider_id' => (int) $user['sub'],
    'pickup_lat' => (float) ($input['pickup_lat'] ?? 0),
    'pickup_lng' => (float) ($input['pickup_lng'] ?? 0),
    'dropoff_lat' => (float) ($input['dropoff_lat'] ?? 0),
    'dropoff_lng' => (float) ($input['dropoff_lng'] ?? 0),
    'pickup_address' => $input['pickup_address'] ?? null,
    'dropoff_address' => $input['dropoff_address'] ?? null,
    'estimated_fare' => $input['estimated_fare'] ?? null,
    'status' => 'pending',
]);
$rideRequestId = (int) getConnection()->lastInsertId();
writeAuditLog((int) $user['sub'], 'ride_request.create', 'RideRequests', $rideRequestId);
sendJson(['ride_request_id' => $rideRequestId], 201);
