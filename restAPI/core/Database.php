<?php
// ============================================================
// Database – PDO singleton factory
// ============================================================

class Database
{
    private static ?PDO $instance = null;

    public static function connect(): PDO
    {
        if (self::$instance === null) {
            $dsn = sprintf(
                'mysql:host=%s;port=%d;dbname=%s;charset=%s',
                DB_HOST, DB_PORT, DB_NAME, DB_CHARSET
            );
            $options = [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
                PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci",
            ];
            self::$instance = new PDO($dsn, DB_USER, DB_PASS, $options);
        }
        return self::$instance;
    }

    // ── Transaction helpers ───────────────────────────────────
    public static function beginTransaction(): void
    {
        self::connect()->beginTransaction();
    }

    public static function commit(): void
    {
        self::connect()->commit();
    }

    public static function rollback(): void
    {
        if (self::connect()->inTransaction()) {
            self::connect()->rollBack();
        }
    }

    // ── Query shortcuts ─────────────────────────────────────────
    /** Execute a prepared statement and return the PDOStatement */
    public static function query(string $sql, array $params = []): PDOStatement
    {
        $stmt = self::connect()->prepare($sql);
        $stmt->execute($params);
        return $stmt;
    }

    /** Fetch all rows */
    public static function fetchAll(string $sql, array $params = []): array
    {
        return self::query($sql, $params)->fetchAll();
    }

    /** Fetch a single row */
    public static function fetchOne(string $sql, array $params = []): ?array
    {
        $row = self::query($sql, $params)->fetch();
        return $row ?: null;
    }

    /** Fetch a single scalar value */
    public static function fetchScalar(string $sql, array $params = [])
    {
        return self::query($sql, $params)->fetchColumn();
    }

    /** Return last insert ID */
    public static function lastInsertId(): string
    {
        return self::connect()->lastInsertId();
    }
}
