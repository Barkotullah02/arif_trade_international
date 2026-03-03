<?php
// ============================================================
// UserController – CRUD for system users (superadmin only)
// ============================================================

class UserController
{
    /** GET /users  ?page=1&per_page=20&role=salesman */
    public static function index(Request $req): void
    {
        $where  = '1=1';
        $params = [];

        if ($role = $req->query('role')) {
            $where   .= ' AND role = ?';
            $params[] = $role;
        }

        $sql    = "SELECT id, name, email, role, is_active, created_at FROM users WHERE $where ORDER BY id DESC";
        $result = paginate($sql, $params, (int)$req->query('page', 1), (int)$req->query('per_page', 20));

        $result['data'] = array_map(
            fn($r) => castRow($r, ['id'], [], ['is_active']),
            $result['data']
        );
        Response::success($result);
    }

    /** POST /users */
    public static function store(Request $req): void
    {
        $data = sanitiseInput($req->all());
        $v    = new Validator();
        $v->validateOrFail($data, [
            'name'     => 'required|string|max:150',
            'email'    => 'required|email|max:150',
            'password' => 'required|string|min:8',
            'role'     => 'required|in:superadmin,editor,viewer,salesman',
        ]);

        // Check duplicate email
        if (Database::fetchScalar('SELECT COUNT(*) FROM users WHERE email = ?', [$data['email']])) {
            Response::error('Email already registered', 409);
        }

        $hash = password_hash($data['password'], PASSWORD_BCRYPT, ['cost' => 12]);

        Database::query(
            'INSERT INTO users (name, email, password_hash, role) VALUES (?, ?, ?, ?)',
            [$data['name'], $data['email'], $hash, $data['role']]
        );

        Response::created(['id' => (int)Database::lastInsertId()], 'User created');
    }

    /** GET /users/{id} */
    public static function show(Request $req): void
    {
        $user = Database::fetchOne(
            'SELECT id, name, email, role, is_active, created_at, updated_at FROM users WHERE id = ?',
            [$req->params['id']]
        );
        if (!$user) Response::notFound('User not found');

        Response::success(castRow($user, ['id'], [], ['is_active']));
    }

    /** PUT /users/{id} */
    public static function update(Request $req): void
    {
        $user = Database::fetchOne('SELECT id FROM users WHERE id = ?', [$req->params['id']]);
        if (!$user) Response::notFound('User not found');

        $data = sanitiseInput($req->all());
        $v    = new Validator();
        $v->validateOrFail($data, [
            'name'      => 'nullable|string|max:150',
            'email'     => 'nullable|email|max:150',
            'password'  => 'nullable|string|min:8',
            'role'      => 'nullable|in:superadmin,editor,viewer,salesman',
            'is_active' => 'nullable|boolean',
        ]);

        $sets   = [];
        $params = [];

        if (isset($data['name']))      { $sets[] = 'name = ?';          $params[] = $data['name']; }
        if (isset($data['email']))     { $sets[] = 'email = ?';         $params[] = $data['email']; }
        if (isset($data['role']))      { $sets[] = 'role = ?';          $params[] = $data['role']; }
        if (isset($data['is_active'])) { $sets[] = 'is_active = ?';     $params[] = (int)(bool)$data['is_active']; }
        if (!empty($data['password'])) {
            $sets[]   = 'password_hash = ?';
            $params[] = password_hash($data['password'], PASSWORD_BCRYPT, ['cost' => 12]);
        }

        if (empty($sets)) Response::error('Nothing to update', 400);

        $params[] = $req->params['id'];
        Database::query('UPDATE users SET ' . implode(', ', $sets) . ' WHERE id = ?', $params);

        Response::success(null, 'User updated');
    }

    /** DELETE /users/{id} */
    public static function destroy(Request $req): void
    {
        $userId = (int)$req->params['id'];

        // Prevent self-deletion
        if ($userId === (int)$req->user['sub']) {
            Response::error('Cannot delete your own account', 400);
        }

        $deleted = Database::query('DELETE FROM users WHERE id = ?', [$userId])->rowCount();
        if (!$deleted) Response::notFound('User not found');

        Response::noContent();
    }
}
