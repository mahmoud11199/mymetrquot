<?php

declare(strict_types=1);
require_once __DIR__ . '/utils.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(['error' => 'Method not allowed'], 405);
}
$user = requireAuth();
$input = readJsonBody();
$rideRequestId = (int) ($input['ride_request_id'] ?? 0);
$receiverId = (int) ($input['receiver_id'] ?? 0);
$content = trim((string) ($input['content'] ?? ''));
if ($rideRequestId <= 0 || $receiverId <= 0 || $content === '') {
    sendJson(['error' => 'Invalid message payload'], 400);
}
$stmt = getConnection()->prepare(
    'INSERT INTO Messages (ride_request_id, sender_id, receiver_id, content) VALUES (:ride_request_id, :sender_id, :receiver_id, :content)'
);
$stmt->execute([
    'ride_request_id' => $rideRequestId,
    'sender_id' => (int) $user['sub'],
    'receiver_id' => $receiverId,
    'content' => $content,
]);
$messageId = (int) getConnection()->lastInsertId();
createNotification($receiverId, 'New message', $content, 'chat_message', ['ride_request_id' => $rideRequestId]);
writeAuditLog((int) $user['sub'], 'message.send', 'Messages', $messageId);
sendJson(['message_id' => $messageId], 201);
