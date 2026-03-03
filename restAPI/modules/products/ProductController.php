<?php
// ============================================================
// ProductController – Products CRUD with auto product_code
// ============================================================

class ProductController
{
    /**
     * GET /products
     * ?page=1&per_page=20&category_id=1&search=paracetamol&active=1
     */
    public static function index(Request $req): void
    {
        $where  = ['1=1'];
        $params = [];

        if ($cid = $req->query('category_id')) {
            $where[]  = 'p.category_id = ?';
            $params[] = $cid;
        }
        if ($search = $req->query('search')) {
            $where[]  = '(p.name LIKE ? OR p.product_code LIKE ?)';
            $params[] = "%$search%";
            $params[] = "%$search%";
        }
        if ($req->query('active') !== null) {
            $where[]  = 'p.is_active = ?';
            $params[] = (int)(bool)$req->query('active');
        }

        $w   = implode(' AND ', $where);
        $sql = "SELECT p.id, p.name, p.product_code, p.description, p.is_active,
                       p.created_at, c.id AS category_id, c.name AS category_name
                FROM products p
                LEFT JOIN categories c ON c.id = p.category_id
                WHERE $w
                ORDER BY p.id DESC";

        $result         = paginate($sql, $params, (int)$req->query('page', 1), (int)$req->query('per_page', 20));
        $result['data'] = array_map(fn($r) => castRow($r, ['id', 'category_id'], [], ['is_active']), $result['data']);
        Response::success($result);
    }

    /** POST /products */
    public static function store(Request $req): void
    {
        $data = sanitiseInput($req->all());
        (new Validator())->validateOrFail($data, [
            'name'        => 'required|string|max:200',
            'category_id' => 'nullable|integer',
            'description' => 'nullable|string',
        ]);

        $code = generateProductCode();

        Database::query(
            'INSERT INTO products (name, category_id, product_code, description) VALUES (?, ?, ?, ?)',
            [$data['name'], $data['category_id'] ?: null, $code, $data['description'] ?? null]
        );

        Response::created([
            'id'           => (int)Database::lastInsertId(),
            'product_code' => $code,
        ], 'Product created');
    }

    /**
     * GET /products/{id}
     * Returns product + variants + each variant's units/stock
     */
    public static function show(Request $req): void
    {
        $product = Database::fetchOne(
            'SELECT p.id, p.name, p.product_code, p.description, p.is_active,
                    p.created_at, p.updated_at,
                    c.id AS category_id, c.name AS category_name
             FROM products p
             LEFT JOIN categories c ON c.id = p.category_id
             WHERE p.id = ?',
            [$req->params['id']]
        );
        if (!$product) Response::notFound('Product not found');

        // Variants
        $variants = Database::fetchAll(
            'SELECT pv.id, pv.attributes, pv.sku, pv.is_active FROM product_variants pv WHERE pv.product_id = ?',
            [$product['id']]
        );

        foreach ($variants as &$variant) {
            $variant['attributes'] = json_decode($variant['attributes'], true);
            $variant['units']      = Database::fetchAll(
                'SELECT vu.id, u.id AS unit_id, u.name AS unit_name, u.multiplier,
                        vu.stock_quantity, vu.unit_price
                 FROM variant_units vu
                 JOIN units u ON u.id = vu.unit_id
                 WHERE vu.variant_id = ?',
                [$variant['id']]
            );
            $variant['units'] = array_map(
                fn($r) => castRow($r, ['id', 'unit_id'], ['multiplier', 'stock_quantity', 'unit_price']),
                $variant['units']
            );
        }

        $product             = castRow($product, ['id', 'category_id'], [], ['is_active']);
        $product['variants'] = $variants;
        Response::success($product);
    }

    /** PUT /products/{id} */
    public static function update(Request $req): void
    {
        if (!Database::fetchOne('SELECT id FROM products WHERE id = ?', [$req->params['id']])) {
            Response::notFound('Product not found');
        }

        $data = sanitiseInput($req->all());
        (new Validator())->validateOrFail($data, [
            'name'        => 'nullable|string|max:200',
            'category_id' => 'nullable|integer',
            'description' => 'nullable|string',
            'is_active'   => 'nullable|boolean',
        ]);

        $sets = []; $params = [];
        if (isset($data['name']))        { $sets[] = 'name = ?';        $params[] = $data['name']; }
        if (array_key_exists('category_id', $data)) { $sets[] = 'category_id = ?'; $params[] = $data['category_id'] ?: null; }
        if (isset($data['description'])) { $sets[] = 'description = ?'; $params[] = $data['description']; }
        if (isset($data['is_active']))   { $sets[] = 'is_active = ?';   $params[] = (int)(bool)$data['is_active']; }

        if (empty($sets)) Response::error('Nothing to update', 400);
        $params[] = $req->params['id'];
        Database::query('UPDATE products SET ' . implode(', ', $sets) . ' WHERE id = ?', $params);
        Response::success(null, 'Product updated');
    }

    /** DELETE /products/{id} */
    public static function destroy(Request $req): void
    {
        $deleted = Database::query('DELETE FROM products WHERE id = ?', [$req->params['id']])->rowCount();
        if (!$deleted) Response::notFound('Product not found');
        Response::noContent();
    }
}
