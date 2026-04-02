<?php
// ============================================================
// QuotationController
// ============================================================

class QuotationController
{
    /**
     * GET /quotations
     * Salesman sees only their own; editors/admins/viewers see all.
     * ?status=pending&salesman_id=3&page=1&per_page=20
     */
    public static function index(Request $req): void
    {
        $filters = sanitiseInput([
            'status'      => $req->query('status'),
            'salesman_id' => $req->query('salesman_id'),
            'page'        => $req->query('page', 1),
            'per_page'    => $req->query('per_page', 20),
        ]);
        (new Validator())->validateOrFail($filters, [
            'status'      => 'nullable|in:pending,accepted,rejected,returned',
            'salesman_id' => 'nullable|integer',
            'page'        => 'nullable|integer|min:1',
            'per_page'    => 'nullable|integer|min:1|max:200',
        ]);

        $role    = $req->user['role'];
        $userId  = (int)$req->user['sub'];
        $where   = ['1=1'];
        $params  = [];

        // Salesmen restricted to own quotes
        if ($role === 'salesman') {
            $where[] = 'qr.salesman_id = ?';
            $params[] = $userId;
        } elseif ($sid = $filters['salesman_id']) {
            $where[] = 'qr.salesman_id = ?';
            $params[] = $sid;
        }

        if ($status = $filters['status']) {
            $where[] = 'qr.status = ?';
            $params[] = $status;
        }

        $w   = implode(' AND ', $where);
        $sql = "SELECT qr.id, qr.salesman_id, u.name AS salesman_name,
                       qr.customer_id, c.name AS customer_name,
                       qr.status, qr.note, qr.requested_at, qr.processed_at
                FROM quotation_requests qr
                JOIN users u ON u.id = qr.salesman_id
                LEFT JOIN customers c ON c.id = qr.customer_id
                WHERE $w
                ORDER BY qr.requested_at DESC";

        $result         = paginate($sql, $params, (int)$filters['page'], (int)$filters['per_page']);
        $result['data'] = array_map(fn($r) => castRow($r, ['id', 'salesman_id', 'customer_id']), $result['data']);
        Response::success($result);
    }

    /**
     * POST /quotations
     * Body: { customer_id?, note?, items: [{variant_unit_id, quantity}] }
     */
    public static function store(Request $req): void
    {
        $data = sanitiseInput($req->all());
        (new Validator())->validateOrFail($data, [
            'items'       => 'required|array',
            'customer_id' => 'nullable|integer',
            'note'        => 'nullable|string',
        ]);

        if (isset($data['customer_id']) && !Database::fetchOne('SELECT id FROM customers WHERE id = ?', [$data['customer_id']])) {
            Response::notFound('Customer not found');
        }

        if (empty($data['items'])) Response::error('Quotation must have at least one item', 422);

        // Validate each item
        foreach ($data['items'] as $i => $item) {
            if (empty($item['variant_unit_id']) || !isset($item['quantity'])) {
                Response::error("Item $i missing variant_unit_id or quantity", 422);
            }
            if ((float)$item['quantity'] <= 0) {
                Response::error("Item $i quantity must be positive", 422);
            }
            if (!Database::fetchOne('SELECT id FROM variant_units WHERE id = ?', [$item['variant_unit_id']])) {
                Response::error("Variant-unit #{$item['variant_unit_id']} not found", 404);
            }
        }

        Database::beginTransaction();
        try {
            Database::query(
                'INSERT INTO quotation_requests (salesman_id, customer_id, note) VALUES (?, ?, ?)',
                [(int)$req->user['sub'], $data['customer_id'] ?? null, $data['note'] ?? null]
            );
            $quotationId = (int)Database::lastInsertId();

            foreach ($data['items'] as $item) {
                // Snapshot current unit_price at quote creation
                $vu = Database::fetchOne(
                    'SELECT unit_price FROM variant_units WHERE id = ?',
                    [$item['variant_unit_id']]
                );

                Database::query(
                    'INSERT INTO quotation_items (quotation_id, variant_unit_id, quantity, unit_price)
                     VALUES (?, ?, ?, ?)',
                    [$quotationId, $item['variant_unit_id'], $item['quantity'], $vu['unit_price']]
                );
            }

            Database::commit();
            Response::created(['id' => $quotationId], 'Quotation created');
        } catch (Throwable $e) {
            Database::rollback();
            throw $e;
        }
    }

