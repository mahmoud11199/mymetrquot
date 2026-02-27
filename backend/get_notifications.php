<?php

declare(strict_types=1);
require_once __DIR__ . '/utils.php';
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendJson(['error' => 'Method not allowed'], 405);
}
$user = requireAuth();
$stmt = getConnection()->prepare('SELECT * FROM Notifications WHERE user_id = :uid ORDER BY id DESC');
$stmt->execute(['uid' => (int) $user['sub']]);
sendJson(['notifications' => $stmt->fetchAll()]);
