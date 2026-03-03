<?php
// ============================================================
// CustomerController
// ============================================================

class CustomerController
{
    /**
     * GET /customers
     * ?type=doctor&search=ali&page=1&per_page=20
     */
    public static function index(Request $req): void
    {
        $where = ['1=1']; $params = [];

        if ($type = $req->query('type')) {
            $where[] = 'type = ?'; $params[] = $type;
        }
        if ($s = $req->query('search')) {
            $where[] = '(name LIKE ? OR phone LIKE ? OR email LIKE ?)';
            $params  = array_merge($params, ["%$s%", "%$s%", "%$s%"]);
        }

        $w      = implode(' AND ', $where);
        $sql    = "SELECT id, name, type, phone, email, address, created_at FROM customers WHERE $w ORDER BY name";
        $result = paginate($sql, $params, (int)$req->query('page', 1), (int)$req->query('per_page', 20));
        $result['data'] = array_map(fn($r) => castRow($r, ['id']), $result['data']);
        Response::success($result);
    }

    /** POST /customers */
    public static function store(Request $req): void
    {
        $data = sanitiseInput($req->all());
        (new Validator())->validateOrFail($data, [
            'name'    => 'required|string|max:150',
            'type'    => 'required|string|max:50',
            'phone'   => 'nullable|string|max:30',
            'email'   => 'nullable|email|max:150',
            'address' => 'nullable|string',
        ]);

        Database::query(
            'INSERT INTO customers (name, type, phone, email, address, created_by)
             VALUES (?, ?, ?, ?, ?, ?)',
            [$data['name'], $data['type'], $data['phone'] ?? null, $data['email'] ?? null,
             $data['address'] ?? null, $req->user['sub']]
        );
        Response::created(['id' => (int)Database::lastInsertId()], 'Customer created');
    }

    /** GET /customers/{id} */
    public static function show(Request $req): void
    {
        $customer = Database::fetchOne(
            'SELECT id, name, type, phone, email, address, created_at, updated_at
             FROM customers WHERE id = ?',
            [$req->params['id']]
        );
        if (!$customer) Response::notFound('Customer not found');

        // Recent invoices summary
        $customer['recent_invoices'] = Database::fetchAll(
            'SELECT id, date, total_amount, status,
                    COALESCE((SELECT SUM(amount_paid) FROM payments WHERE invoice_id = si.id), 0) AS paid
             FROM sales_invoices si WHERE customer_id = ? ORDER BY date DESC LIMIT 10',
            [$customer['id']]
        );

        Response::success(castRow($customer, ['id']));
    }

    /** PUT /customers/{id} */
    public static function update(Request $req): void
    {
        if (!Database::fetchOne('SELECT id FROM customers WHERE id = ?', [$req->params['id']])) {
            Response::notFound('Customer not found');
        }

        $data = sanitiseInput($req->all());
        (new Validator())->validateOrFail($data, [
            'name'    => 'nullable|string|max:150',
            'type'    => 'nullable|string|max:50',
            'phone'   => 'nullable|string|max:30',
            'email'   => 'nullable|email|max:150',
            'address' => 'nullable|string',
        ]);

        $sets = []; $params = [];
        foreach (['name', 'type', 'phone', 'email', 'address'] as $f) {
            if (array_key_exists($f, $data)) { $sets[] = "$f = ?"; $params[] = $data[$f]; }
        }
        if (empty($sets)) Response::error('Nothing to update', 400);
        $params[] = $req->params['id'];
        Database::query('UPDATE customers SET ' . implode(', ', $sets) . ' WHERE id = ?', $params);
        Response::success(null, 'Customer updated');
    }

    /** DELETE /customers/{id} */
    public static function destroy(Request $req): void
    {
        $inUse = Database::fetchScalar(
            'SELECT COUNT(*) FROM sales_invoices WHERE customer_id = ?',
            [$req->params['id']]
        );
        if ($inUse) Response::error('Customer has invoices and cannot be deleted', 409);

        $deleted = Database::query('DELETE FROM customers WHERE id = ?', [$req->params['id']])->rowCount();
        if (!$deleted) Response::notFound('Customer not found');
        Response::noContent();
    }
}
