<?php
// ============================================================
// UnitController – Units CRUD
// ============================================================

class UnitController
{
    /** GET /units */
    public static function index(Request $req): void
    {
        $rows = Database::fetchAll('SELECT id, name, multiplier, created_at FROM units ORDER BY name');
        Response::success(array_map(fn($r) => castRow($r, ['id'], ['multiplier']), $rows));
    }

    /** POST /units */
    public static function store(Request $req): void
    {
        $data = sanitiseInput($req->all());
        (new Validator())->validateOrFail($data, [
            'name'       => 'required|string|max:100',
            'multiplier' => 'required|numeric|min:0.0001',
        ]);

        if (Database::fetchScalar('SELECT COUNT(*) FROM units WHERE name = ?', [$data['name']])) {
            Response::error('Unit name already exists', 409);
        }

        Database::query(
            'INSERT INTO units (name, multiplier) VALUES (?, ?)',
            [$data['name'], $data['multiplier']]
        );
        Response::created(['id' => (int)Database::lastInsertId()], 'Unit created');
    }

    /** GET /units/{id} */
    public static function show(Request $req): void
    {
        $row = Database::fetchOne(
            'SELECT id, name, multiplier, created_at FROM units WHERE id = ?',
            [$req->params['id']]
        );
        if (!$row) Response::notFound('Unit not found');
        Response::success(castRow($row, ['id'], ['multiplier']));
    }

    /** PUT /units/{id} */
    public static function update(Request $req): void
    {
        $data = sanitiseInput($req->all());
        (new Validator())->validateOrFail($data, [
            'name'       => 'nullable|string|max:100',
            'multiplier' => 'nullable|numeric|min:0.0001',
        ]);

        $sets = []; $params = [];
        if (isset($data['name']))       { $sets[] = 'name = ?';       $params[] = $data['name']; }
        if (isset($data['multiplier'])) { $sets[] = 'multiplier = ?'; $params[] = $data['multiplier']; }

        if (empty($sets)) Response::error('Nothing to update', 400);
        $params[] = $req->params['id'];

        $updated = Database::query('UPDATE units SET ' . implode(', ', $sets) . ' WHERE id = ?', $params)->rowCount();
        if (!$updated) Response::notFound('Unit not found');
        Response::success(null, 'Unit updated');
    }

    /** DELETE /units/{id} */
    public static function destroy(Request $req): void
    {
        // Prevent deleting units in use
        $inUse = Database::fetchScalar('SELECT COUNT(*) FROM variant_units WHERE unit_id = ?', [$req->params['id']]);
        if ($inUse) Response::error('Unit is linked to variants and cannot be deleted', 409);

        $deleted = Database::query('DELETE FROM units WHERE id = ?', [$req->params['id']])->rowCount();
        if (!$deleted) Response::notFound('Unit not found');
        Response::noContent();
    }
}
