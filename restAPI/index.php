<?php
// ============================================================
// ATI REST API – Front Controller
// Entry point for every request routed by .htaccess
// ============================================================

declare(strict_types=1);

// ── Bootstrap ────────────────────────────────────────────────
require_once __DIR__ . '/config.php';

// Core library
require_once BASE_PATH . '/core/Database.php';
require_once BASE_PATH . '/core/JWT.php';
require_once BASE_PATH . '/core/Request.php';
require_once BASE_PATH . '/core/Response.php';
require_once BASE_PATH . '/core/Router.php';
require_once BASE_PATH . '/core/AuthMiddleware.php';
require_once BASE_PATH . '/core/Validator.php';
require_once BASE_PATH . '/core/Helpers.php';

// Module controllers (internal includes – no HTTP overhead)
require_once BASE_PATH . '/modules/auth/AuthController.php';
require_once BASE_PATH . '/modules/users/UserController.php';
require_once BASE_PATH . '/modules/categories/CategoryController.php';
require_once BASE_PATH . '/modules/products/ProductController.php';
require_once BASE_PATH . '/modules/variants/VariantController.php';
require_once BASE_PATH . '/modules/units/UnitController.php';
require_once BASE_PATH . '/modules/variantunits/VariantUnitController.php';
require_once BASE_PATH . '/modules/customers/CustomerController.php';
require_once BASE_PATH . '/modules/quotations/QuotationService.php';
require_once BASE_PATH . '/modules/quotations/QuotationController.php';
require_once BASE_PATH . '/modules/invoices/InvoiceController.php';
require_once BASE_PATH . '/modules/payments/PaymentController.php';
require_once BASE_PATH . '/modules/inventory/InventoryController.php';
require_once BASE_PATH . '/modules/docs/DocsController.php';

// ── Global error handler ─────────────────────────────────────
set_exception_handler(function (Throwable $e) {
    $status = (is_int($e->getCode()) && $e->getCode() >= 400 && $e->getCode() < 600)
        ? $e->getCode() : 500;
    $body = ['success' => false, 'message' => $e->getMessage()];
    if (ATI_ENV !== 'production') {
        $body['trace'] = $e->getTraceAsString();
    }
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($body);
    exit;
});

// ── Build request + router ────────────────────────────────────
$request = new Request();
$router  = new Router();

// Middleware shortcuts
$auth      = [AuthMiddleware::auth()];
$admin     = [AuthMiddleware::auth(), AuthMiddleware::role('superadmin')];
$editorUp  = [AuthMiddleware::auth(), AuthMiddleware::role('superadmin', 'editor')];
$viewerUp  = [AuthMiddleware::auth(), AuthMiddleware::role('superadmin', 'editor', 'viewer')];
$allRoles  = [AuthMiddleware::auth(), AuthMiddleware::role('superadmin', 'editor', 'viewer', 'salesman')];

// ── Routes ───────────────────────────────────────────────────

// Health check (public)
$router->get('/health', fn($req) => Response::success(['status' => 'ok', 'version' => APP_VERSION]));

// API Spec (public) – /spec avoids collision with the docs/ HTML directory
$router->get('/spec', [DocsController::class, 'spec']);

// ── Auth ─────────────────────────────────────────────────────
$router->post('/auth/login',   [AuthController::class, 'login']);
$router->get('/auth/me',       [AuthController::class, 'me'],       $auth);
$router->post('/auth/refresh', [AuthController::class, 'refresh'],  $auth);

// ── Users (superadmin only) ───────────────────────────────────
$router->get('/users',          [UserController::class, 'index'],   $admin);
$router->post('/users',         [UserController::class, 'store'],   $admin);
$router->get('/users/{id}',     [UserController::class, 'show'],    $admin);
$router->put('/users/{id}',     [UserController::class, 'update'],  $admin);
$router->delete('/users/{id}',  [UserController::class, 'destroy'], $admin);

// ── Categories ────────────────────────────────────────────────
$router->get('/categories',         [CategoryController::class, 'index'],   $allRoles);
$router->post('/categories',        [CategoryController::class, 'store'],   $admin);
$router->get('/categories/{id}',    [CategoryController::class, 'show'],    $allRoles);
$router->put('/categories/{id}',    [CategoryController::class, 'update'],  $admin);
$router->delete('/categories/{id}', [CategoryController::class, 'destroy'], $admin);

