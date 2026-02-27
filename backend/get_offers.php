<?php

declare(strict_types=1);
require_once __DIR__ . '/utils.php';
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendJson(['error' => 'Method not allowed'], 405);
}
$user = requireAuth();
$rideRequestId = (int) ($_GET['ride_request_id'] ?? 0);
if ($rideRequestId <= 0) {
    sendJson(['error' => 'ride_request_id is required'], 400);
}
if (($user['role'] ?? '') === 'driver') {
    $stmt = getConnection()->prepare('SELECT * FROM Offers WHERE ride_request_id = :rrid AND driver_id = :driver_id ORDER BY id DESC');
    $stmt->execute(['rrid' => $rideRequestId, 'driver_id' => (int) $user['sub']]);
} else {
    $stmt = getConnection()->prepare('SELECT * FROM Offers WHERE ride_request_id = :rrid ORDER BY id DESC');
    $stmt->execute(['rrid' => $rideRequestId]);
}
sendJson(['offers' => $stmt->fetchAll()]);
