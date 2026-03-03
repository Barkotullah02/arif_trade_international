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
        $where = ['1=1']; $params = [];

        if ($cid = $req->query('customer_id')) {
            $where[] = 'si.customer_id = ?'; $params[] = $cid;
        }
        if ($from = $req->query('from')) {
            $where[] = 'si.date >= ?'; $params[] = $from;
        }
        if ($to = $req->query('to')) {
            $where[] = 'si.date <= ?'; $params[] = $to;
        }
        if ($status = $req->query('status')) {
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

        $result = paginate($sql, $params, (int)$req->query('page', 1), (int)$req->query('per_page', 20));
        $result['data'] = array_map(
            fn($r) => castRow($r, ['id', 'quotation_id', 'customer_id'], ['total_amount', 'paid', 'due']),
            $result['data']
        );
        Response::success($result);
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
}
