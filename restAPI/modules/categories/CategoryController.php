<?php
// ============================================================
// CategoryController
// ============================================================

class CategoryController
{
    /** GET /categories */
    public static function index(Request $req): void
    {
        $rows = Database::fetchAll('SELECT id, name, created_at FROM categories ORDER BY name ASC');
        Response::success(array_map(fn($r) => castRow($r, ['id']), $rows));
    }

    /** POST /categories */
    public static function store(Request $req): void
    {
        $data = sanitiseInput($req->all());
        (new Validator())->validateOrFail($data, ['name' => 'required|string|max:100']);

        if (Database::fetchScalar('SELECT COUNT(*) FROM categories WHERE name = ?', [$data['name']])) {
            Response::error('Category name already exists', 409);
        }

        Database::query('INSERT INTO categories (name) VALUES (?)', [$data['name']]);
        Response::created(['id' => (int)Database::lastInsertId()], 'Category created');
    }

    /** GET /categories/{id} */
    public static function show(Request $req): void
    {
        $row = Database::fetchOne(
            'SELECT id, name, created_at FROM categories WHERE id = ?',
            [$req->params['id']]
        );
        if (!$row) Response::notFound('Category not found');
        Response::success(castRow($row, ['id']));
    }

    /** PUT /categories/{id} */
    public static function update(Request $req): void
    {
        $data = sanitiseInput($req->all());
        (new Validator())->validateOrFail($data, ['name' => 'required|string|max:100']);

        $updated = Database::query(
            'UPDATE categories SET name = ? WHERE id = ?',
            [$data['name'], $req->params['id']]
        )->rowCount();

        if (!$updated) Response::notFound('Category not found');
        Response::success(null, 'Category updated');
    }

    /** DELETE /categories/{id} */
    public static function destroy(Request $req): void
    {
        $deleted = Database::query(
            'DELETE FROM categories WHERE id = ?',
            [$req->params['id']]
        )->rowCount();

        if (!$deleted) Response::notFound('Category not found');
        Response::noContent();
    }
}
