<?php

declare(strict_types=1);

require_once __DIR__ . '/utils.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendJson(['error' => 'Method not allowed'], 405);
}

$user = requireAuth();
$userId = (int) $user['sub'];
$role = (string) $user['role'];

if ($role === 'admin') {
    $stmt = getConnection()->query(
        'SELECT id, ride_request_id, rider_id, driver_id, offer_id, distance_km, duration_sec, fare, status, started_at, completed_at, created_at
         FROM Trips ORDER BY id DESC'
    );
} else {
    $stmt = getConnection()->prepare(
        'SELECT id, ride_request_id, rider_id, driver_id, offer_id, distance_km, duration_sec, fare, status, started_at, completed_at, created_at
         FROM Trips WHERE rider_id = :user_id OR driver_id = :user_id ORDER BY id DESC'
    );
    $stmt->execute(['user_id' => $userId]);
}

$trips = $stmt->fetchAll();
sendJson(['trips' => $trips]);
