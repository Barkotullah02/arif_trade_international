<?php
// ============================================================
// InventoryController – audit log with rich filters
// ============================================================

class InventoryController
{
    /**
     * GET /inventory
     * ?action=handover&variant_unit_id=3&product_id=5
     *  &from=2026-01-01&to=2026-12-31&user_id=2
     *  &page=1&per_page=50
     */
    public static function index(Request $req): void
    {
        $filters = sanitiseInput([
            'action'          => $req->query('action'),
            'variant_unit_id' => $req->query('variant_unit_id'),
            'product_id'      => $req->query('product_id'),
            'user_id'         => $req->query('user_id'),
            'from'            => $req->query('from'),
            'to'              => $req->query('to'),
            'page'            => $req->query('page', 1),
            'per_page'        => $req->query('per_page', 50),
        ]);

        (new Validator())->validateOrFail($filters, [
            'action'          => 'nullable|in:handover,sold,returned',
            'variant_unit_id' => 'nullable|integer',
            'product_id'      => 'nullable|integer',
            'user_id'         => 'nullable|integer',
            'from'            => 'nullable|date',
            'to'              => 'nullable|date',
            'page'            => 'nullable|integer|min:1',
            'per_page'        => 'nullable|integer|min:1|max:200',
        ]);

        $where  = ['1=1'];
        $params = [];

        if ($action = $filters['action']) {
            $where[] = 'il.action = ?'; $params[] = $action;
        }
        if ($vu = $filters['variant_unit_id']) {
            $where[] = 'il.variant_unit_id = ?'; $params[] = $vu;
        }
        if ($productId = $filters['product_id']) {
            $where[] = 'p.id = ?'; $params[] = $productId;
        }
        if ($uid = $filters['user_id']) {
            $where[] = 'il.user_id = ?'; $params[] = $uid;
        }
        if ($from = $filters['from']) {
            $where[] = 'DATE(il.created_at) >= ?'; $params[] = $from;
        }
        if ($to = $filters['to']) {
            $where[] = 'DATE(il.created_at) <= ?'; $params[] = $to;
        }

        $w   = implode(' AND ', $where);
        $sql = "SELECT il.id, il.variant_unit_id, il.quantity, il.action,
                       il.related_id, il.note, il.created_at,
                       u.name AS user_name, u.role AS user_role,
                       p.id AS product_id, p.name AS product_name, p.product_code,
                       un.name AS unit_name,
                       pv.attributes AS variant_attributes
                FROM inventory_log il
                LEFT JOIN users u            ON u.id  = il.user_id
                JOIN variant_units vu         ON vu.id = il.variant_unit_id
                JOIN units un                 ON un.id = vu.unit_id
                JOIN product_variants pv      ON pv.id = vu.variant_id
                JOIN products p               ON p.id  = pv.product_id
                WHERE $w
                ORDER BY il.created_at DESC";

        $result = paginate($sql, $params, (int)$filters['page'], (int)$filters['per_page']);

        $result['data'] = array_map(function ($r) {
            $r['variant_attributes'] = json_decode($r['variant_attributes'], true);
            return castRow($r, ['id', 'variant_unit_id', 'related_id', 'product_id'], ['quantity']);
        }, $result['data']);

        Response::success($result);
    }

    /** GET /inventory/log */
    public static function log(Request $req): void
    {
        self::index($req);
    }

