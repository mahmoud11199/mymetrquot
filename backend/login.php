<?php

declare(strict_types=1);

require_once __DIR__ . '/utils.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(['error' => 'Method not allowed'], 405);
}

$input = json_decode(file_get_contents('php://input') ?: '{}', true);
$username = trim((string) ($input['username'] ?? ''));
$password = (string) ($input['password'] ?? '');

if ($username === '' || $password === '') {
    sendJson(['error' => 'Username and password are required'], 400);
}

$stmt = getConnection()->prepare('SELECT id, username, password_hash FROM users WHERE username = :username LIMIT 1');
$stmt->execute(['username' => $username]);
$user = $stmt->fetch();

if (!$user || !password_verify($password, $user['password_hash'])) {
    sendJson(['error' => 'Invalid credentials'], 401);
}

$token = createJwt((int) $user['id'], (string) $user['username']);

sendJson([
    'token' => $token,
    'expires_in' => JWT_EXPIRY_SECONDS,
]);
