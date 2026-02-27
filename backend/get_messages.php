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
$stmt = getConnection()->prepare(
    'SELECT * FROM Messages WHERE ride_request_id = :ride_request_id AND (sender_id = :uid OR receiver_id = :uid) ORDER BY id ASC'
);
$stmt->execute(['ride_request_id' => $rideRequestId, 'uid' => (int) $user['sub']]);
sendJson(['messages' => $stmt->fetchAll()]);
