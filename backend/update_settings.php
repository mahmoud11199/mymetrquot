<?php

declare(strict_types=1);
require_once __DIR__ . '/utils.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') { sendJson(['error' => 'Method not allowed'], 405); }
$user = requireAuth();
requireRole($user, ['admin']);
$input = readJsonBody();
$key = trim((string)($input['key'] ?? ''));
$value = (string)($input['value'] ?? '');
if ($key === '') { sendJson(['error' => 'key is required'], 400); }
$stmt = getConnection()->prepare('INSERT INTO Settings (`key`, `value`) VALUES (:key, :value) ON DUPLICATE KEY UPDATE `value` = VALUES(`value`)');
$stmt->execute(['key' => $key, 'value' => $value]);
sendJson(['message' => 'Setting updated']);