// ── Products ──────────────────────────────────────────────────
$router->get('/products',          [ProductController::class, 'index'],   $allRoles);
$router->post('/products',         [ProductController::class, 'store'],   $editorUp);
$router->get('/products/{id}',     [ProductController::class, 'show'],    $allRoles);
$router->put('/products/{id}',     [ProductController::class, 'update'],  $editorUp);
$router->delete('/products/{id}',  [ProductController::class, 'destroy'], $admin);

// ── Product Variants ──────────────────────────────────────────
$router->get('/products/{productId}/variants',  [VariantController::class, 'index'],   $allRoles);
$router->post('/products/{productId}/variants', [VariantController::class, 'store'],   $editorUp);
$router->get('/variants/{id}',                  [VariantController::class, 'show'],    $allRoles);
$router->put('/variants/{id}',                  [VariantController::class, 'update'],  $editorUp);
$router->delete('/variants/{id}',               [VariantController::class, 'destroy'], $admin);

// ── Units ─────────────────────────────────────────────────────
$router->get('/units',         [UnitController::class, 'index'],   $allRoles);
$router->post('/units',        [UnitController::class, 'store'],   $admin);
$router->get('/units/{id}',    [UnitController::class, 'show'],    $allRoles);
$router->put('/units/{id}',    [UnitController::class, 'update'],  $admin);
$router->delete('/units/{id}', [UnitController::class, 'destroy'], $admin);

// ── Variant-Units (stock + pricing per variant/unit combo) ────
$router->get('/variants/{variantId}/units',     [VariantUnitController::class, 'index'],   $allRoles);
$router->post('/variants/{variantId}/units',    [VariantUnitController::class, 'store'],   $editorUp);
$router->get('/variant-units/{id}',             [VariantUnitController::class, 'show'],    $allRoles);
$router->put('/variant-units/{id}',             [VariantUnitController::class, 'update'],  $editorUp);
$router->delete('/variant-units/{id}',          [VariantUnitController::class, 'destroy'], $admin);

// ── Customers (admin manages; editors/viewers read) ───────────
$router->get('/customers',          [CustomerController::class, 'index'],   $editorUp);
$router->post('/customers',         [CustomerController::class, 'store'],   $admin);
$router->get('/customers/{id}',     [CustomerController::class, 'show'],    $editorUp);
$router->put('/customers/{id}',     [CustomerController::class, 'update'],  $admin);
$router->delete('/customers/{id}',  [CustomerController::class, 'destroy'], $admin);

// ── Quotation Requests ────────────────────────────────────────
// salesman: can create + list own; editor+: can list all + update status
$router->get('/quotations',              [QuotationController::class, 'index'],  $allRoles);
$router->post('/quotations',             [QuotationController::class, 'store'],
    [AuthMiddleware::auth(), AuthMiddleware::role('superadmin', 'editor', 'salesman')]);
$router->get('/quotations/{id}',         [QuotationController::class, 'show'],   $allRoles);
$router->put('/quotations/{id}/status',  [QuotationController::class, 'updateStatus'], $editorUp);

// ── Invoices ──────────────────────────────────────────────────
$router->get('/invoices',          [InvoiceController::class, 'index'],  $editorUp);
$router->get('/invoices/{id}',     [InvoiceController::class, 'show'],   $editorUp);

// ── Payments ─────────────────────────────────────────────────
$router->get('/invoices/{invoiceId}/payments',  [PaymentController::class, 'index'],  $editorUp);
$router->post('/invoices/{invoiceId}/payments', [PaymentController::class, 'store'],  $editorUp);
$router->get('/payments/{id}',                  [PaymentController::class, 'show'],   $editorUp);
$router->delete('/payments/{id}',               [PaymentController::class, 'destroy'], $admin);

// ── Inventory Log ─────────────────────────────────────────────
$router->get('/inventory/log', [InventoryController::class, 'log'], $viewerUp);

// ── Dispatch ──────────────────────────────────────────────────
$router->dispatch($request);
