<?php

declare(strict_types=1);
require_once __DIR__ . '/utils.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(['error' => 'Method not allowed'], 405);
}
$user = requireAuth();
$input = readJsonBody();
$offerId = (int) ($input['offer_id'] ?? 0);
$status = (string) ($input['status'] ?? '');
if ($offerId <= 0 || !in_array($status, ['accepted', 'rejected', 'withdrawn'], true)) {
    sendJson(['error' => 'Invalid payload'], 400);
}
$stmt = getConnection()->prepare('UPDATE Offers SET status = :status WHERE id = :id');
$stmt->execute(['status' => $status, 'id' => $offerId]);
if ($stmt->rowCount() === 0) {
    sendJson(['error' => 'Offer not found'], 404);
}
writeAuditLog((int) $user['sub'], 'offer.update_status', 'Offers', $offerId, ['status' => $status]);
sendJson(['message' => 'Offer status updated']);
