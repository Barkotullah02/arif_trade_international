<?php
// ============================================================
// Request – HTTP request wrapper
// ============================================================

class Request
{
    public string $method;
    public string $path;
    public ?array $user = null;
    private array $body    = [];
    private array $query   = [];
    private array $headers = [];

    public function __construct()
    {
        $this->method = strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET');

        // Normalise path: strip the directory prefix of this script (e.g. /arif_trade_international/restAPI)
        $scriptDir   = rtrim(dirname($_SERVER['SCRIPT_NAME'] ?? '/'), '/');
        $raw         = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH);
        if ($scriptDir && str_starts_with($raw, $scriptDir)) {
            $raw = substr($raw, strlen($scriptDir));
        }
        $this->path  = rtrim($raw ?: '/', '/') ?: '/';

        $this->query   = $_GET;
        $this->headers = getallheaders() ?: [];

        // Parse JSON body
        $ct = $this->header('Content-Type') ?? '';
        if (str_contains($ct, 'application/json')) {
            $raw        = file_get_contents('php://input');
            $this->body = json_decode($raw, true) ?? [];
        } else {
            $this->body = $_POST;
        }
    }

    /** Body param (POST/JSON) */
    public function input(string $key, mixed $default = null): mixed
    {
        return $this->body[$key] ?? $default;
    }

    /** All body params */
    public function all(): array
    {
        return $this->body;
    }

    /** Query string param */
    public function query(string $key, mixed $default = null): mixed
    {
        return $this->query[$key] ?? $default;
    }

    /** HTTP header (case-insensitive) */
    public function header(string $name): ?string
    {
        foreach ($this->headers as $k => $v) {
            if (strcasecmp($k, $name) === 0) return $v;
        }
        return null;
    }

    /** Bearer token from Authorization header */
    public function bearerToken(): ?string
    {
        $auth = $this->header('Authorization') ?? '';
        if (preg_match('/^Bearer\s+(.+)$/i', $auth, $m)) {
            return $m[1];
        }
        return null;
    }

    // Route segments set by Router after matching
    public array $params = [];
}
