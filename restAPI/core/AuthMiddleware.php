<?php
// ============================================================
// AuthMiddleware – JWT verification + role enforcement
// ============================================================

class AuthMiddleware
{
    /**
     * Returns a closure that validates the JWT and injects
     * $request->user (payload array).
     */
    public static function auth(): Closure
    {
        return function (Request $request, callable $next): void {
            $token = $request->bearerToken();
            if (!$token) {
                Response::unauthorized('Missing Bearer token');
            }

            try {
                $payload       = JWT::decode($token);
                $request->user = $payload;          // attach to request
            } catch (RuntimeException $e) {
                Response::unauthorized($e->getMessage());
            }

            $next();
        };
    }

    /**
     * Returns a closure that allows only the given roles.
     * Must be placed AFTER auth() in the middleware stack.
     *
     * Usage: AuthMiddleware::role('superadmin', 'editor')
     */
    public static function role(string ...$allowedRoles): Closure
    {
        return function (Request $request, callable $next) use ($allowedRoles): void {
            $role = $request->user['role'] ?? '';
            if (!in_array($role, $allowedRoles, true)) {
                Response::forbidden("Role '$role' is not permitted for this action");
            }
            $next();
        };
    }
}
