<?php

declare(strict_types=1);

require_once __DIR__ . '/utils.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(['error' => 'Method not allowed'], 405);
}

$user = requireAuth();

$input = json_decode(file_get_contents('php://input') ?: '{}', true);
$distance = (float) ($input['distance'] ?? 0);
$duration = (int) ($input['duration'] ?? 0);
$fare = (float) ($input['fare'] ?? 0);
$date = trim((string) ($input['date'] ?? ''));

if ($distance <= 0 || $duration <= 0 || $fare < 0 || $date === '') {
    sendJson(['error' => 'Invalid trip payload'], 400);
}

$stmt = getConnection()->prepare(
    'INSERT INTO trips (distance, duration, fare, date) VALUES (:distance, :duration, :fare, :date)'
);
$stmt->execute([
    'distance' => $distance,
    'duration' => $duration,
    'fare' => $fare,
    'date' => $date,
]);

sendJson([
    'message' => 'Trip added successfully',
    'trip_id' => (int) getConnection()->lastInsertId(),
    'user' => $user['username'] ?? null,
], 201);
