<?php

declare(strict_types=1);

require_once __DIR__ . '/utils.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJson(['error' => 'Method not allowed'], 405);
}

$input = readJsonBody();
$username = trim((string) ($input['username'] ?? ''));
$email = trim((string) ($input['email'] ?? ''));
$password = (string) ($input['password'] ?? '');
$role = (string) ($input['role'] ?? 'rider');

if ($username === '' || $email === '' || $password === '' || !in_array($role, ['rider', 'driver'], true)) {
    sendJson(['error' => 'Invalid registration payload'], 400);
}

$stmt = getConnection()->prepare(
    'INSERT INTO Users (username, email, password_hash, role) VALUES (:username, :email, :password_hash, :role)'
);
$stmt->execute([
    'username' => $username,
    'email' => $email,
    'password_hash' => password_hash($password, PASSWORD_BCRYPT),
    'role' => $role,
]);

$userId = (int) getConnection()->lastInsertId();
writeAuditLog($userId, 'register', 'Users', $userId);
sendJson(['message' => 'User registered', 'user_id' => $userId], 201);
