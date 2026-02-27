<?php

declare(strict_types=1);

require_once __DIR__ . '/utils.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(['error' => 'Method not allowed'], 405);
}

$user = requireAuth();
$input = readJsonBody();
$id = (int) ($input['id'] ?? 0);
if ($id <= 0) {
    sendJson(['error' => 'Invalid trip id'], 400);
}

if (($user['role'] ?? '') !== 'admin') {
    $stmt = getConnection()->prepare('DELETE FROM Trips WHERE id = :id AND (rider_id = :uid OR driver_id = :uid)');
    $stmt->execute(['id' => $id, 'uid' => (int) $user['sub']]);
} else {
    $stmt = getConnection()->prepare('DELETE FROM Trips WHERE id = :id');
    $stmt->execute(['id' => $id]);
}

if ($stmt->rowCount() === 0) {
    sendJson(['error' => 'Trip not found'], 404);
}

writeAuditLog((int) $user['sub'], 'trip.delete', 'Trips', $id);
sendJson(['message' => 'Trip deleted successfully']);
