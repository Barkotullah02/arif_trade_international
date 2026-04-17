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
                $assignments = Database::fetchAll(
                    'SELECT la.id, la.lot_id, la.quantity, l.name AS lot_name
                     FROM lot_assignments la
                     JOIN lots l ON l.id = la.lot_id
                     WHERE la.quotation_item_id = ?
                     ORDER BY la.id',
                    [(int)$item['id']]
                );
                if (empty($assignments)) {
                    throw new RuntimeException(
                        "Lot assignments are required for quotation item #{$item['id']}",
                        422
                    );
                }

                $assignedQty = 0.0;
                foreach ($assignments as $assignment) {
                    $assignedQty += (float)$assignment['quantity'];
                }
                if (abs($assignedQty - (float)$item['quantity']) > 0.0001) {
                    throw new RuntimeException(
                        "Assigned lot quantities must equal item quantity for quotation item #{$item['id']}",
                        422
                    );
                }

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

                foreach ($assignments as $assignment) {
                    $stock = Database::fetchOne(
                        'SELECT ls.id, ls.quantity_total, ls.quantity_sold
                         FROM lot_stocks ls
                         JOIN lots l ON l.id = ls.lot_id
                         WHERE ls.lot_id = ? AND ls.variant_unit_id = ? AND l.is_active = 1
                         FOR UPDATE',
                        [(int)$assignment['lot_id'], (int)$item['variant_unit_id']]
                    );
                    if (!$stock) {
                        throw new RuntimeException(
                            "Lot #{$assignment['lot_id']} is not available for variant-unit #{$item['variant_unit_id']}",
                            422
                        );
                    }

                    $available = (float)$stock['quantity_total'] - (float)$stock['quantity_sold'];
                    if ($available + 0.0001 < (float)$assignment['quantity']) {
                        throw new RuntimeException(
                            "Insufficient lot stock for lot #{$assignment['lot_id']}. Available: {$available}, Requested: {$assignment['quantity']}",
                            422
                        );
                    }

                    Database::query(
                        'UPDATE lot_stocks SET quantity_sold = quantity_sold + ? WHERE id = ?',
                        [(float)$assignment['quantity'], (int)$stock['id']]
                    );

                    Database::query(
                        'INSERT INTO inventory_log (variant_unit_id, quantity, action, related_id, user_id, note)
                         VALUES (?, ?, ?, ?, ?, ?)',
                        [
                            (int)$item['variant_unit_id'],
                            -((float)$assignment['quantity']),
                            'sold',
                            $quotationId,
                            $editorId,
                            "Lot #{$assignment['lot_id']} ({$assignment['lot_name']}) sold via quotation #$quotationId",
                        ]
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
                'SELECT id, variant_unit_id, quantity FROM quotation_items WHERE quotation_id = ?',
                [$quotationId]
            );

            foreach ($items as $item) {
                $assignments = Database::fetchAll(
                    'SELECT la.lot_id, la.quantity
                     FROM lot_assignments la
                     WHERE la.quotation_item_id = ?',
                    [(int)$item['id']]
                );

                // Restore stock
                Database::query(
                    'UPDATE variant_units SET stock_quantity = stock_quantity + ? WHERE id = ?',
                    [$item['quantity'], $item['variant_unit_id']]
                );

                foreach ($assignments as $assignment) {
                    Database::query(
                        'UPDATE lot_stocks
                         SET quantity_sold = GREATEST(quantity_sold - ?, 0)
                         WHERE lot_id = ? AND variant_unit_id = ?',
                        [(float)$assignment['quantity'], (int)$assignment['lot_id'], (int)$item['variant_unit_id']]
                    );
                }

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