    /** POST /inventory */
    public static function store(Request $req): void
    {
        $data = sanitiseInput($req->all());
        (new Validator())->validateOrFail($data, [
            'variant_unit_id' => 'required|integer',
            'quantity'        => 'required|numeric',
            'action'          => 'required|in:handover,sold,returned',
            'related_id'      => 'nullable|integer',
            'note'            => 'nullable|string',
            'user_id'         => 'nullable|integer',
        ]);

        if ((float)$data['quantity'] == 0.0) {
            Response::error('quantity must not be zero', 422);
        }

        if (!Database::fetchOne('SELECT id FROM variant_units WHERE id = ?', [$data['variant_unit_id']])) {
            Response::notFound('Variant-unit not found');
        }

        $userId = isset($data['user_id']) ? (int)$data['user_id'] : (int)$req->user['sub'];
        if (!Database::fetchOne('SELECT id FROM users WHERE id = ?', [$userId])) {
            Response::notFound('User not found');
        }

        Database::query(
            'INSERT INTO inventory_log (variant_unit_id, quantity, action, related_id, user_id, note)
             VALUES (?, ?, ?, ?, ?, ?)',
            [
                $data['variant_unit_id'],
                $data['quantity'],
                $data['action'],
                $data['related_id'] ?? null,
                $userId,
                $data['note'] ?? null,
            ]
        );

        Response::created(['id' => (int)Database::lastInsertId()], 'Inventory log entry created');
    }

    /** GET /inventory/{id} */
    public static function show(Request $req): void
    {
        $row = Database::fetchOne(
            'SELECT il.id, il.variant_unit_id, il.quantity, il.action,
                    il.related_id, il.note, il.created_at,
                    u.name AS user_name, u.role AS user_role,
                    p.id AS product_id, p.name AS product_name, p.product_code,
                    un.name AS unit_name,
                    pv.attributes AS variant_attributes
             FROM inventory_log il
             LEFT JOIN users u            ON u.id  = il.user_id
             JOIN variant_units vu         ON vu.id = il.variant_unit_id
             JOIN units un                 ON un.id = vu.unit_id
             JOIN product_variants pv      ON pv.id = vu.variant_id
             JOIN products p               ON p.id  = pv.product_id
             WHERE il.id = ?',
            [(int)$req->params['id']]
        );

        if (!$row) {
            Response::notFound('Inventory log entry not found');
        }

        $row['variant_attributes'] = json_decode($row['variant_attributes'], true);
        Response::success(castRow($row, ['id', 'variant_unit_id', 'related_id', 'product_id'], ['quantity']));
    }

    /** PUT /inventory/{id} */
    public static function update(Request $req): void
    {
        $entryId = (int)$req->params['id'];
        if (!Database::fetchOne('SELECT id FROM inventory_log WHERE id = ?', [$entryId])) {
            Response::notFound('Inventory log entry not found');
        }

        $data = sanitiseInput($req->all());
        (new Validator())->validateOrFail($data, [
            'variant_unit_id' => 'nullable|integer',
            'quantity'        => 'nullable|numeric',
            'action'          => 'nullable|in:handover,sold,returned',
            'related_id'      => 'nullable|integer',
            'note'            => 'nullable|string',
            'user_id'         => 'nullable|integer',
        ]);

        if (array_key_exists('quantity', $data) && (float)$data['quantity'] == 0.0) {
            Response::error('quantity must not be zero', 422);
        }

        if (isset($data['variant_unit_id']) && !Database::fetchOne('SELECT id FROM variant_units WHERE id = ?', [$data['variant_unit_id']])) {
            Response::notFound('Variant-unit not found');
        }
        if (isset($data['user_id']) && !Database::fetchOne('SELECT id FROM users WHERE id = ?', [$data['user_id']])) {
            Response::notFound('User not found');
        }

        $sets = [];
        $params = [];
        foreach (['variant_unit_id', 'quantity', 'action', 'related_id', 'note', 'user_id'] as $field) {
            if (array_key_exists($field, $data)) {
                $sets[] = "$field = ?";
                $params[] = $data[$field];
            }
        }

        if (empty($sets)) {
            Response::error('Nothing to update', 400);
        }

        $params[] = $entryId;
        Database::query('UPDATE inventory_log SET ' . implode(', ', $sets) . ' WHERE id = ?', $params);
        Response::success(null, 'Inventory log entry updated');
    }

    /** DELETE /inventory/{id} */
    public static function destroy(Request $req): void
    {
        $deleted = Database::query(
            'DELETE FROM inventory_log WHERE id = ?',
            [(int)$req->params['id']]
        )->rowCount();

        if (!$deleted) {
            Response::notFound('Inventory log entry not found');
        }

        Response::noContent();
    }
}
