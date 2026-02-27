<?php

declare(strict_types=1);

require_once __DIR__ . '/utils.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(['error' => 'Method not allowed'], 405);
}

requireAuth();

$input = json_decode(file_get_contents('php://input') ?: '{}', true);
$id = (int) ($input['id'] ?? 0);
if ($id <= 0) {
    sendJson(['error' => 'Invalid trip id'], 400);
}

$stmt = getConnection()->prepare('DELETE FROM trips WHERE id = :id');
$stmt->execute(['id' => $id]);

if ($stmt->rowCount() === 0) {
    sendJson(['error' => 'Trip not found'], 404);
}

sendJson(['message' => 'Trip deleted successfully']);
