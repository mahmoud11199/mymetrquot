<?php

declare(strict_types=1);

require_once __DIR__ . '/utils.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(['error' => 'Method not allowed'], 405);
}

$user = requireAuth();
$input = readJsonBody();

$driverId = (int) ($input['driver_id'] ?? 0);
$riderId = (int) ($input['rider_id'] ?? 0);
$fare = (float) ($input['fare'] ?? 0);
$distance = (float) ($input['distance_km'] ?? $input['distance'] ?? 0);
$duration = (int) ($input['duration_sec'] ?? $input['duration'] ?? 0);
$status = (string) ($input['status'] ?? 'created');

if ($driverId <= 0 || $riderId <= 0 || $fare < 0) {
    sendJson(['error' => 'Invalid trip payload'], 400);
}

$stmt = getConnection()->prepare(
    'INSERT INTO Trips (ride_request_id, rider_id, driver_id, offer_id, distance_km, duration_sec, fare, status, started_at)
     VALUES (:ride_request_id, :rider_id, :driver_id, :offer_id, :distance_km, :duration_sec, :fare, :status, :started_at)'
);
$stmt->execute([
    'ride_request_id' => $input['ride_request_id'] ?? null,
    'rider_id' => $riderId,
    'driver_id' => $driverId,
    'offer_id' => $input['offer_id'] ?? null,
    'distance_km' => $distance,
    'duration_sec' => $duration,
    'fare' => $fare,
    'status' => $status,
    'started_at' => $input['started_at'] ?? null,
]);

$tripId = (int) getConnection()->lastInsertId();
writeAuditLog((int) $user['sub'], 'trip.create', 'Trips', $tripId, ['status' => $status]);

sendJson([
    'message' => 'Trip added successfully',
    'trip_id' => $tripId,
], 201);
