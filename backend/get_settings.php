<?php

declare(strict_types=1);
require_once __DIR__ . '/utils.php';
if ($_SERVER['REQUEST_METHOD'] !== 'GET') { sendJson(['error' => 'Method not allowed'], 405); }
requireAuth();
$stmt = getConnection()->query('SELECT `key`, `value`, updated_at FROM Settings ORDER BY `key`');
sendJson(['settings' => $stmt->fetchAll()]);
