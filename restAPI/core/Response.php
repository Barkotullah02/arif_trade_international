<?php
// ============================================================
// Response – JSON response helpers
// ============================================================

class Response
{
    public static function json($data, int $status = 200): void
    {
        http_response_code($status);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        exit;
    }

    public static function success($data = null, string $message = 'OK', int $status = 200): void
    {
        self::json([
            'success' => true,
            'message' => $message,
            'data'    => $data,
        ], $status);
    }

    public static function created($data = null, string $message = 'Created'): void
    {
        self::success($data, $message, 201);
    }

    public static function error(string $message, int $status = 400, $errors = null): void
    {
        $body = ['success' => false, 'message' => $message];
        if ($errors !== null) $body['errors'] = $errors;
        self::json($body, $status);
    }

    public static function unauthorized(string $message = 'Unauthorized'): void
    {
        self::error($message, 401);
    }

    public static function forbidden(string $message = 'Forbidden'): void
    {
        self::error($message, 403);
    }

    public static function notFound(string $message = 'Not found'): void
    {
        self::error($message, 404);
    }

    public static function unprocessable(array $errors, string $message = 'Validation failed'): void
    {
        self::error($message, 422, $errors);
    }

    public static function serverError(string $message = 'Internal server error'): void
    {
        self::error($message, 500);
    }

    /** 204 No Content */
    public static function noContent(): void
    {
        http_response_code(204);
        exit;
    }
}
