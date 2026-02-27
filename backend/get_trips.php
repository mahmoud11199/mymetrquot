<?php

declare(strict_types=1);

require_once __DIR__ . '/utils.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendJson(['error' => 'Method not allowed'], 405);
}

requireAuth();

$stmt = getConnection()->query('SELECT id, distance, duration, fare, date FROM trips ORDER BY id DESC');
$trips = $stmt->fetchAll();

sendJson(['trips' => $trips]);
