<?php

declare(strict_types=1);
require_once __DIR__ . '/utils.php';
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendJson(['error' => 'Method not allowed'], 405);
}
$user = requireAuth();
$role = (string) ($user['role'] ?? 'rider');
if ($role === 'driver' || $role === 'admin') {
    $stmt = getConnection()->query('SELECT * FROM RideRequests ORDER BY id DESC');
} else {
    $stmt = getConnection()->prepare('SELECT * FROM RideRequests WHERE rider_id = :rider_id ORDER BY id DESC');
    $stmt->execute(['rider_id' => (int) $user['sub']]);
}
sendJson(['ride_requests' => $stmt->fetchAll()]);
