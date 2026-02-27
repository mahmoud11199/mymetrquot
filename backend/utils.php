<?php

declare(strict_types=1);

require_once __DIR__ . '/config.php';

function getConnection(): PDO
{
    static $pdo = null;

    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $dsn = sprintf('mysql:host=%s;dbname=%s;charset=utf8mb4', DB_HOST, DB_NAME);
    $pdo = new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);

    return $pdo;
}

function sendJson(array $payload, int $statusCode = 200): void
{
    http_response_code($statusCode);
    header('Content-Type: application/json; charset=utf-8');
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: DENY');
    echo json_encode($payload);
    exit;
}

function base64UrlEncode(string $input): string
{
    return rtrim(strtr(base64_encode($input), '+/', '-_'), '=');
}

function base64UrlDecode(string $input): string
{
    $remainder = strlen($input) % 4;
    if ($remainder > 0) {
        $input .= str_repeat('=', 4 - $remainder);
    }

    return base64_decode(strtr($input, '-_', '+/')) ?: '';
}

function createJwt(int $userId, string $username, string $role): string
{
    $header = ['alg' => 'HS256', 'typ' => 'JWT'];
    $payload = [
        'sub' => $userId,
        'username' => $username,
        'role' => $role,
        'iss' => JWT_ISSUER,
        'iat' => time(),
        'exp' => time() + JWT_EXPIRY_SECONDS,
    ];

    $encodedHeader = base64UrlEncode(json_encode($header));
    $encodedPayload = base64UrlEncode(json_encode($payload));
    $signature = hash_hmac('sha256', "$encodedHeader.$encodedPayload", JWT_SECRET, true);
    $encodedSignature = base64UrlEncode($signature);

    return "$encodedHeader.$encodedPayload.$encodedSignature";
}

function validateJwt(string $jwt): ?array
{
    $parts = explode('.', $jwt);
    if (count($parts) !== 3) {
        return null;
    }

    [$encodedHeader, $encodedPayload, $encodedSignature] = $parts;
    $expectedSignature = base64UrlEncode(
        hash_hmac('sha256', "$encodedHeader.$encodedPayload", JWT_SECRET, true)
    );

    if (!hash_equals($expectedSignature, $encodedSignature)) {
        return null;
    }

    $payloadJson = base64UrlDecode($encodedPayload);
    $payload = json_decode($payloadJson, true);

    if (!is_array($payload) || !isset($payload['iss'], $payload['exp'], $payload['sub'], $payload['role'])) {
        return null;
    }

    if ($payload['iss'] !== JWT_ISSUER || (int) $payload['exp'] < time()) {
        return null;
    }

    return $payload;
}

function getBearerToken(): ?string
{
    $header = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
    if ($header === '' && function_exists('getallheaders')) {
        $headers = getallheaders();
        $header = $headers['Authorization'] ?? $headers['authorization'] ?? '';
    }

    if (preg_match('/Bearer\s+(.*)$/i', $header, $matches) === 1) {
        return trim($matches[1]);
    }

    return null;
}

function requireAuth(): array
{
    $token = getBearerToken();
    if ($token === null) {
        sendJson(['error' => 'Missing authorization token'], 401);
    }

    $payload = validateJwt($token);
    if ($payload === null) {
        sendJson(['error' => 'Invalid or expired token'], 401);
    }

    return $payload;
}

function requireRole(array $user, array $roles): void
{
    if (!in_array($user['role'] ?? '', $roles, true)) {
        sendJson(['error' => 'Forbidden'], 403);
    }
}

function readJsonBody(): array
{
    $input = json_decode(file_get_contents('php://input') ?: '{}', true);
    return is_array($input) ? $input : [];
}

function createNotification(int $userId, string $title, string $body, string $type, array $meta = []): void
{
    $stmt = getConnection()->prepare(
        'INSERT INTO Notifications (user_id, title, body, type, metadata_json) VALUES (:user_id, :title, :body, :type, :metadata_json)'
    );

    $stmt->execute([
        'user_id' => $userId,
        'title' => $title,
        'body' => $body,
        'type' => $type,
        'metadata_json' => json_encode($meta),
    ]);
}

function writeAuditLog(?int $actorUserId, string $action, string $entityType, ?int $entityId = null, array $details = []): void
{
    $stmt = getConnection()->prepare(
        'INSERT INTO AuditLogs (actor_user_id, action, entity_type, entity_id, details_json, ip_address)
         VALUES (:actor_user_id, :action, :entity_type, :entity_id, :details_json, :ip_address)'
    );

    $stmt->execute([
        'actor_user_id' => $actorUserId,
        'action' => $action,
        'entity_type' => $entityType,
        'entity_id' => $entityId,
        'details_json' => json_encode($details),
        'ip_address' => $_SERVER['REMOTE_ADDR'] ?? null,
    ]);
}
