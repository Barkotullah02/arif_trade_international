<?php
// ============================================================
// InvoiceController
// ============================================================

class InvoiceController
{
    /**
     * GET /invoices
     * ?customer_id=5&from=2026-01-01&to=2026-12-31&status=active&page=1&per_page=20
     */
    public static function index(Request $req): void
    {
        $filters = sanitiseInput([
            'customer_id' => $req->query('customer_id'),
            'from'        => $req->query('from'),
            'to'          => $req->query('to'),
            'status'      => $req->query('status'),
            'page'        => $req->query('page', 1),
            'per_page'    => $req->query('per_page', 20),
        ]);

        (new Validator())->validateOrFail($filters, [
            'customer_id' => 'nullable|integer',
            'from'        => 'nullable|date',
            'to'          => 'nullable|date',
            'status'      => 'nullable|in:active,returned,void',
            'page'        => 'nullable|integer|min:1',
            'per_page'    => 'nullable|integer|min:1|max:200',
        ]);

        $where = ['1=1']; $params = [];

        if ($cid = $filters['customer_id']) {
            $where[] = 'si.customer_id = ?'; $params[] = $cid;
        }
        if ($from = $filters['from']) {
            $where[] = 'si.date >= ?'; $params[] = $from;
        }
        if ($to = $filters['to']) {
            $where[] = 'si.date <= ?'; $params[] = $to;
        }
        if ($status = $filters['status']) {
            $where[] = 'si.status = ?'; $params[] = $status;
        }

        $w   = implode(' AND ', $where);
        $sql = "SELECT si.id, si.quotation_id, si.customer_id, c.name AS customer_name,
                       si.date, si.total_amount, si.status,
                       COALESCE((SELECT SUM(amount_paid) FROM payments p WHERE p.invoice_id = si.id), 0) AS paid,
                       si.total_amount
                       - COALESCE((SELECT SUM(amount_paid) FROM payments p WHERE p.invoice_id = si.id), 0) AS due,
                       si.created_at
                FROM sales_invoices si
                JOIN customers c ON c.id = si.customer_id
                WHERE $w
                ORDER BY si.date DESC";

        $result = paginate($sql, $params, (int)$filters['page'], (int)$filters['per_page']);
        $result['data'] = array_map(
            fn($r) => castRow($r, ['id', 'quotation_id', 'customer_id'], ['total_amount', 'paid', 'due']),
            $result['data']
        );
        Response::success($result);
    }

    /** POST /invoices */
    public static function store(Request $req): void
    {
        $data = sanitiseInput($req->all());
        (new Validator())->validateOrFail($data, [
            'quotation_id' => 'required|integer',
            'customer_id'  => 'required|integer',
            'date'         => 'required|date',
            'total_amount' => 'required|numeric|min:0',
            'status'       => 'nullable|in:active,returned,void',
        ]);

        if (!Database::fetchOne('SELECT id FROM quotation_requests WHERE id = ?', [$data['quotation_id']])) {
            Response::notFound('Quotation not found');
        }
        if (!Database::fetchOne('SELECT id FROM customers WHERE id = ?', [$data['customer_id']])) {
            Response::notFound('Customer not found');
        }
        if (Database::fetchScalar('SELECT COUNT(*) FROM sales_invoices WHERE quotation_id = ?', [$data['quotation_id']])) {
            Response::error('Invoice already exists for this quotation', 409);
        }

        Database::query(
            'INSERT INTO sales_invoices (quotation_id, customer_id, date, total_amount, status, created_by)
             VALUES (?, ?, ?, ?, ?, ?)',
            [
                $data['quotation_id'],
                $data['customer_id'],
                $data['date'],
                $data['total_amount'],
                $data['status'] ?? 'active',
                (int)$req->user['sub'],
            ]
        );

        Response::created(['id' => (int)Database::lastInsertId()], 'Invoice created');
    }

