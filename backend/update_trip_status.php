<?php

declare(strict_types=1);
require_once __DIR__ . '/utils.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(['error' => 'Method not allowed'], 405);
}
$user = requireAuth();
$input = readJsonBody();
$tripId = (int) ($input['trip_id'] ?? 0);
$status = (string) ($input['status'] ?? '');
if ($tripId <= 0 || !in_array($status, ['driver_arriving', 'in_progress', 'completed', 'cancelled'], true)) {
    sendJson(['error' => 'Invalid payload'], 400);
}
$stmt = getConnection()->prepare(
    'UPDATE Trips SET status = :status, completed_at = CASE WHEN :status = "completed" THEN NOW() ELSE completed_at END WHERE id = :id'
);
$stmt->execute(['status' => $status, 'id' => $tripId]);
if ($stmt->rowCount() === 0) {
    sendJson(['error' => 'Trip not found'], 404);
}
writeAuditLog((int) $user['sub'], 'trip.update_status', 'Trips', $tripId, ['status' => $status]);
sendJson(['message' => 'Trip status updated']);
