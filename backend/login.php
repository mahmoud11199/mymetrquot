<?php

declare(strict_types=1);

require_once __DIR__ . '/utils.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(['error' => 'Method not allowed'], 405);
}

$input = readJsonBody();
$username = trim((string) ($input['username'] ?? ''));
$password = (string) ($input['password'] ?? '');

if ($username === '' || $password === '') {
    sendJson(['error' => 'Username and password are required'], 400);
}

$stmt = getConnection()->prepare(
    'SELECT id, username, role, password_hash FROM Users WHERE username = :username AND is_active = 1 LIMIT 1'
);
$stmt->execute(['username' => $username]);
$user = $stmt->fetch();

if (!$user || !password_verify($password, $user['password_hash'])) {
    sendJson(['error' => 'Invalid credentials'], 401);
}

$token = createJwt((int) $user['id'], (string) $user['username'], (string) $user['role']);
writeAuditLog((int) $user['id'], 'login', 'Users', (int) $user['id']);

sendJson([
    'token' => $token,
    'expires_in' => JWT_EXPIRY_SECONDS,
    'user' => [
        'id' => (int) $user['id'],
        'username' => $user['username'],
        'role' => $user['role'],
    ],
]);
