<?php

declare(strict_types=1);

$envPath = __DIR__ . '/.env';
$env = parse_ini_file($envPath);

if ($env === false) {
    throw new RuntimeException('Unable to load environment file: ' . $envPath);
}

function envValue(array $env, string $key, ?string $default = null): string
{
    if (array_key_exists($key, $env) && $env[$key] !== '') {
        return (string) $env[$key];
    }

    if ($default !== null) {
        return $default;
    }

    throw new RuntimeException('Missing required environment key: ' . $key);
}

define('DB_HOST', envValue($env, 'DB_HOST', '127.0.0.1'));
define('DB_NAME', envValue($env, 'DB_NAME'));
define('DB_USER', envValue($env, 'DB_USER'));
define('DB_PASS', envValue($env, 'DB_PASS', ''));

define('JWT_SECRET', envValue($env, 'JWT_SECRET'));
define('JWT_ISSUER', envValue($env, 'JWT_ISSUER', 'mymetrquot-api'));
define('JWT_EXPIRY_SECONDS', (int) envValue($env, 'JWT_EXPIRY_SECONDS', (string) (60 * 60 * 24)));

define('MAP_PROVIDER', envValue($env, 'MAP_PROVIDER', 'google_maps'));
