<?php
// ============================================================
// ATI REST API – Central Configuration
// ============================================================

define('ATI_ENV', getenv('ATI_ENV') ?: 'development'); // production | development

// ── Database ─────────────────────────────────────────────────
define('DB_HOST',    '127.0.0.1');
define('DB_PORT',    3306);
define('DB_NAME',    'ati_db');
define('DB_USER',    'ati_dev');
define('DB_PASS',    'atiRestApiDev');
define('DB_CHARSET', 'utf8mb4');

// ── JWT ───────────────────────────────────────────────────────
// Change JWT_SECRET before going to production (min 32 chars, high entropy)
define('JWT_SECRET',  getenv('JWT_SECRET') ?: 'ati_super_secret_key_change_in_production_32c');
define('JWT_ALGO',    'HS256');
define('JWT_EXPIRY',  60 * 60 * 8); // 8 hours in seconds

// ── App ───────────────────────────────────────────────────────
define('APP_NAME',    'ATI REST API');
define('APP_VERSION', '1.0.0');
define('TIMEZONE',    'Asia/Dhaka');
define('BASE_PATH',   __DIR__);   // /…/restAPI

date_default_timezone_set(TIMEZONE);

// ── Error reporting ───────────────────────────────────────────
if (ATI_ENV === 'production') {
    ini_set('display_errors', '0');
    error_reporting(0);
} else {
    ini_set('display_errors', '1');
    error_reporting(E_ALL);
}
