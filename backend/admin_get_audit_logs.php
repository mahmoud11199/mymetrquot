<?php

declare(strict_types=1);
require_once __DIR__ . '/utils.php';
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendJson(['error' => 'Method not allowed'], 405);
}
$user = requireAuth();
requireRole($user, ['admin']);
$stmt = getConnection()->query('SELECT * FROM AuditLogs ORDER BY id DESC LIMIT 500');
sendJson(['audit_logs' => $stmt->fetchAll()]);
