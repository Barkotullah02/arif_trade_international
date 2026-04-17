<?php
// ============================================================
// AnalyticsController – admin dashboard analytics endpoints
// ============================================================

class AnalyticsController
{
    /** GET /analytics/summary?month=YYYY-MM */
    public static function summary(Request $req): void
    {
        [$from, $to, $month] = self::resolveMonthRange($req->query('month'));

        $invoiceSummary = Database::fetchOne(
            'SELECT
                COUNT(*) AS invoice_count,
                COALESCE(SUM(si.total_amount), 0) AS total_revenue,
                COUNT(DISTINCT si.customer_id) AS customers_served
             FROM sales_invoices si
             WHERE si.date >= ?
               AND si.date <= ?
               AND si.status = "active"',
            [$from, $to]
        ) ?: ['invoice_count' => 0, 'total_revenue' => 0, 'customers_served' => 0];

        $totalPaid = (float)(Database::fetchScalar(
            'SELECT COALESCE(SUM(p.amount_paid), 0)
             FROM payments p
             WHERE p.payment_date >= ?
               AND p.payment_date <= ?',
            [$from, $to]
        ) ?? 0);

        $totalDue = (float)(Database::fetchScalar(
            'SELECT COALESCE(SUM(si.total_amount), 0)
                - COALESCE((
                    SELECT SUM(p.amount_paid)
                    FROM payments p
                    JOIN sales_invoices sx ON sx.id = p.invoice_id
                    WHERE sx.status = "active"
                      AND sx.date >= ?
                      AND sx.date <= ?
                ), 0)
             FROM sales_invoices si
             WHERE si.status = "active"
               AND si.date >= ?
               AND si.date <= ?',
            [$from, $to, $from, $to]
        ) ?? 0);

        $lotSummary = Database::fetchOne(
            'SELECT
                COUNT(DISTINCT l.id) AS total_lots,
                COUNT(DISTINCT CASE WHEN (ls.quantity_total - ls.quantity_sold) > 0 THEN l.id END) AS lots_with_stock,
                COUNT(DISTINCT CASE
                    WHEN (ls.quantity_total - ls.quantity_sold) > 0
                     AND (ls.quantity_total - ls.quantity_sold) <= 10
                    THEN l.id END) AS low_stock_lots,
                COALESCE(SUM(ls.quantity_total - ls.quantity_sold), 0) AS lot_quantity_left
             FROM lots l
             LEFT JOIN lot_stocks ls ON ls.lot_id = l.id
             WHERE l.is_active = 1'
        ) ?: ['total_lots' => 0, 'lots_with_stock' => 0, 'low_stock_lots' => 0, 'lot_quantity_left' => 0];

        Response::success([
            'month' => $month,
            'totals' => [
                'invoice_count' => (int)$invoiceSummary['invoice_count'],
                'customers_served' => (int)$invoiceSummary['customers_served'],
                'total_revenue' => (float)$invoiceSummary['total_revenue'],
                'total_paid' => $totalPaid,
                'total_due' => max(0, $totalDue),
            ],
            'lots' => [
                'total_lots' => (int)$lotSummary['total_lots'],
                'lots_with_stock' => (int)$lotSummary['lots_with_stock'],
                'low_stock_lots' => (int)$lotSummary['low_stock_lots'],
                'lot_quantity_left' => (float)$lotSummary['lot_quantity_left'],
            ],
        ]);
    }

    /** GET /analytics/top-products?month=YYYY-MM&limit=5 */
    public static function topProducts(Request $req): void
    {
        [$from, $to, $month] = self::resolveMonthRange($req->query('month'));

        $filters = sanitiseInput([
            'limit' => $req->query('limit', 5),
        ]);

        (new Validator())->validateOrFail($filters, [
            'limit' => 'nullable|integer|min:1|max:50',
        ]);

        $limit = (int)($filters['limit'] ?? 5);

        $rows = Database::fetchAll(
            'SELECT
                p.id AS product_id,
                p.name AS product_name,
                p.product_code,
                COALESCE(SUM(qi.quantity), 0) AS quantity_sold,
                COALESCE(SUM(qi.quantity * qi.unit_price), 0) AS revenue
             FROM sales_invoices si
             JOIN quotation_items qi ON qi.quotation_id = si.quotation_id
             JOIN variant_units vu ON vu.id = qi.variant_unit_id
             JOIN product_variants pv ON pv.id = vu.variant_id
             JOIN products p ON p.id = pv.product_id
             WHERE si.date >= ?
               AND si.date <= ?
               AND si.status = "active"
             GROUP BY p.id, p.name, p.product_code
             ORDER BY revenue DESC, quantity_sold DESC
             LIMIT ?',
            [$from, $to, $limit]
        );

        $rows = array_map(
            fn($r) => castRow($r, ['product_id'], ['quantity_sold', 'revenue']),
            $rows
        );

        Response::success([
            'month' => $month,
            'items' => $rows,
        ]);
    }

    /** GET /analytics/customer-monthly-sales?month=YYYY-MM&limit=20 */
    public static function customerMonthlySales(Request $req): void
    {
        [$from, $to, $month] = self::resolveMonthRange($req->query('month'));

        $filters = sanitiseInput([
            'limit' => $req->query('limit', 20),
        ]);

        (new Validator())->validateOrFail($filters, [
            'limit' => 'nullable|integer|min:1|max:200',
        ]);

        $limit = (int)($filters['limit'] ?? 20);

        $rows = Database::fetchAll(
            'SELECT
                c.id AS customer_id,
                c.name AS customer_name,
                c.type AS customer_type,
                COUNT(si.id) AS invoice_count,
                COALESCE(SUM(si.total_amount), 0) AS sold_amount,
                COALESCE(SUM(COALESCE(pay.paid, 0)), 0) AS paid_amount,
                COALESCE(SUM(si.total_amount - COALESCE(pay.paid, 0)), 0) AS due_amount
             FROM sales_invoices si
             JOIN customers c ON c.id = si.customer_id
             LEFT JOIN (
                SELECT p.invoice_id, SUM(p.amount_paid) AS paid
                FROM payments p
                GROUP BY p.invoice_id
             ) pay ON pay.invoice_id = si.id
             WHERE si.date >= ?
               AND si.date <= ?
               AND si.status = "active"
             GROUP BY c.id, c.name, c.type
             ORDER BY sold_amount DESC, due_amount DESC
             LIMIT ?',
            [$from, $to, $limit]
        );

        $rows = array_map(
            fn($r) => castRow($r, ['customer_id', 'invoice_count'], ['sold_amount', 'paid_amount', 'due_amount']),
            $rows
        );

        Response::success([
            'month' => $month,
            'items' => $rows,
        ]);
    }

    private static function resolveMonthRange(?string $monthInput): array
    {
        $month = trim((string)($monthInput ?? ''));
        if ($month === '') {
            $month = date('Y-m');
        }

        if (!preg_match('/^\\d{4}-(0[1-9]|1[0-2])$/', $month)) {
            Response::error('month must be in YYYY-MM format', 422);
        }

        $from = $month . '-01';
        $to = date('Y-m-t', strtotime($from));

        return [$from, $to, $month];
    }
}
