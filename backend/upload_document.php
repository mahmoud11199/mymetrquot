<?php

declare(strict_types=1);
require_once __DIR__ . '/utils.php';
if ($_SERVER['REQUEST_METHOD'] !== 'POST') { sendJson(['error' => 'Method not allowed'], 405); }
$user = requireAuth();
$input = readJsonBody();
$stmt = getConnection()->prepare(
  'INSERT INTO Documents (user_id, document_type, file_url, verification_status) VALUES (:user_id, :document_type, :file_url, :verification_status)'
);
$stmt->execute([
  'user_id' => (int)$user['sub'],
  'document_type' => trim((string)($input['document_type'] ?? '')),
  'file_url' => trim((string)($input['file_url'] ?? '')),
  'verification_status' => 'pending',
]);
sendJson(['document_id' => (int)getConnection()->lastInsertId()], 201);
