<?php
// ============================================================
// InventoryController – audit log with rich filters
// ============================================================

class InventoryController
{
    /**
     * GET /inventory/log
     * ?action=handover&variant_unit_id=3&product_id=5
     *  &from=2026-01-01&to=2026-12-31&user_id=2
     *  &page=1&per_page=50
     */
    public static function log(Request $req): void
    {
        $where  = ['1=1'];
        $params = [];

        if ($action = $req->query('action')) {
            $where[] = 'il.action = ?'; $params[] = $action;
        }
        if ($vu = $req->query('variant_unit_id')) {
            $where[] = 'il.variant_unit_id = ?'; $params[] = $vu;
        }
        if ($productId = $req->query('product_id')) {
            $where[] = 'p.id = ?'; $params[] = $productId;
        }
        if ($uid = $req->query('user_id')) {
            $where[] = 'il.user_id = ?'; $params[] = $uid;
        }
        if ($from = $req->query('from')) {
            $where[] = 'DATE(il.created_at) >= ?'; $params[] = $from;
        }
        if ($to = $req->query('to')) {
            $where[] = 'DATE(il.created_at) <= ?'; $params[] = $to;
        }

        $w   = implode(' AND ', $where);
        $sql = "SELECT il.id, il.variant_unit_id, il.quantity, il.action,
                       il.related_id, il.note, il.created_at,
                       u.name AS user_name, u.role AS user_role,
                       p.id AS product_id, p.name AS product_name, p.product_code,
                       un.name AS unit_name,
                       pv.attributes AS variant_attributes
                FROM inventory_log il
                LEFT JOIN users u            ON u.id  = il.user_id
                JOIN variant_units vu         ON vu.id = il.variant_unit_id
                JOIN units un                 ON un.id = vu.unit_id
                JOIN product_variants pv      ON pv.id = vu.variant_id
                JOIN products p               ON p.id  = pv.product_id
                WHERE $w
                ORDER BY il.created_at DESC";

        $result = paginate($sql, $params, (int)$req->query('page', 1), (int)$req->query('per_page', 50));

        $result['data'] = array_map(function ($r) {
            $r['variant_attributes'] = json_decode($r['variant_attributes'], true);
            return castRow($r, ['id', 'variant_unit_id', 'related_id', 'product_id'], ['quantity']);
        }, $result['data']);

        Response::success($result);
    }
}
