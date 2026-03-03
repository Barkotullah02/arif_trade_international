<?php
// ============================================================
// Helpers – utility functions
// ============================================================

/**
 * Auto-generate a product code: ATI-YYYYMMDD-XXXXX
 * Ensures uniqueness by running a DB check loop.
 */
function generateProductCode(): string
{
    $prefix = 'ATI-' . date('Ymd') . '-';
    do {
        $code = $prefix . strtoupper(substr(bin2hex(random_bytes(3)), 0, 5));
        $exists = Database::fetchScalar(
            'SELECT COUNT(*) FROM products WHERE product_code = ?',
            [$code]
        );
    } while ($exists > 0);
    return $code;
}

/**
 * Paginate any query safely.
 * Returns ['data' => [...], 'pagination' => [...]]
 */
function paginate(string $sql, array $params, int $page, int $perPage): array
{
    $page    = max(1, (int)$page);
    $perPage = max(1, min(200, (int)$perPage));
    $offset  = ($page - 1) * $perPage;

    // Count total (wrap original query)
    $total = (int)Database::fetchScalar(
        "SELECT COUNT(*) FROM ({$sql}) AS _count_wrap",
        $params
    );

    $rows = Database::fetchAll("{$sql} LIMIT ? OFFSET ?", array_merge($params, [$perPage, $offset]));

    return [
        'data'       => $rows,
        'pagination' => [
            'page'       => $page,
            'per_page'   => $perPage,
            'total'      => $total,
            'last_page'  => max(1, (int)ceil($total / $perPage)),
        ],
    ];
}

/**
 * Cast an array of rows' numeric strings to proper PHP types.
 * Useful for ID fields, prices, quantities, booleans.
 */
function castRow(array $row, array $intFields = [], array $floatFields = [], array $boolFields = []): array
{
    foreach ($intFields   as $f) { if (isset($row[$f])) $row[$f] = (int)$row[$f]; }
    foreach ($floatFields as $f) { if (isset($row[$f])) $row[$f] = (float)$row[$f]; }
    foreach ($boolFields  as $f) { if (isset($row[$f])) $row[$f] = (bool)$row[$f]; }
    return $row;
}

/**
 * Shallow sanitise: trim strings in the input array.
 */
function sanitiseInput(array $data): array
{
    return array_map(fn($v) => is_string($v) ? trim($v) : $v, $data);
}
