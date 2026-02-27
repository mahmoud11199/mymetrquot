<?php

declare(strict_types=1);

require_once __DIR__ . '/config.php';

function sendJson(array $data, int $statusCode = 200): void
{
    http_response_code($statusCode);
    header('Content-Type: application/json');
    echo json_encode($data);
    exit;
}

function base64UrlEncode(string $data): string
{
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

function base64UrlDecode(string $data): string
{
    $remainder = strlen($data) % 4;
    if ($remainder !== 0) {
        $data .= str_repeat('=', 4 - $remainder);
    }

    return base64_decode(strtr($data, '-_', '+/')) ?: '';
}

function createJwt(int $userId, string $username): string
{
    $header = ['alg' => 'HS256', 'typ' => 'JWT'];
    $payload = [
        'iss' => JWT_ISSUER,
        'sub' => $userId,
        'username' => $username,
        'iat' => time(),
        'exp' => time() + JWT_EXPIRY_SECONDS,
    ];

    $encodedHeader = base64UrlEncode(json_encode($header, JSON_THROW_ON_ERROR));
    $encodedPayload = base64UrlEncode(json_encode($payload, JSON_THROW_ON_ERROR));
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

    if (!is_array($payload) || !isset($payload['iss'], $payload['exp'])) {
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
