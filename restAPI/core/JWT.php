<?php
// ============================================================
// JWT – Pure-PHP HS256 JSON Web Token helper
// ============================================================

class JWT
{
    // ── Issue ────────────────────────────────────────────────
    public static function issue(array $payload): string
    {
        $header  = self::b64url(json_encode(['typ' => 'JWT', 'alg' => JWT_ALGO]));
        $now     = time();
        $payload = array_merge($payload, [
            'iat' => $now,
            'exp' => $now + JWT_EXPIRY,
        ]);
        $claims  = self::b64url(json_encode($payload));
        $sig     = self::sign("$header.$claims");
        return "$header.$claims.$sig";
    }

    // ── Verify & decode ──────────────────────────────────────
    /**
     * @throws RuntimeException on invalid/expired token
     */
    public static function decode(string $token): array
    {
        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            throw new RuntimeException('Malformed token', 401);
        }

        [$headerB64, $claimsB64, $sigB64] = $parts;

        // Verify signature
        $expected = self::sign("$headerB64.$claimsB64");
        if (!hash_equals($expected, $sigB64)) {
            throw new RuntimeException('Invalid token signature', 401);
        }

        $payload = json_decode(self::b64urlDecode($claimsB64), true);
        if (!is_array($payload)) {
            throw new RuntimeException('Invalid token payload', 401);
        }

        // Expiry check
        if (isset($payload['exp']) && $payload['exp'] < time()) {
            throw new RuntimeException('Token expired', 401);
        }

        return $payload;
    }

    // ── Internal ─────────────────────────────────────────────
    private static function sign(string $data): string
    {
        return self::b64url(
            hash_hmac('sha256', $data, JWT_SECRET, true)
        );
    }

    private static function b64url(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    private static function b64urlDecode(string $data): string
    {
        return base64_decode(strtr($data, '-_', '+/') . str_repeat('=', (4 - strlen($data) % 4) % 4));
    }
}
