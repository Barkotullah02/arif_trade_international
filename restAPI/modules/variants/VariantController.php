<?php
// ============================================================
// VariantController – Product Variants CRUD
// ============================================================

class VariantController
{
    /** GET /products/{productId}/variants */
    public static function index(Request $req): void
    {
        $rows = Database::fetchAll(
            'SELECT id, product_id, attributes, sku, is_active, created_at
             FROM product_variants WHERE product_id = ? ORDER BY id',
            [$req->params['productId']]
        );

        $rows = array_map(function ($r) {
            $r['attributes'] = json_decode($r['attributes'], true);
            return castRow($r, ['id', 'product_id'], [], ['is_active']);
        }, $rows);

        Response::success($rows);
    }

    /** POST /products/{productId}/variants */
    public static function store(Request $req): void
    {
        $productId = (int)$req->params['productId'];
        if (!Database::fetchOne('SELECT id FROM products WHERE id = ?', [$productId])) {
            Response::notFound('Product not found');
        }

        $data = $req->all();
        (new Validator())->validateOrFail($data, [
            'attributes' => 'required|array',
            'sku'        => 'nullable|string|max:100',
        ]);

        // Check SKU uniqueness if provided
        if (!empty($data['sku'])) {
            if (Database::fetchScalar('SELECT COUNT(*) FROM product_variants WHERE sku = ?', [$data['sku']])) {
                Response::error('SKU already exists', 409);
            }
        }

        Database::query(
            'INSERT INTO product_variants (product_id, attributes, sku) VALUES (?, ?, ?)',
            [$productId, json_encode($data['attributes']), $data['sku'] ?? null]
        );

        Response::created(['id' => (int)Database::lastInsertId()], 'Variant created');
    }

    /** GET /variants/{id} */
    public static function show(Request $req): void
    {
        $variant = Database::fetchOne(
            'SELECT pv.id, pv.product_id, pv.attributes, pv.sku, pv.is_active,
                    pv.created_at, pv.updated_at,
                    p.name AS product_name, p.product_code
             FROM product_variants pv
             JOIN products p ON p.id = pv.product_id
             WHERE pv.id = ?',
            [$req->params['id']]
        );
        if (!$variant) Response::notFound('Variant not found');

        $variant['attributes'] = json_decode($variant['attributes'], true);
        $variant['units'] = Database::fetchAll(
            'SELECT vu.id, u.id AS unit_id, u.name AS unit_name, u.multiplier,
                    vu.stock_quantity, vu.unit_price
             FROM variant_units vu JOIN units u ON u.id = vu.unit_id
             WHERE vu.variant_id = ?',
            [$variant['id']]
        );
        $variant['units'] = array_map(
            fn($r) => castRow($r, ['id', 'unit_id'], ['multiplier', 'stock_quantity', 'unit_price']),
            $variant['units']
        );

        Response::success(castRow($variant, ['id', 'product_id'], [], ['is_active']));
    }

    /** PUT /variants/{id} */
    public static function update(Request $req): void
    {
        if (!Database::fetchOne('SELECT id FROM product_variants WHERE id = ?', [$req->params['id']])) {
            Response::notFound('Variant not found');
        }

        $data = $req->all();
        (new Validator())->validateOrFail($data, [
            'attributes' => 'nullable|array',
            'sku'        => 'nullable|string|max:100',
            'is_active'  => 'nullable|boolean',
        ]);

        $sets = []; $params = [];
        if (isset($data['attributes'])) { $sets[] = 'attributes = ?'; $params[] = json_encode($data['attributes']); }
        if (isset($data['sku']))        { $sets[] = 'sku = ?';        $params[] = $data['sku']; }
        if (isset($data['is_active']))  { $sets[] = 'is_active = ?';  $params[] = (int)(bool)$data['is_active']; }

        if (empty($sets)) Response::error('Nothing to update', 400);
        $params[] = $req->params['id'];
        Database::query('UPDATE product_variants SET ' . implode(', ', $sets) . ' WHERE id = ?', $params);
        Response::success(null, 'Variant updated');
    }

    /** DELETE /variants/{id} */
    public static function destroy(Request $req): void
    {
        $deleted = Database::query(
            'DELETE FROM product_variants WHERE id = ?',
            [$req->params['id']]
        )->rowCount();
        if (!$deleted) Response::notFound('Variant not found');
        Response::noContent();
    }
}
