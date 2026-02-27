<?php

declare(strict_types=1);
require_once __DIR__ . '/utils.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(['error' => 'Method not allowed'], 405);
}
$user = requireAuth();
$input = readJsonBody();
$tripId = (int) ($input['trip_id'] ?? 0);
$lat = (float) ($input['lat'] ?? 0);
$lng = (float) ($input['lng'] ?? 0);
if ($tripId <= 0 || abs($lat) > 90 || abs($lng) > 180) {
    sendJson(['error' => 'Invalid location payload'], 400);
}
$stmt = getConnection()->prepare(
    'INSERT INTO Locations (trip_id, user_id, lat, lng, speed_kmh, heading, captured_at)
     VALUES (:trip_id, :user_id, :lat, :lng, :speed_kmh, :heading, :captured_at)'
);
$stmt->execute([
    'trip_id' => $tripId,
    'user_id' => (int) $user['sub'],
    'lat' => $lat,
    'lng' => $lng,
    'speed_kmh' => (float) ($input['speed_kmh'] ?? 0),
    'heading' => (float) ($input['heading'] ?? 0),
    'captured_at' => $input['captured_at'] ?? date('Y-m-d H:i:s'),
]);
sendJson(['message' => 'Location updated'], 201);
