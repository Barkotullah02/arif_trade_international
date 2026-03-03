<?php
// ============================================================
// Router – lightweight path-based HTTP router
// ============================================================

class Router
{
    private array $routes = [];       // [method => [[pattern, handler, middleware[]], …]]

    // ── Route registration ───────────────────────────────────
    public function get(string $path, callable $handler, array $middleware = []): void
    {
        $this->add('GET', $path, $handler, $middleware);
    }

    public function post(string $path, callable $handler, array $middleware = []): void
    {
        $this->add('POST', $path, $handler, $middleware);
    }

    public function put(string $path, callable $handler, array $middleware = []): void
    {
        $this->add('PUT', $path, $handler, $middleware);
    }

    public function delete(string $path, callable $handler, array $middleware = []): void
    {
        $this->add('DELETE', $path, $handler, $middleware);
    }

    private function add(string $method, string $path, callable $handler, array $middleware): void
    {
        $this->routes[$method][] = [$this->toRegex($path), $handler, $middleware, $path];
    }

    // ── Dispatch ──────────────────────────────────────────────
    public function dispatch(Request $request): void
    {
        $method = $request->method;

        if (!isset($this->routes[$method])) {
            Response::error('Method not allowed', 405);
        }

        foreach ($this->routes[$method] as [$regex, $handler, $middleware]) {
            if (preg_match($regex, $request->path, $matches)) {
                // Extract named route params
                $request->params = array_filter(
                    $matches,
                    fn($k) => is_string($k),
                    ARRAY_FILTER_USE_KEY
                );

                // Run middleware chain then handler
                $this->runMiddleware($middleware, $request, $handler);
                return;
            }
        }

        Response::notFound("No route matched: {$method} {$request->path}");
    }

    // ── Middleware pipeline ────────────────────────────────────
    private function runMiddleware(array $stack, Request $request, callable $handler): void
    {
        if (empty($stack)) {
            $handler($request);
            return;
        }

        $mw   = array_shift($stack);
        $next = function () use ($stack, $request, $handler) {
            $this->runMiddleware($stack, $request, $handler);
        };

        $mw($request, $next);
    }

    // ── Pattern → regex ───────────────────────────────────────
    /** Convert /users/{id} into a named-group regex */
    private function toRegex(string $path): string
    {
        $pattern = preg_replace_callback(
            '/\{(\w+)\}/',
            fn($m) => '(?P<' . $m[1] . '>[^/]+)',
            $path
        );
        return '#^' . $pattern . '$#';
    }
}
