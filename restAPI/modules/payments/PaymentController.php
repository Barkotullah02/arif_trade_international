<?php
// ============================================================
// PaymentController – partial payment records per invoice
// ============================================================

class PaymentController
{
    /** GET /invoices/{invoiceId}/payments */
    public static function index(Request $req): void
    {
        $invoiceId = (int)$req->params['invoiceId'];

        if (!Database::fetchOne('SELECT id FROM sales_invoices WHERE id = ?', [$invoiceId])) {
            Response::notFound('Invoice not found');
        }

        $rows = Database::fetchAll(
            'SELECT p.id, p.invoice_id, p.amount_paid, p.payment_date,
                    p.method, p.reference, p.note, p.created_at,
                    u.name AS received_by_name
             FROM payments p
             LEFT JOIN users u ON u.id = p.received_by
             WHERE p.invoice_id = ?
             ORDER BY p.payment_date',
            [$invoiceId]
        );

        // Summary: total due
        $invoice = Database::fetchOne(
            'SELECT total_amount,
                    COALESCE((SELECT SUM(amount_paid) FROM payments WHERE invoice_id = ?), 0) AS paid
             FROM sales_invoices WHERE id = ?',
            [$invoiceId, $invoiceId]
        );

        Response::success([
            'invoice_id'   => $invoiceId,
            'total_amount' => (float)$invoice['total_amount'],
            'total_paid'   => (float)$invoice['paid'],
            'due'          => round((float)$invoice['total_amount'] - (float)$invoice['paid'], 2),
            'payments'     => array_map(fn($r) => castRow($r, ['id', 'invoice_id'], ['amount_paid']), $rows),
        ]);
    }

    /** GET /payments/{id} */
    public static function show(Request $req): void
    {
        $row = Database::fetchOne(
            'SELECT p.id, p.invoice_id, p.amount_paid, p.payment_date,
                    p.method, p.reference, p.note, p.created_at,
                    u.name AS received_by_name
             FROM payments p
             LEFT JOIN users u ON u.id = p.received_by
             WHERE p.id = ?',
            [$req->params['id']]
        );
        if (!$row) Response::notFound('Payment not found');
        Response::success(castRow($row, ['id', 'invoice_id'], ['amount_paid']));
    }

    /**
     * POST /invoices/{invoiceId}/payments
     * Body: { amount_paid, payment_date, method?, reference?, note? }
     */
    public static function store(Request $req): void
    {
        $invoiceId = (int)$req->params['invoiceId'];

        $invoice = Database::fetchOne(
            'SELECT id, total_amount, status FROM sales_invoices WHERE id = ?',
            [$invoiceId]
        );
        if (!$invoice) Response::notFound('Invoice not found');
        if ($invoice['status'] !== 'active') {
            Response::error("Cannot add payment to a {$invoice['status']} invoice", 409);
        }

        $data = sanitiseInput($req->all());
        (new Validator())->validateOrFail($data, [
            'amount_paid'  => 'required|numeric|min:0.01',
            'payment_date' => 'required|date',
            'method'       => 'nullable|string|max:50',
            'reference'    => 'nullable|string|max:100',
            'note'         => 'nullable|string',
        ]);

        // Over-payment guard
        $alreadyPaid = (float)Database::fetchScalar(
            'SELECT COALESCE(SUM(amount_paid), 0) FROM payments WHERE invoice_id = ?',
            [$invoiceId]
        );
        $due = (float)$invoice['total_amount'] - $alreadyPaid;
        if ((float)$data['amount_paid'] > $due + 0.001) {
            Response::error("Payment exceeds outstanding due of $due", 422);
        }

        Database::query(
            'INSERT INTO payments (invoice_id, amount_paid, payment_date, method, reference, received_by, note)
             VALUES (?, ?, ?, ?, ?, ?, ?)',
            [$invoiceId, $data['amount_paid'], $data['payment_date'],
             $data['method'] ?? null, $data['reference'] ?? null,
             (int)$req->user['sub'], $data['note'] ?? null]
        );

        $newPaid = $alreadyPaid + (float)$data['amount_paid'];
        $newDue  = round((float)$invoice['total_amount'] - $newPaid, 2);

        Response::created([
            'id'         => (int)Database::lastInsertId(),
            'total_paid' => round($newPaid, 2),
            'due'        => $newDue,
        ], 'Payment recorded');
    }

    /**
     * DELETE /payments/{id}  (superadmin only – enforced by route middleware)
     */
    public static function destroy(Request $req): void
    {
        $deleted = Database::query(
            'DELETE FROM payments WHERE id = ?',
            [$req->params['id']]
        )->rowCount();
        if (!$deleted) Response::notFound('Payment not found');
        Response::noContent();
    }
}
