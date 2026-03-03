<?php
// ============================================================
// AuthController – login / me / refresh
// ============================================================

class AuthController
{
    /** POST /auth/login */
    public static function login(Request $req): void
    {
        $v = new Validator();
        $v->validateOrFail($req->all(), [
            'email'    => 'required|email',
            'password' => 'required|string',
        ]);

        $user = Database::fetchOne(
            'SELECT id, name, email, password_hash, role, is_active FROM users WHERE email = ?',
            [$req->input('email')]
        );

        if (!$user || !password_verify($req->input('password'), $user['password_hash'])) {
            Response::unauthorized('Invalid email or password');
        }

        if (!(bool)$user['is_active']) {
            Response::forbidden('Account is disabled');
        }

        $token = JWT::issue([
            'sub'   => $user['id'],
            'name'  => $user['name'],
            'email' => $user['email'],
            'role'  => $user['role'],
        ]);

        Response::success([
            'token'      => $token,
            'expires_in' => JWT_EXPIRY,
            'user'       => [
                'id'    => (int)$user['id'],
                'name'  => $user['name'],
                'email' => $user['email'],
                'role'  => $user['role'],
            ],
        ], 'Login successful');
    }

    /** GET /auth/me  (requires auth middleware) */
    public static function me(Request $req): void
    {
        $user = Database::fetchOne(
            'SELECT id, name, email, role, is_active, created_at FROM users WHERE id = ?',
            [$req->user['sub']]
        );
        if (!$user) Response::notFound('User not found');

        Response::success(castRow($user, ['id', 'is_active']));
    }

    /** POST /auth/refresh  (requires auth middleware – issues a fresh token) */
    public static function refresh(Request $req): void
    {
        $user = Database::fetchOne(
            'SELECT id, name, email, role, is_active FROM users WHERE id = ?',
            [$req->user['sub']]
        );
        if (!$user || !(bool)$user['is_active']) {
            Response::unauthorized('Cannot refresh – account inactive or missing');
        }

        $token = JWT::issue([
            'sub'   => $user['id'],
            'name'  => $user['name'],
            'email' => $user['email'],
            'role'  => $user['role'],
        ]);

        Response::success(['token' => $token, 'expires_in' => JWT_EXPIRY]);
    }
}
