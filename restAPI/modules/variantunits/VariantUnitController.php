<?php
// ============================================================
// VariantUnitController – links variants to units, tracks stock/price
// ============================================================

class VariantUnitController
{
    /** GET /variants/{variantId}/units */
    public static function index(Request $req): void
    {
        $rows = Database::fetchAll(
            'SELECT vu.id, vu.variant_id, u.id AS unit_id, u.name AS unit_name,
                    u.multiplier, vu.stock_quantity, vu.unit_price, vu.updated_at
             FROM variant_units vu
             JOIN units u ON u.id = vu.unit_id
             WHERE vu.variant_id = ?
             ORDER BY u.name',
            [$req->params['variantId']]
        );
        $rows = array_map(
            fn($r) => castRow($r, ['id', 'variant_id', 'unit_id'], ['multiplier', 'stock_quantity', 'unit_price']),
            $rows
        );
        Response::success($rows);
    }

    /** POST /variants/{variantId}/units */
    public static function store(Request $req): void
    {
        $variantId = (int)$req->params['variantId'];
        $variant = Database::fetchOne('SELECT id, product_id FROM product_variants WHERE id = ?', [$variantId]);
        if (!$variant) {
            Response::notFound('Variant not found');
        }

        $data = sanitiseInput($req->all());
        (new Validator())->validateOrFail($data, [
            'unit_id'        => 'required|integer',
            'unit_price'     => 'required|numeric|min:0',
            'stock_quantity' => 'nullable|numeric|min:0',
            'lot_id'         => 'nullable|integer',
            'lot_name'       => 'nullable|string|max:120',
            'lot_description'=> 'nullable|string|max:255',
        ]);

        if (!Database::fetchOne('SELECT id FROM units WHERE id = ?', [$data['unit_id']])) {
            Response::notFound('Unit not found');
        }

        // Check duplicate combo
        if (Database::fetchScalar(
            'SELECT COUNT(*) FROM variant_units WHERE variant_id = ? AND unit_id = ?',
            [$variantId, $data['unit_id']]
        )) {
            Response::error('This unit is already linked to the variant', 409);
        }

        $stockQty = (float)($data['stock_quantity'] ?? 0);

        Database::beginTransaction();
        try {
            Database::query(
                'INSERT INTO variant_units (variant_id, unit_id, stock_quantity, unit_price)
                 VALUES (?, ?, ?, ?)',
                [$variantId, $data['unit_id'], $stockQty, $data['unit_price']]
            );
            $vuId = (int)Database::lastInsertId();

            if ($stockQty > 0 && (isset($data['lot_id']) || !empty($data['lot_name']))) {
                $lotId = null;

                if (isset($data['lot_id'])) {
                    $lot = Database::fetchOne(
                        'SELECT id, product_id, is_active FROM lots WHERE id = ?',
                        [(int)$data['lot_id']]
                    );
                    if (!$lot || (int)$lot['product_id'] !== (int)$variant['product_id'] || !(bool)$lot['is_active']) {
                        Response::error('lot_id is invalid for this product', 422);
                    }
                    $lotId = (int)$lot['id'];
                } else {
                    if (Database::fetchScalar(
                        'SELECT COUNT(*) FROM lots WHERE product_id = ? AND name = ?',
                        [(int)$variant['product_id'], $data['lot_name']]
                    )) {
                        Response::error('lot_name already exists for this product', 409);
                    }
                    Database::query(
                        'INSERT INTO lots (product_id, name, description, created_by) VALUES (?, ?, ?, ?)',
                        [(int)$variant['product_id'], $data['lot_name'], $data['lot_description'] ?? null, (int)$req->user['sub']]
                    );
                    $lotId = (int)Database::lastInsertId();
                }

                $existing = Database::fetchOne(
                    'SELECT id FROM lot_stocks WHERE lot_id = ? AND variant_unit_id = ?',
                    [$lotId, $vuId]
                );
                if ($existing) {
                    Database::query(
                        'UPDATE lot_stocks SET quantity_total = quantity_total + ? WHERE id = ?',
                        [$stockQty, (int)$existing['id']]
                    );
                } else {
                    Database::query(
                        'INSERT INTO lot_stocks (lot_id, variant_unit_id, quantity_total, quantity_sold)
                         VALUES (?, ?, ?, 0)',
                        [$lotId, $vuId, $stockQty]
                    );
                }
            }

            Database::commit();
            Response::created(['id' => $vuId], 'Variant-unit created');
        } catch (Throwable $e) {
            Database::rollback();
            throw $e;
        }
    }

    /** GET /variant-units/{id} */
    public static function show(Request $req): void
    {
        $row = Database::fetchOne(
            'SELECT vu.id, vu.variant_id, vu.unit_id, u.name AS unit_name,
                    u.multiplier, vu.stock_quantity, vu.unit_price, vu.updated_at
             FROM variant_units vu
             JOIN units u ON u.id = vu.unit_id
             WHERE vu.id = ?',
            [$req->params['id']]
        );
        if (!$row) Response::notFound('Variant-unit not found');
        Response::success(castRow($row, ['id', 'variant_id', 'unit_id'], ['multiplier', 'stock_quantity', 'unit_price']));
    }

    /** PUT /variant-units/{id} – update stock or price */
    public static function update(Request $req): void
    {
        $vu = Database::fetchOne('SELECT id FROM variant_units WHERE id = ?', [$req->params['id']]);
        if (!$vu) Response::notFound('Variant-unit not found');

        $data = $req->all();
        (new Validator())->validateOrFail($data, [
            'unit_price'     => 'nullable|numeric|min:0',
            'stock_quantity' => 'nullable|numeric|min:0',
        ]);

        $sets = []; $params = [];
        if (isset($data['unit_price']))     { $sets[] = 'unit_price = ?';     $params[] = $data['unit_price']; }
        if (isset($data['stock_quantity'])) { $sets[] = 'stock_quantity = ?'; $params[] = $data['stock_quantity']; }

        if (empty($sets)) Response::error('Nothing to update', 400);
        $params[] = $req->params['id'];
        Database::query('UPDATE variant_units SET ' . implode(', ', $sets) . ' WHERE id = ?', $params);
        Response::success(null, 'Variant-unit updated');
    }

    /** DELETE /variant-units/{id} */
    public static function destroy(Request $req): void
    {
        // Block deletion if referenced in quotation items or inventory
        $inUse = Database::fetchScalar(
            'SELECT COUNT(*) FROM quotation_items WHERE variant_unit_id = ?',
            [$req->params['id']]
        );
        if ($inUse) Response::error('Variant-unit has quotation items and cannot be deleted', 409);

        $deleted = Database::query(
            'DELETE FROM variant_units WHERE id = ?',
            [$req->params['id']]
        )->rowCount();
        if (!$deleted) Response::notFound('Variant-unit not found');
        Response::noContent();
    }
}
