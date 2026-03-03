<?php
// ============================================================
// QuotationService – Transactional workflows
//   accept()   : deduct stock → log handover → create invoice
//   returnQuote(): restore stock → log returned → mark invoice returned
//   reject()   : status change only (no stock movement)
// ============================================================

class QuotationService
{
    // ── Accept ────────────────────────────────────────────────
    /**
     * @param int $quotationId
     * @param int $editorId
     * @param int $customerId   Editor selects/confirms the customer on acceptance
     * @throws RuntimeException
     */
    public static function accept(int $quotationId, int $editorId, int $customerId): array
    {
        // Validate customer exists
        if (!Database::fetchOne('SELECT id FROM customers WHERE id = ?', [$customerId])) {
            throw new RuntimeException('Customer not found', 404);
        }

        Database::beginTransaction();
        try {
            // Lock the quotation row
            $quote = Database::fetchOne(
                'SELECT * FROM quotation_requests WHERE id = ? FOR UPDATE',
                [$quotationId]
            );

            if (!$quote) {
                throw new RuntimeException('Quotation not found', 404);
            }
            if ($quote['status'] !== 'pending') {
                throw new RuntimeException("Cannot accept a quotation with status '{$quote['status']}'", 409);
            }

            // Load items
            $items = Database::fetchAll(
                'SELECT qi.id, qi.variant_unit_id, qi.quantity, qi.unit_price
                 FROM quotation_items qi WHERE qi.quotation_id = ?',
                [$quotationId]
            );
            if (empty($items)) {
                throw new RuntimeException('Quotation has no items', 422);
            }

            $totalAmount = 0.0;

            foreach ($items as $item) {
                // Lock + read stock row
                $vu = Database::fetchOne(
                    'SELECT id, stock_quantity FROM variant_units WHERE id = ? FOR UPDATE',
                    [$item['variant_unit_id']]
                );
                if (!$vu) {
                    throw new RuntimeException("Variant-unit #{$item['variant_unit_id']} not found", 404);
                }

                $newStock = $vu['stock_quantity'] - $item['quantity'];
                if ($newStock < 0) {
                    throw new RuntimeException(
                        "Insufficient stock for variant-unit #{$item['variant_unit_id']}. " .
                        "Available: {$vu['stock_quantity']}, Requested: {$item['quantity']}",
                        422
                    );
                }

                // Deduct stock
                Database::query(
                    'UPDATE variant_units SET stock_quantity = ? WHERE id = ?',
                    [$newStock, $vu['id']]
                );

                // Log handover
                Database::query(
                    'INSERT INTO inventory_log (variant_unit_id, quantity, action, related_id, user_id, note)
                     VALUES (?, ?, ?, ?, ?, ?)',
                    [$vu['id'], -$item['quantity'], 'handover', $quotationId, $editorId,
                     "Quotation #$quotationId accepted"]
                );

                $totalAmount += $item['quantity'] * $item['unit_price'];
            }

            // Update quotation status
            Database::query(
                'UPDATE quotation_requests
                 SET status = ?, editor_id = ?, customer_id = ?, processed_at = NOW()
                 WHERE id = ?',
                ['accepted', $editorId, $customerId, $quotationId]
            );

            // Create invoice
            Database::query(
                'INSERT INTO sales_invoices (quotation_id, customer_id, date, total_amount, created_by)
                 VALUES (?, ?, CURDATE(), ?, ?)',
                [$quotationId, $customerId, $totalAmount, $editorId]
            );
            $invoiceId = (int)Database::lastInsertId();

            Database::commit();

            return [
                'quotation_id' => $quotationId,
                'invoice_id'   => $invoiceId,
                'total_amount' => round($totalAmount, 2),
            ];
        } catch (Throwable $e) {
            Database::rollback();
            throw $e;
        }
    }

    // ── Return (physical post-acceptance return) ──────────────
    /**
     * @param int $quotationId
     * @param int $editorId
     * @throws RuntimeException
     */
    public static function returnQuote(int $quotationId, int $editorId): void
    {
        Database::beginTransaction();
        try {
            $quote = Database::fetchOne(
                'SELECT * FROM quotation_requests WHERE id = ? FOR UPDATE',
                [$quotationId]
            );

            if (!$quote) {
                throw new RuntimeException('Quotation not found', 404);
            }
            if ($quote['status'] !== 'accepted') {
                throw new RuntimeException("Can only return an accepted quotation; current status is '{$quote['status']}'", 409);
            }

            $items = Database::fetchAll(
                'SELECT variant_unit_id, quantity FROM quotation_items WHERE quotation_id = ?',
                [$quotationId]
            );

            foreach ($items as $item) {
                // Restore stock
                Database::query(
                    'UPDATE variant_units SET stock_quantity = stock_quantity + ? WHERE id = ?',
                    [$item['quantity'], $item['variant_unit_id']]
                );

                // Log returned
                Database::query(
                    'INSERT INTO inventory_log (variant_unit_id, quantity, action, related_id, user_id, note)
                     VALUES (?, ?, ?, ?, ?, ?)',
                    [$item['variant_unit_id'], $item['quantity'], 'returned', $quotationId, $editorId,
                     "Quotation #$quotationId returned"]
                );
            }

            // Update quotation
            Database::query(
                'UPDATE quotation_requests SET status = ?, editor_id = ?, processed_at = NOW() WHERE id = ?',
                ['returned', $editorId, $quotationId]
            );

            // Mark linked invoice as returned
            Database::query(
                'UPDATE sales_invoices SET status = ? WHERE quotation_id = ?',
                ['returned', $quotationId]
            );

            Database::commit();
        } catch (Throwable $e) {
            Database::rollback();
            throw $e;
        }
    }

    // ── Reject ────────────────────────────────────────────────
    public static function reject(int $quotationId, int $editorId): void
    {
        Database::beginTransaction();
        try {
            $quote = Database::fetchOne(
                'SELECT status FROM quotation_requests WHERE id = ? FOR UPDATE',
                [$quotationId]
            );
            if (!$quote) throw new RuntimeException('Quotation not found', 404);
            if ($quote['status'] !== 'pending') {
                throw new RuntimeException("Only pending quotations can be rejected; current status is '{$quote['status']}'", 409);
            }

            Database::query(
                'UPDATE quotation_requests SET status = ?, editor_id = ?, processed_at = NOW() WHERE id = ?',
                ['rejected', $editorId, $quotationId]
            );
            Database::commit();
        } catch (Throwable $e) {
            Database::rollback();
            throw $e;
        }
    }
}
