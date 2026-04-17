<?php
// ============================================================
// LotController – product-level lots with lot stock balances
// ============================================================

class LotController
{
    /** GET /lots */
    public static function index(Request $req): void
    {
        $filters = sanitiseInput([
            'product_id' => $req->query('product_id'),
            'search'     => $req->query('search'),
            'is_active'  => $req->query('is_active'),
            'page'       => $req->query('page', 1),
            'per_page'   => $req->query('per_page', 20),
        ]);

        (new Validator())->validateOrFail($filters, [
            'product_id' => 'nullable|integer',
            'search'     => 'nullable|string|max:120',
            'is_active'  => 'nullable|boolean',
            'page'       => 'nullable|integer|min:1',
            'per_page'   => 'nullable|integer|min:1|max:200',
        ]);

        $where = ['1=1'];
        $params = [];

        if ($filters['product_id'] !== null && $filters['product_id'] !== '') {
            $where[] = 'l.product_id = ?';
            $params[] = (int)$filters['product_id'];
        }
        if (!empty($filters['search'])) {
            $where[] = 'l.name LIKE ?';
            $params[] = '%' . $filters['search'] . '%';
        }
        if ($filters['is_active'] !== null && $filters['is_active'] !== '') {
            $where[] = 'l.is_active = ?';
            $params[] = (int)(bool)$filters['is_active'];
        }

        $w = implode(' AND ', $where);
        $sql = "SELECT l.id, l.product_id, p.name AS product_name,
                  l.name, l.description, l.expiry_date, l.is_active, l.created_at, l.updated_at,
                  (l.expiry_date IS NOT NULL AND l.expiry_date < CURDATE()) AS is_expired,
                  (l.expiry_date IS NOT NULL AND l.expiry_date >= CURDATE() AND l.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 3 MONTH)) AS is_expiring_soon,
                       COALESCE(SUM(ls.quantity_total), 0) AS quantity_total,
                       COALESCE(SUM(ls.quantity_sold), 0) AS quantity_sold,
                       COALESCE(SUM(ls.quantity_total - ls.quantity_sold), 0) AS quantity_left
                FROM lots l
                JOIN products p ON p.id = l.product_id
                LEFT JOIN lot_stocks ls ON ls.lot_id = l.id
                WHERE $w
              GROUP BY l.id, l.product_id, p.name, l.name, l.description, l.expiry_date, l.is_active, l.created_at, l.updated_at
                ORDER BY l.id DESC";

        $result = paginate($sql, $params, (int)$filters['page'], (int)$filters['per_page']);
        $result['data'] = array_map(
            fn($r) => castRow($r, ['id', 'product_id'], ['quantity_total', 'quantity_sold', 'quantity_left'], ['is_active', 'is_expired', 'is_expiring_soon']),
            $result['data']
        );

