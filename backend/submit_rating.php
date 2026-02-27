<?php

declare(strict_types=1);
require_once __DIR__ . '/utils.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(['error' => 'Method not allowed'], 405);
}
$user = requireAuth();
$input = readJsonBody();
$tripId = (int) ($input['trip_id'] ?? 0);
$rateeId = (int) ($input['ratee_id'] ?? 0);
$score = (int) ($input['score'] ?? 0);
if ($tripId <= 0 || $rateeId <= 0 || $score < 1 || $score > 5) {
    sendJson(['error' => 'Invalid rating payload'], 400);
}
$stmt = getConnection()->prepare(
    'INSERT INTO Ratings (trip_id, rater_id, ratee_id, score, comment) VALUES (:trip_id, :rater_id, :ratee_id, :score, :comment)'
);
$stmt->execute([
    'trip_id' => $tripId,
    'rater_id' => (int) $user['sub'],
    'ratee_id' => $rateeId,
    'score' => $score,
    'comment' => $input['comment'] ?? null,
]);
$ratingId = (int) getConnection()->lastInsertId();
writeAuditLog((int) $user['sub'], 'rating.submit', 'Ratings', $ratingId);
sendJson(['rating_id' => $ratingId], 201);