    /** GET /invoices/{id} */
    public static function show(Request $req): void
    {
        $invoice = Database::fetchOne(
            'SELECT si.id, si.quotation_id, si.customer_id, c.name AS customer_name,
                    si.date, si.total_amount, si.status, si.created_at, si.updated_at,
                    COALESCE((SELECT SUM(amount_paid) FROM payments p WHERE p.invoice_id = si.id), 0) AS paid
             FROM sales_invoices si
             JOIN customers c ON c.id = si.customer_id
             WHERE si.id = ?',
            [$req->params['id']]
        );
        if (!$invoice) Response::notFound('Invoice not found');

        $invoice['due']   = round((float)$invoice['total_amount'] - (float)$invoice['paid'], 2);

        // Line items (from quotation)
        $invoice['items'] = Database::fetchAll(
            'SELECT qi.id, qi.variant_unit_id, qi.quantity, qi.unit_price,
                    (qi.quantity * qi.unit_price) AS line_total,
                    pv.attributes,
                    p.name AS product_name, p.product_code,
                    u.name AS unit_name
             FROM quotation_items qi
             JOIN variant_units vu    ON vu.id  = qi.variant_unit_id
             JOIN product_variants pv ON pv.id  = vu.variant_id
             JOIN products p          ON p.id   = pv.product_id
             JOIN units u             ON u.id   = vu.unit_id
             WHERE qi.quotation_id = ?',
            [$invoice['quotation_id']]
        );
        foreach ($invoice['items'] as &$item) {
            $item['attributes'] = json_decode($item['attributes'], true);
            $item = castRow($item, ['id', 'variant_unit_id'], ['quantity', 'unit_price', 'line_total']);
        }

        // Payments
        $invoice['payments'] = Database::fetchAll(
            'SELECT id, amount_paid, payment_date, method, reference, note FROM payments
             WHERE invoice_id = ? ORDER BY payment_date',
            [$invoice['id']]
        );

        Response::success(castRow($invoice, ['id', 'quotation_id', 'customer_id'], ['total_amount', 'paid', 'due']));
    }

    /** PUT /invoices/{id} */
    public static function update(Request $req): void
    {
        $invoiceId = (int)$req->params['id'];
        if (!Database::fetchOne('SELECT id FROM sales_invoices WHERE id = ?', [$invoiceId])) {
            Response::notFound('Invoice not found');
        }

        $data = sanitiseInput($req->all());
        (new Validator())->validateOrFail($data, [
            'customer_id'  => 'nullable|integer',
            'date'         => 'nullable|date',
            'total_amount' => 'nullable|numeric|min:0',
            'status'       => 'nullable|in:active,returned,void',
        ]);

        if (isset($data['customer_id']) && !Database::fetchOne('SELECT id FROM customers WHERE id = ?', [$data['customer_id']])) {
            Response::notFound('Customer not found');
        }

        $sets = [];
        $params = [];
        if (array_key_exists('customer_id', $data)) { $sets[] = 'customer_id = ?'; $params[] = $data['customer_id']; }
        if (array_key_exists('date', $data)) { $sets[] = 'date = ?'; $params[] = $data['date']; }
        if (array_key_exists('total_amount', $data)) { $sets[] = 'total_amount = ?'; $params[] = $data['total_amount']; }
        if (array_key_exists('status', $data)) { $sets[] = 'status = ?'; $params[] = $data['status']; }

        if (empty($sets)) {
            Response::error('Nothing to update', 400);
        }

        $params[] = $invoiceId;
        Database::query('UPDATE sales_invoices SET ' . implode(', ', $sets) . ' WHERE id = ?', $params);

        Response::success(null, 'Invoice updated');
    }

    /** DELETE /invoices/{id} */
    public static function destroy(Request $req): void
    {
        $invoiceId = (int)$req->params['id'];
        if (!Database::fetchOne('SELECT id FROM sales_invoices WHERE id = ?', [$invoiceId])) {
            Response::notFound('Invoice not found');
        }

        if ((int)Database::fetchScalar('SELECT COUNT(*) FROM payments WHERE invoice_id = ?', [$invoiceId]) > 0) {
            Response::error('Invoice has payments and cannot be deleted', 409);
        }

        Database::query('DELETE FROM sales_invoices WHERE id = ?', [$invoiceId]);
        Response::noContent();
    }
}
