<?php

declare(strict_types=1);
require_once __DIR__ . '/utils.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(['error' => 'Method not allowed'], 405);
}
$user = requireAuth();
$input = readJsonBody();
$id = (int) ($input['id'] ?? 0);
$stmt = getConnection()->prepare('UPDATE Notifications SET is_read = 1 WHERE id = :id AND user_id = :uid');
$stmt->execute(['id' => $id, 'uid' => (int) $user['sub']]);
if ($stmt->rowCount() === 0) {
    sendJson(['error' => 'Notification not found'], 404);
}
sendJson(['message' => 'Notification marked as read']);
