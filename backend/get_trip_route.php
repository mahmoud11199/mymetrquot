<?php

declare(strict_types=1);
require_once __DIR__ . '/utils.php';
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendJson(['error' => 'Method not allowed'], 405);
}
$user = requireAuth();
$tripId = (int) ($_GET['trip_id'] ?? 0);
if ($tripId <= 0) {
    sendJson(['error' => 'trip_id is required'], 400);
}
$stmt = getConnection()->prepare(
    'SELECT id, lat, lng, speed_kmh, heading, captured_at FROM Locations WHERE trip_id = :trip_id ORDER BY captured_at ASC'
);
$stmt->execute(['trip_id' => $tripId]);
$route = $stmt->fetchAll();
writeAuditLog((int) $user['sub'], 'trip.route.view', 'Locations', $tripId);
sendJson(['route' => $route, 'map_provider' => MAP_PROVIDER]);
