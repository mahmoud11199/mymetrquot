<?php

declare(strict_types=1);

const DB_HOST = '127.0.0.1';
const DB_NAME = 'mymetrquot';
const DB_USER = 'root';
const DB_PASS = '';
const JWT_SECRET = 'replace_with_long_random_secret';
const JWT_ISSUER = 'mymetrquot-api';
const JWT_EXPIRY_SECONDS = 3600;

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