    /** PUT /quotations/{id} */
    public static function update(Request $req): void
    {
        $quotationId = (int)$req->params['id'];
        $quote = Database::fetchOne(
            'SELECT id, status, customer_id, note FROM quotation_requests WHERE id = ?',
            [$quotationId]
        );
        if (!$quote) {
            Response::notFound('Quotation not found');
        }
        if ($quote['status'] !== 'pending') {
            Response::error('Only pending quotations can be updated', 409);
        }

        $data = sanitiseInput($req->all());
        (new Validator())->validateOrFail($data, [
            'customer_id' => 'nullable|integer',
            'note'        => 'nullable|string',
            'items'       => 'nullable|array',
        ]);

        if (isset($data['customer_id']) && !Database::fetchOne('SELECT id FROM customers WHERE id = ?', [$data['customer_id']])) {
            Response::notFound('Customer not found');
        }

        if (array_key_exists('items', $data)) {
            if (empty($data['items'])) {
                Response::error('Quotation must have at least one item', 422);
            }
            foreach ($data['items'] as $i => $item) {
                if (empty($item['variant_unit_id']) || !isset($item['quantity'])) {
                    Response::error("Item $i missing variant_unit_id or quantity", 422);
                }
                if ((float)$item['quantity'] <= 0) {
                    Response::error("Item $i quantity must be positive", 422);
                }
                if (!Database::fetchOne('SELECT id FROM variant_units WHERE id = ?', [$item['variant_unit_id']])) {
                    Response::error("Variant-unit #{$item['variant_unit_id']} not found", 404);
                }
            }
        }

        Database::beginTransaction();
        try {
            $sets = [];
            $params = [];
            if (array_key_exists('customer_id', $data)) { $sets[] = 'customer_id = ?'; $params[] = $data['customer_id']; }
            if (array_key_exists('note', $data)) { $sets[] = 'note = ?'; $params[] = $data['note']; }

            if (!empty($sets)) {
                $params[] = $quotationId;
                Database::query('UPDATE quotation_requests SET ' . implode(', ', $sets) . ' WHERE id = ?', $params);
            }

            if (array_key_exists('items', $data)) {
                Database::query('DELETE FROM quotation_items WHERE quotation_id = ?', [$quotationId]);
                foreach ($data['items'] as $item) {
                    $vu = Database::fetchOne('SELECT unit_price FROM variant_units WHERE id = ?', [$item['variant_unit_id']]);
                    Database::query(
                        'INSERT INTO quotation_items (quotation_id, variant_unit_id, quantity, unit_price)
                         VALUES (?, ?, ?, ?)',
                        [$quotationId, $item['variant_unit_id'], $item['quantity'], $vu['unit_price']]
                    );
                }
            }

            if (empty($sets) && !array_key_exists('items', $data)) {
                Response::error('Nothing to update', 400);
            }

            Database::commit();
            Response::success(null, 'Quotation updated');
        } catch (Throwable $e) {
            Database::rollback();
            throw $e;
        }
    }

    /** GET /quotations/{id} */
    public static function show(Request $req): void
    {
        $role    = $req->user['role'];
        $userId  = (int)$req->user['sub'];

        $quote = Database::fetchOne(
            'SELECT qr.*, u.name AS salesman_name, c.name AS customer_name
             FROM quotation_requests qr
             JOIN users u ON u.id = qr.salesman_id
             LEFT JOIN customers c ON c.id = qr.customer_id
             WHERE qr.id = ?',
            [$req->params['id']]
        );
        if (!$quote) Response::notFound('Quotation not found');

        // Salesmen can only see their own
        if ($role === 'salesman' && (int)$quote['salesman_id'] !== $userId) {
            Response::forbidden();
        }

        // Items
        $quote['items'] = Database::fetchAll(
            'SELECT qi.id, qi.variant_unit_id, qi.quantity, qi.unit_price,
                    pv.attributes, p.name AS product_name, p.product_code,
                    u.name AS unit_name
             FROM quotation_items qi
             JOIN variant_units vu  ON vu.id  = qi.variant_unit_id
             JOIN product_variants pv ON pv.id = vu.variant_id
             JOIN products p         ON p.id   = pv.product_id
             JOIN units u            ON u.id   = vu.unit_id
             WHERE qi.quotation_id = ?',
            [$quote['id']]
        );

        foreach ($quote['items'] as &$item) {
            $item['attributes'] = json_decode($item['attributes'], true);
            $item = castRow($item, ['id', 'variant_unit_id'], ['quantity', 'unit_price']);
        }

        Response::success(castRow($quote, ['id', 'salesman_id', 'customer_id', 'editor_id']));
    }

    /**
     * PUT /quotations/{id}/status
     * Body: { status: "accepted"|"rejected"|"returned", customer_id? }
     * Only editors/superadmins may call this.
     */
    public static function updateStatus(Request $req): void
    {
        $data = $req->all();
        (new Validator())->validateOrFail($data, [
            'status'      => 'required|in:accepted,rejected,returned',
            'customer_id' => 'nullable|integer',
        ]);

        $quotationId = (int)$req->params['id'];
        $editorId    = (int)$req->user['sub'];
        $status      = $data['status'];

        switch ($status) {
            case 'accepted':
                if (empty($data['customer_id'])) {
                    Response::error('customer_id is required to accept a quotation', 422);
                }
                $result = QuotationService::accept($quotationId, $editorId, (int)$data['customer_id']);
                Response::success($result, 'Quotation accepted; stock deducted and invoice created');

            case 'returned':
                QuotationService::returnQuote($quotationId, $editorId);
                Response::success(null, 'Quotation returned; stock restored');

            case 'rejected':
                QuotationService::reject($quotationId, $editorId);
                Response::success(null, 'Quotation rejected');
        }
    }

    /** DELETE /quotations/{id} */
    public static function destroy(Request $req): void
    {
        $quotationId = (int)$req->params['id'];
        $quote = Database::fetchOne(
            'SELECT id, status FROM quotation_requests WHERE id = ?',
            [$quotationId]
        );
        if (!$quote) {
            Response::notFound('Quotation not found');
        }

        if ($quote['status'] !== 'pending') {
            Response::error('Only pending quotations can be deleted', 409);
        }

        if ((int)Database::fetchScalar('SELECT COUNT(*) FROM sales_invoices WHERE quotation_id = ?', [$quotationId]) > 0) {
            Response::error('Quotation already has an invoice and cannot be deleted', 409);
        }

        Database::beginTransaction();
        try {
            Database::query('DELETE FROM quotation_items WHERE quotation_id = ?', [$quotationId]);
            Database::query('DELETE FROM quotation_requests WHERE id = ?', [$quotationId]);
            Database::commit();
            Response::noContent();
        } catch (Throwable $e) {
            Database::rollback();
            throw $e;
        }
    }
}
