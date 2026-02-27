<?php

declare(strict_types=1);
require_once __DIR__ . '/utils.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') { sendJson(['error' => 'Method not allowed'], 405); }
$user = requireAuth();
$input = readJsonBody();
$stmt = getConnection()->prepare('INSERT INTO Disputes (trip_id, reported_by, reason) VALUES (:trip_id, :reported_by, :reason)');
$stmt->execute([
  'trip_id' => (int)($input['trip_id'] ?? 0),
  'reported_by' => (int)$user['sub'],
  'reason' => trim((string)($input['reason'] ?? '')),
]);
sendJson(['dispute_id' => (int)getConnection()->lastInsertId()], 201);