        Response::success($result);
    }

    /** GET /lots/autocomplete?product_id=1&variant_unit_id=2&search=LO */
    public static function autocomplete(Request $req): void
    {
        $filters = sanitiseInput([
            'product_id'      => $req->query('product_id'),
            'variant_unit_id' => $req->query('variant_unit_id'),
            'search'          => $req->query('search', ''),
            'limit'           => $req->query('limit', 20),
        ]);

        (new Validator())->validateOrFail($filters, [
            'product_id'      => 'required|integer',
            'variant_unit_id' => 'required|integer',
            'search'          => 'nullable|string|max:120',
            'limit'           => 'nullable|integer|min:1|max:100',
        ]);

        $rows = Database::fetchAll(
            'SELECT l.id, l.product_id, l.name,
                    ls.variant_unit_id,
                    ls.quantity_total,
                    ls.quantity_sold,
                    (ls.quantity_total - ls.quantity_sold) AS quantity_left
             FROM lots l
             JOIN lot_stocks ls ON ls.lot_id = l.id
             WHERE l.product_id = ?
               AND ls.variant_unit_id = ?
               AND l.is_active = 1
               AND l.name LIKE ?
               AND (ls.quantity_total - ls.quantity_sold) > 0
             ORDER BY l.name ASC
             LIMIT ?',
            [
                (int)$filters['product_id'],
                (int)$filters['variant_unit_id'],
                '%' . ($filters['search'] ?? '') . '%',
                (int)$filters['limit'],
            ]
        );

        $rows = array_map(
            fn($r) => castRow($r, ['id', 'product_id', 'variant_unit_id'], ['quantity_total', 'quantity_sold', 'quantity_left']),
            $rows
        );

        Response::success($rows);
    }

    /** POST /lots */
    public static function store(Request $req): void
    {
        $data = sanitiseInput($req->all());
        (new Validator())->validateOrFail($data, [
            'product_id'   => 'required|integer',
            'name'         => 'required|string|max:120',
            'description'  => 'nullable|string|max:255',
            'expiry_date'  => 'nullable|date',
            'variant_unit_id' => 'nullable|integer',
            'quantity_total'  => 'nullable|numeric|min:0',
        ]);

        if (!Database::fetchOne('SELECT id FROM products WHERE id = ?', [(int)$data['product_id']])) {
            Response::notFound('Product not found');
        }

        if (Database::fetchScalar('SELECT COUNT(*) FROM lots WHERE product_id = ? AND name = ?', [(int)$data['product_id'], $data['name']])) {
            Response::error('Lot name already exists for this product', 409);
        }

        Database::beginTransaction();
        try {
            Database::query(
                'INSERT INTO lots (product_id, name, description, expiry_date, created_by) VALUES (?, ?, ?, ?, ?)',
                [(int)$data['product_id'], $data['name'], $data['description'] ?? null, $data['expiry_date'] ?? null, (int)$req->user['sub']]
            );
            $lotId = (int)Database::lastInsertId();

            if (array_key_exists('variant_unit_id', $data) || array_key_exists('quantity_total', $data)) {
                if (!isset($data['variant_unit_id']) || !isset($data['quantity_total'])) {
                    Response::error('Both variant_unit_id and quantity_total are required together', 422);
                }

                $vu = Database::fetchOne(
                    'SELECT vu.id, pv.product_id
                     FROM variant_units vu
                     JOIN product_variants pv ON pv.id = vu.variant_id
                     WHERE vu.id = ?',
                    [(int)$data['variant_unit_id']]
                );
                if (!$vu) {
                    Response::notFound('Variant-unit not found');
                }
                if ((int)$vu['product_id'] !== (int)$data['product_id']) {
                    Response::error('variant_unit_id does not belong to product_id', 422);
                }

                Database::query(
                    'INSERT INTO lot_stocks (lot_id, variant_unit_id, quantity_total, quantity_sold)
                     VALUES (?, ?, ?, 0)',
                    [$lotId, (int)$data['variant_unit_id'], (float)$data['quantity_total']]
                );
            }

            Database::commit();
            Response::created(['id' => $lotId], 'Lot created');
        } catch (Throwable $e) {
            Database::rollback();
            throw $e;
        }
    }

    /** GET /lots/{id} */
    public static function show(Request $req): void
    {
        $lot = Database::fetchOne(
            'SELECT l.id, l.product_id, p.name AS product_name,
                    l.name, l.description, l.expiry_date, l.is_active, l.created_at, l.updated_at,
                    (l.expiry_date IS NOT NULL AND l.expiry_date < CURDATE()) AS is_expired,
                    (l.expiry_date IS NOT NULL AND l.expiry_date >= CURDATE() AND l.expiry_date <= DATE_ADD(CURDATE(), INTERVAL 3 MONTH)) AS is_expiring_soon
             FROM lots l
             JOIN products p ON p.id = l.product_id
             WHERE l.id = ?',
            [(int)$req->params['id']]
        );

        if (!$lot) {
            Response::notFound('Lot not found');
        }

        $lot['stocks'] = Database::fetchAll(
            'SELECT ls.id, ls.lot_id, ls.variant_unit_id,
                    ls.quantity_total, ls.quantity_sold,
                    (ls.quantity_total - ls.quantity_sold) AS quantity_left,
                    vu.unit_id, u.name AS unit_name,
                    pv.id AS variant_id, p.name AS product_name
             FROM lot_stocks ls
             JOIN variant_units vu ON vu.id = ls.variant_unit_id
             JOIN units u ON u.id = vu.unit_id
             JOIN product_variants pv ON pv.id = vu.variant_id
             JOIN products p ON p.id = pv.product_id
             WHERE ls.lot_id = ?
             ORDER BY ls.id DESC',
            [(int)$lot['id']]
        );

        $lot['stocks'] = array_map(
            fn($r) => castRow($r, ['id', 'lot_id', 'variant_unit_id', 'unit_id', 'variant_id'], ['quantity_total', 'quantity_sold', 'quantity_left']),
            $lot['stocks']
        );

        Response::success(castRow($lot, ['id', 'product_id'], [], ['is_active', 'is_expired', 'is_expiring_soon']));
    }

    /** PUT /lots/{id} */
    public static function update(Request $req): void
    {
        $lotId = (int)$req->params['id'];
        if (!Database::fetchOne('SELECT id FROM lots WHERE id = ?', [$lotId])) {
            Response::notFound('Lot not found');
        }

        $data = sanitiseInput($req->all());
        (new Validator())->validateOrFail($data, [
            'name'        => 'nullable|string|max:120',
            'description' => 'nullable|string|max:255',
            'expiry_date' => 'nullable|date',
            'is_active'   => 'nullable|boolean',
        ]);

        $sets = [];
        $params = [];
        if (array_key_exists('name', $data)) { $sets[] = 'name = ?'; $params[] = $data['name']; }
        if (array_key_exists('description', $data)) { $sets[] = 'description = ?'; $params[] = $data['description']; }
        if (array_key_exists('expiry_date', $data)) { $sets[] = 'expiry_date = ?'; $params[] = $data['expiry_date'] ?: null; }
        if (array_key_exists('is_active', $data)) { $sets[] = 'is_active = ?'; $params[] = (int)(bool)$data['is_active']; }

        if (empty($sets)) {
            Response::error('Nothing to update', 400);
        }

        $params[] = $lotId;
        Database::query('UPDATE lots SET ' . implode(', ', $sets) . ' WHERE id = ?', $params);
        Response::success(null, 'Lot updated');
    }

    /** DELETE /lots/{id} (soft delete) */
    public static function destroy(Request $req): void
    {
        $lotId = (int)$req->params['id'];
        $updated = Database::query('UPDATE lots SET is_active = 0 WHERE id = ?', [$lotId])->rowCount();
        if (!$updated) {
            Response::notFound('Lot not found');
        }
        Response::success(null, 'Lot archived');
    }

    /** POST /lots/{id}/stocks */
    public static function addStock(Request $req): void
    {
        $lotId = (int)$req->params['id'];
        $lot = Database::fetchOne('SELECT id, product_id FROM lots WHERE id = ?', [$lotId]);
        if (!$lot) {
            Response::notFound('Lot not found');
        }

        $data = sanitiseInput($req->all());
        (new Validator())->validateOrFail($data, [
            'variant_unit_id' => 'required|integer',
            'quantity_total'  => 'required|numeric|min:0.0001',
        ]);

        $vu = Database::fetchOne(
            'SELECT vu.id, pv.product_id
             FROM variant_units vu
             JOIN product_variants pv ON pv.id = vu.variant_id
             WHERE vu.id = ?',
            [(int)$data['variant_unit_id']]
        );
        if (!$vu) {
            Response::notFound('Variant-unit not found');
        }
        if ((int)$vu['product_id'] !== (int)$lot['product_id']) {
            Response::error('variant_unit_id does not belong to lot product', 422);
        }

        $existing = Database::fetchOne(
            'SELECT id FROM lot_stocks WHERE lot_id = ? AND variant_unit_id = ?',
            [$lotId, (int)$data['variant_unit_id']]
        );

        if ($existing) {
            Database::query(
                'UPDATE lot_stocks SET quantity_total = quantity_total + ? WHERE id = ?',
                [(float)$data['quantity_total'], (int)$existing['id']]
            );
            Response::success(['id' => (int)$existing['id']], 'Lot stock increased');
        }

        Database::query(
            'INSERT INTO lot_stocks (lot_id, variant_unit_id, quantity_total, quantity_sold)
             VALUES (?, ?, ?, 0)',
            [$lotId, (int)$data['variant_unit_id'], (float)$data['quantity_total']]
        );

        Response::created(['id' => (int)Database::lastInsertId()], 'Lot stock created');
    }

    /** GET /lots/stats */
    public static function stats(Request $req): void
    {
        $filters = sanitiseInput([
            'product_id'      => $req->query('product_id'),
            'lot_id'          => $req->query('lot_id'),
            'variant_unit_id' => $req->query('variant_unit_id'),
        ]);

        (new Validator())->validateOrFail($filters, [
            'product_id'      => 'nullable|integer',
            'lot_id'          => 'nullable|integer',
            'variant_unit_id' => 'nullable|integer',
        ]);

        $where = ['1=1'];
        $params = [];
        if (!empty($filters['product_id'])) {
            $where[] = 'l.product_id = ?';
            $params[] = (int)$filters['product_id'];
        }
        if (!empty($filters['lot_id'])) {
            $where[] = 'l.id = ?';
            $params[] = (int)$filters['lot_id'];
        }
        if (!empty($filters['variant_unit_id'])) {
            $where[] = 'ls.variant_unit_id = ?';
            $params[] = (int)$filters['variant_unit_id'];
        }

        $w = implode(' AND ', $where);

        $rows = Database::fetchAll(
            "SELECT l.id AS lot_id, l.product_id, l.name AS lot_name,
                    COALESCE(SUM(ls.quantity_total), 0) AS quantity_total,
                    COALESCE(SUM(ls.quantity_sold), 0) AS quantity_sold,
                    COALESCE(SUM(ls.quantity_total - ls.quantity_sold), 0) AS quantity_left
             FROM lots l
             LEFT JOIN lot_stocks ls ON ls.lot_id = l.id
             WHERE $w
             GROUP BY l.id, l.product_id, l.name
             ORDER BY l.id DESC",
            $params
        );

        $rows = array_map(
            fn($r) => castRow($r, ['lot_id', 'product_id'], ['quantity_total', 'quantity_sold', 'quantity_left']),
            $rows
        );

        Response::success($rows);
    }

    /** GET /lots/expiring-soon?days=90 */
    public static function expiringSoon(Request $req): void
    {
        $filters = sanitiseInput([
            'days' => $req->query('days', 90),
        ]);

        (new Validator())->validateOrFail($filters, [
            'days' => 'nullable|integer|min:1|max:365',
        ]);

        $days = (int)($filters['days'] ?? 90);

        $products = Database::fetchAll(
            'SELECT p.id, p.name, p.product_code, p.expiry_date,
                    DATEDIFF(p.expiry_date, CURDATE()) AS days_remaining,
                    (p.expiry_date < CURDATE()) AS is_expired,
                    (p.expiry_date >= CURDATE() AND p.expiry_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY)) AS is_expiring_soon
             FROM products p
             WHERE p.expiry_date IS NOT NULL
               AND p.is_active = 1
               AND p.expiry_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY)
             ORDER BY p.expiry_date ASC, p.id ASC',
            [$days, $days]
        );

        $lots = Database::fetchAll(
            'SELECT l.id, l.product_id, p.name AS product_name, l.name,
                    l.expiry_date,
                    DATEDIFF(l.expiry_date, CURDATE()) AS days_remaining,
                    (l.expiry_date < CURDATE()) AS is_expired,
                    (l.expiry_date >= CURDATE() AND l.expiry_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY)) AS is_expiring_soon,
                    COALESCE(SUM(ls.quantity_total - ls.quantity_sold), 0) AS quantity_left
             FROM lots l
             JOIN products p ON p.id = l.product_id
             LEFT JOIN lot_stocks ls ON ls.lot_id = l.id
             WHERE l.expiry_date IS NOT NULL
               AND l.is_active = 1
               AND l.expiry_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY)
             GROUP BY l.id, l.product_id, p.name, l.name, l.expiry_date
             ORDER BY l.expiry_date ASC, l.id ASC',
            [$days, $days]
        );

        $products = array_map(
            fn($row) => castRow($row, ['id', 'days_remaining'], [], ['is_expired', 'is_expiring_soon']),
            $products
        );
        $lots = array_map(
            fn($row) => castRow($row, ['id', 'product_id', 'days_remaining'], ['quantity_left'], ['is_expired', 'is_expiring_soon']),
            $lots
        );

        Response::success([
            'days' => $days,
            'products' => $products,
            'lots' => $lots,
            'totals' => [
                'products' => count($products),
                'lots' => count($lots),
            ],
        ]);
    }

    /** POST /quotations/{id}/lot-assignments */
    public static function assignToQuotation(Request $req): void
    {
        $quotationId = (int)$req->params['id'];

        $quote = Database::fetchOne('SELECT id, status FROM quotation_requests WHERE id = ?', [$quotationId]);
        if (!$quote) {
            Response::notFound('Quotation not found');
        }
        if ($quote['status'] !== 'pending') {
            Response::error('Only pending quotations can receive lot assignments', 409);
        }

        $data = $req->all();
        (new Validator())->validateOrFail($data, [
            'assignments' => 'required|array',
        ]);

        if (empty($data['assignments'])) {
            Response::error('assignments cannot be empty', 422);
        }

        Database::beginTransaction();
        try {
            foreach ($data['assignments'] as $idx => $entry) {
                if (empty($entry['quotation_item_id']) || !isset($entry['lots']) || !is_array($entry['lots'])) {
                    Response::error("Assignment $idx requires quotation_item_id and lots[]", 422);
                }

                $qi = Database::fetchOne(
                    'SELECT qi.id, qi.variant_unit_id, qi.quantity
                     FROM quotation_items qi
                     WHERE qi.id = ? AND qi.quotation_id = ?',
                    [(int)$entry['quotation_item_id'], $quotationId]
                );
                if (!$qi) {
                    Response::notFound('Quotation item not found for this quotation');
                }

                Database::query('DELETE FROM lot_assignments WHERE quotation_item_id = ?', [(int)$qi['id']]);

                $assigned = 0.0;
                foreach ($entry['lots'] as $lidx => $lotEntry) {
                    if (empty($lotEntry['lot_id']) || !isset($lotEntry['quantity'])) {
                        Response::error("Assignment $idx lot $lidx requires lot_id and quantity", 422);
                    }
                    if ((float)$lotEntry['quantity'] <= 0) {
                        Response::error("Assignment $idx lot $lidx quantity must be positive", 422);
                    }

                    $ok = Database::fetchOne(
                        'SELECT ls.id
                         FROM lot_stocks ls
                         JOIN lots l ON l.id = ls.lot_id
                         JOIN variant_units vu ON vu.id = ls.variant_unit_id
                         JOIN product_variants pv ON pv.id = vu.variant_id
                         WHERE l.id = ? AND ls.variant_unit_id = ? AND l.is_active = 1',
                        [(int)$lotEntry['lot_id'], (int)$qi['variant_unit_id']]
                    );
                    if (!$ok) {
                        Response::error("Lot #{$lotEntry['lot_id']} is not valid for quotation item #{$qi['id']}", 422);
                    }

                    Database::query(
                        'INSERT INTO lot_assignments (quotation_item_id, lot_id, quantity) VALUES (?, ?, ?)',
                        [(int)$qi['id'], (int)$lotEntry['lot_id'], (float)$lotEntry['quantity']]
                    );
                    $assigned += (float)$lotEntry['quantity'];
                }

                if (abs($assigned - (float)$qi['quantity']) > 0.0001) {
                    Response::error("Assigned lot quantity must equal item quantity for item #{$qi['id']}", 422);
                }
            }

            Database::commit();
            Response::success(null, 'Lot assignments saved');
        } catch (Throwable $e) {
            Database::rollback();
            throw $e;
        }
    }
}
