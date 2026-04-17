#!/usr/bin/env bash
set -u

BASE="${BASE:-http://localhost/arif_trade_international/restAPI}"
TAG="$(date +%s)"
PASS=0
FAIL=0
ERRORS=()
AUTH=""
VIEWER_AUTH=""
LAST_BODY=''

h() { echo; echo "━━━ $1 ━━━"; }

json_get() {
  local expr="$1"
  python3 -c '
import json,sys
expr = sys.argv[1]
try:
  data = json.loads(sys.stdin.read())
except Exception:
  print("")
  raise SystemExit(0)
node = data
for key in expr.split("."):
  if not key:
    continue
  if isinstance(node, dict):
    node = node.get(key)
  else:
    node = None
    break
print("" if node is None else node)
' "$expr"
}

request() {
  local method="$1" url="$2" data="$3" token="$4"
  local args=(-s -o /tmp/ati_body -w "%{http_code}" -X "$method" -H "Accept: application/json")
  if [[ -n "$token" ]]; then
    args+=(-H "Authorization: Bearer $token")
  fi
  if [[ -n "$data" ]]; then
    args+=(-H "Content-Type: application/json" -d "$data")
  fi
  curl "${args[@]}" "$url"
}

check() {
  local label="$1" method="$2" path="$3" data="$4" expect="$5"
  local token
  if [[ $# -ge 6 ]]; then
    token="$6"
  else
    token="$AUTH"
  fi
  local status
  status=$(request "$method" "$BASE$path" "$data" "$token")
  LAST_BODY=$(cat /tmp/ati_body)
  if [[ "$status" == "$expect" ]]; then
    echo "  ✅ [$status] $label"
    PASS=$((PASS + 1))
  else
    echo "  ❌ [$status vs $expect] $label"
    echo "     body: $(echo "$LAST_BODY" | head -c 260)"
    FAIL=$((FAIL + 1))
    ERRORS+=("$label [got $status, want $expect]")
  fi
}

cleanup_test_users() {
  check "cleanup viewer user" POST "/auth/login" '{"email":"admin@ati.local","password":"Admin@1234"}' 200 ""
  local admin_token
  admin_token=$(printf '%s' "$LAST_BODY" | json_get "data.token")
  if [[ -n "$admin_token" ]]; then
    local users_status
    users_status=$(request GET "$BASE/users?search=apitestviewer" "" "$admin_token")
    local users_body
    users_body=$(cat /tmp/ati_body)
    if [[ "$users_status" == "200" ]]; then
      local vid
      vid=$(printf '%s' "$users_body" | python3 - <<'PY'
import json,sys
try:
    d=json.loads(sys.stdin.read())
    rows=((d.get('data') or {}).get('data') or [])
    for r in rows:
        if r.get('email')=='apitestviewer@ati.local':
            print(r.get('id',''))
            break
except Exception:
    pass
PY
)
      if [[ -n "$vid" ]]; then
        request DELETE "$BASE/users/$vid" "" "$admin_token" >/dev/null
      fi
    fi
  fi
}

h "0) Public endpoints"
check "health endpoint" GET "/health" "" 200 ""
check "api spec endpoint" GET "/spec" "" 200 ""
check "api spec endpoint with query" GET "/spec?search=invoice" "" 200 ""

h "1) Auth"
check "login superadmin" POST "/auth/login" '{"email":"admin@ati.local","password":"Admin@1234"}' 200 ""
AUTH=$(printf '%s' "$LAST_BODY" | json_get "data.token")
if [[ -z "$AUTH" ]]; then
  echo "Superadmin token missing; aborting tests."
  exit 1
fi
check "refresh token superadmin" POST "/auth/refresh" "" 200

VIEWER_EMAIL="apitestviewer.${TAG}@ati.local"
check "create viewer user" POST "/users" "{\"name\":\"API Test Viewer\",\"email\":\"$VIEWER_EMAIL\",\"password\":\"Viewer@1234\",\"role\":\"viewer\"}" 201
VIEWER_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "show viewer user" GET "/users/$VIEWER_ID" "" 200
check "show missing user" GET "/users/99999999" "" 404
TEMP_USER_EMAIL="apitesttempuser.${TAG}@ati.local"
check "create temp user" POST "/users" "{\"name\":\"API Temp User\",\"email\":\"$TEMP_USER_EMAIL\",\"password\":\"TempUser@1234\",\"role\":\"salesman\"}" 201
TEMP_USER_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "update temp user" PUT "/users/$TEMP_USER_ID" '{"name":"API Temp User Updated","role":"editor","is_active":false}' 200
check "delete temp user" DELETE "/users/$TEMP_USER_ID" "" 204
check "login viewer" POST "/auth/login" "{\"email\":\"$VIEWER_EMAIL\",\"password\":\"Viewer@1234\"}" 200 ""
VIEWER_AUTH=$(printf '%s' "$LAST_BODY" | json_get "data.token")

h "2) Create prerequisite data"
CATEGORY_NAME="API Test Category ${TAG}"
PRODUCT_NAME="API Test Product ${TAG}"
UNIT_NAME="API Test Unit ${TAG}"
VARIANT_SKU="API-TEST-SKU-${TAG}"
CUSTOMER_EMAIL="api-test-customer.${TAG}@ati.local"

check "create category" POST "/categories" "{\"name\":\"$CATEGORY_NAME\"}" 201
CAT_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "show category" GET "/categories/$CAT_ID" "" 200
check "show missing category" GET "/categories/99999999" "" 404

TEMP_CATEGORY_NAME="API Temp Category ${TAG}"
check "create temp category" POST "/categories" "{\"name\":\"$TEMP_CATEGORY_NAME\"}" 201
TEMP_CAT_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "update temp category" PUT "/categories/$TEMP_CAT_ID" "{\"name\":\"$TEMP_CATEGORY_NAME Updated\"}" 200
check "delete temp category" DELETE "/categories/$TEMP_CAT_ID" "" 204

check "create product" POST "/products" "{\"name\":\"$PRODUCT_NAME\",\"category_id\":$CAT_ID}" 201
PROD_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "update product expiry" PUT "/products/$PROD_ID" '{"expiry_date":"2026-07-10"}' 200
check "show missing product" GET "/products/99999999" "" 404

TEMP_PRODUCT_NAME="API Temp Product ${TAG}"
check "create temp product" POST "/products" "{\"name\":\"$TEMP_PRODUCT_NAME\",\"category_id\":$CAT_ID}" 201
TEMP_PROD_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "delete temp product" DELETE "/products/$TEMP_PROD_ID" "" 204

TEMP_UNIT_NAME="API Temp Unit ${TAG}"
check "create temp unit" POST "/units" "{\"name\":\"$TEMP_UNIT_NAME\",\"multiplier\":2}" 201
TEMP_UNIT_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "update temp unit" PUT "/units/$TEMP_UNIT_ID" "{\"name\":\"$TEMP_UNIT_NAME Updated\",\"multiplier\":2.5}" 200
check "delete temp unit" DELETE "/units/$TEMP_UNIT_ID" "" 204

check "create unit" POST "/units" "{\"name\":\"$UNIT_NAME\",\"multiplier\":1}" 201
UNIT_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "show unit" GET "/units/$UNIT_ID" "" 200
check "show missing unit" GET "/units/99999999" "" 404

check "create variant" POST "/products/$PROD_ID/variants" "{\"sku\":\"$VARIANT_SKU\",\"attributes\":{\"pack\":\"single\"}}" 201
VAR_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "list variants by product" GET "/products/$PROD_ID/variants" "" 200
check "show variant" GET "/variants/$VAR_ID" "" 200
check "show missing variant" GET "/variants/99999999" "" 404

check "create variant-unit" POST "/variants/$VAR_ID/units" "{\"unit_id\":$UNIT_ID,\"unit_price\":120,\"stock_quantity\":100}" 201
VU_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "list variant-units by variant" GET "/variants/$VAR_ID/units" "" 200
check "show variant-unit" GET "/variant-units/$VU_ID" "" 200
check "show missing variant-unit" GET "/variant-units/99999999" "" 404

LOT_NAME="API-LOT-${TAG}"
check "create lot" POST "/lots" "{\"product_id\":$PROD_ID,\"name\":\"$LOT_NAME\",\"description\":\"primary lot\"}" 201
LOT_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
SECOND_LOT_NAME="API-LOT-SECOND-${TAG}"
check "create second lot" POST "/lots" "{\"product_id\":$PROD_ID,\"name\":\"$SECOND_LOT_NAME\",\"description\":\"secondary lot\",\"expiry_date\":\"2026-06-20\"}" 201
LOT2_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "update lot" PUT "/lots/$LOT2_ID" '{"description":"secondary lot updated"}' 200
check "archive lot" DELETE "/lots/$LOT2_ID" "" 200
check "add lot stock" POST "/lots/$LOT_ID/stocks" "{\"variant_unit_id\":$VU_ID,\"quantity_total\":100}" 201
check "update lot expiry" PUT "/lots/$LOT_ID" '{"expiry_date":"2026-07-15"}' 200
check "show lot" GET "/lots/$LOT_ID" "" 200
check "show missing lot" GET "/lots/99999999" "" 404
check "lot autocomplete" GET "/lots/autocomplete?product_id=$PROD_ID&variant_unit_id=$VU_ID&search=API-LOT" "" 200
check "lot stats" GET "/lots/stats?lot_id=$LOT_ID" "" 200
check "lot expiring soon" GET "/lots/expiring-soon?days=120" "" 200
check "lot expiring soon invalid days" GET "/lots/expiring-soon?days=999" "" 422

h "2.1) Analytics"
MONTH_NOW="$(date +%Y-%m)"
check "analytics summary" GET "/analytics/summary?month=$MONTH_NOW" "" 200
check "analytics top products" GET "/analytics/top-products?month=$MONTH_NOW&limit=5" "" 200
check "analytics customer monthly sales" GET "/analytics/customer-monthly-sales?month=$MONTH_NOW&limit=10" "" 200
check "analytics top products invalid limit" GET "/analytics/top-products?month=$MONTH_NOW&limit=999" "" 422
check "analytics month validation" GET "/analytics/summary?month=2026-13" "" 422
check "viewer cannot read analytics" GET "/analytics/summary" "" 403 "$VIEWER_AUTH"

check "create customer" POST "/customers" "{\"name\":\"API Test Customer\",\"type\":\"general\",\"email\":\"$CUSTOMER_EMAIL\"}" 201
CUST_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "show customer" GET "/customers/$CUST_ID" "" 200
check "show missing customer" GET "/customers/99999999" "" 404
TEMP_CUSTOMER_EMAIL="api-temp-customer.${TAG}@ati.local"
check "create temp customer" POST "/customers" "{\"name\":\"API Temp Customer\",\"type\":\"general\",\"email\":\"$TEMP_CUSTOMER_EMAIL\"}" 201
TEMP_CUST_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "update temp customer" PUT "/customers/$TEMP_CUST_ID" '{"name":"API Temp Customer Updated","phone":"01700000000"}' 200
check "delete temp customer" DELETE "/customers/$TEMP_CUST_ID" "" 204
check "customer ledger" GET "/customers/$CUST_ID/ledger" "" 200
check "customer ledger month filter" GET "/customers/$CUST_ID/ledger?month=$MONTH_NOW&status=active" "" 200
check "customer ledger invalid month" GET "/customers/$CUST_ID/ledger?month=2026-13" "" 422
check "viewer cannot view customer ledger" GET "/customers/$CUST_ID/ledger" "" 403 "$VIEWER_AUTH"

h "3) Quotations CRUD success"
check "list quotations" GET "/quotations" "" 200
check "list quotations with status filter" GET "/quotations?status=pending" "" 200
check "create quotation" POST "/quotations" "{\"customer_id\":$CUST_ID,\"note\":\"Q1\",\"items\":[{\"variant_unit_id\":$VU_ID,\"quantity\":2,\"lots\":[{\"lot_id\":$LOT_ID,\"quantity\":2}]}]}" 201
QID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "show quotation" GET "/quotations/$QID" "" 200
check "update quotation" PUT "/quotations/$QID" "{\"note\":\"Q1 updated\",\"items\":[{\"variant_unit_id\":$VU_ID,\"quantity\":2,\"lots\":[{\"lot_id\":$LOT_ID,\"quantity\":2}]}]}" 200

h "4) Quotations failure cases"
check "viewer cannot list quotations" GET "/quotations" "" 403 "$VIEWER_AUTH"
check "viewer cannot update quotation status" PUT "/quotations/$QID/status" "{\"status\":\"rejected\"}" 403 "$VIEWER_AUTH"
check "show missing quotation" GET "/quotations/99999999" "" 404
check "create quotation invalid payload" POST "/quotations" '{"note":"bad"}' 422
check "update accepted quotation should fail" PUT "/quotations/$QID/status" "{\"status\":\"accepted\",\"customer_id\":$CUST_ID}" 200
INV_ID=$(printf '%s' "$LAST_BODY" | json_get "data.invoice_id")
check "cannot update accepted quotation" PUT "/quotations/$QID" '{"note":"blocked"}' 409
check "cannot delete accepted quotation" DELETE "/quotations/$QID" "" 409

check "create second quotation for delete" POST "/quotations" "{\"customer_id\":$CUST_ID,\"note\":\"Q2\",\"items\":[{\"variant_unit_id\":$VU_ID,\"quantity\":1,\"lots\":[{\"lot_id\":$LOT_ID,\"quantity\":1}]}]}" 201
Q2_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "delete pending quotation" DELETE "/quotations/$Q2_ID" "" 204

check "create quotation without lots" POST "/quotations" "{\"customer_id\":$CUST_ID,\"note\":\"Q-no-lots\",\"items\":[{\"variant_unit_id\":$VU_ID,\"quantity\":1}]}" 201
Q_NOLOTS_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "accept requires lot assignments" PUT "/quotations/$Q_NOLOTS_ID/status" "{\"status\":\"accepted\",\"customer_id\":$CUST_ID}" 422
check "show quotation without lots" GET "/quotations/$Q_NOLOTS_ID" "" 200
Q_NOLOTS_ITEM_ID=$(printf '%s' "$LAST_BODY" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d["data"]["items"][0]["id"])')
check "assign lots via endpoint" POST "/quotations/$Q_NOLOTS_ID/lot-assignments" "{\"assignments\":[{\"quotation_item_id\":$Q_NOLOTS_ITEM_ID,\"lots\":[{\"lot_id\":$LOT_ID,\"quantity\":1}]}]}" 200

h "5) Invoices CRUD success"
check "list invoices" GET "/invoices" "" 200
check "list invoices with filters" GET "/invoices?status=active&customer_id=$CUST_ID" "" 200
check "list due invoices" GET "/invoices/due" "" 200
check "list due invoices with search" GET "/invoices/due?search=API%20Test&from=2026-01-01&to=2026-12-31" "" 200
check "list due invoices invalid per_page" GET "/invoices/due?per_page=999" "" 422
check "show invoice" GET "/invoices/$INV_ID" "" 200
check "update invoice" PUT "/invoices/$INV_ID" '{"status":"active"}' 200

check "create standalone invoice" POST "/quotations" "{\"customer_id\":$CUST_ID,\"note\":\"Q3\",\"items\":[{\"variant_unit_id\":$VU_ID,\"quantity\":1,\"lots\":[{\"lot_id\":$LOT_ID,\"quantity\":1}]}]}" 201
Q3_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "create invoice" POST "/invoices" "{\"quotation_id\":$Q3_ID,\"customer_id\":$CUST_ID,\"date\":\"2026-03-28\",\"total_amount\":120}" 201
INV2_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "delete invoice without payments" DELETE "/invoices/$INV2_ID" "" 204

h "6) Invoices failure cases"
check "viewer cannot list invoices" GET "/invoices" "" 403 "$VIEWER_AUTH"
check "viewer cannot list due invoices" GET "/invoices/due" "" 403 "$VIEWER_AUTH"
check "show missing invoice" GET "/invoices/99999999" "" 404
check "create invoice invalid payload" POST "/invoices" '{"customer_id":1}' 422
check "create duplicate invoice for quotation" POST "/invoices" "{\"quotation_id\":$Q3_ID,\"customer_id\":$CUST_ID,\"date\":\"2026-03-28\",\"total_amount\":120}" 201
INV3_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "duplicate invoice conflict" POST "/invoices" "{\"quotation_id\":$Q3_ID,\"customer_id\":$CUST_ID,\"date\":\"2026-03-28\",\"total_amount\":120}" 409

h "7) Payments CRUD success"
check "list payments by invoice" GET "/invoices/$INV_ID/payments" "" 200
check "create payment" POST "/invoices/$INV_ID/payments" '{"amount_paid":50,"payment_date":"2026-03-28","method":"cash"}' 201
PAY_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "cannot delete invoice with payment" DELETE "/invoices/$INV_ID" "" 409
check "show payment" GET "/payments/$PAY_ID" "" 200
check "update payment" PUT "/payments/$PAY_ID" '{"amount_paid":45,"reference":"PAY-UPDATED"}' 200
check "show payment after update" GET "/payments/$PAY_ID" "" 200
check "delete payment" DELETE "/payments/$PAY_ID" "" 204

h "8) Payments failure cases"
check "viewer cannot create payment" POST "/invoices/$INV_ID/payments" '{"amount_paid":1,"payment_date":"2026-03-28"}' 403 "$VIEWER_AUTH"
check "viewer cannot list payments by invoice" GET "/invoices/$INV_ID/payments" "" 403 "$VIEWER_AUTH"
check "create payment invalid payload" POST "/invoices/$INV_ID/payments" '{"amount_paid":-1}' 422
check "show missing payment" GET "/payments/99999999" "" 404

h "9) Inventory CRUD success"
check "list inventory log" GET "/inventory/log" "" 200
check "list inventory with action filter" GET "/inventory/log?action=returned&from=2026-01-01&to=2026-12-31" "" 200
check "create inventory log" POST "/inventory" "{\"variant_unit_id\":$VU_ID,\"quantity\":1,\"action\":\"returned\",\"note\":\"manual correction\"}" 201
ILOG_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "show inventory log" GET "/inventory/$ILOG_ID" "" 200
check "update inventory log" PUT "/inventory/$ILOG_ID" '{"note":"manual correction updated"}' 200
check "show inventory log after update" GET "/inventory/$ILOG_ID" "" 200
check "delete inventory log" DELETE "/inventory/$ILOG_ID" "" 204

h "10) Inventory failure cases"
check "viewer cannot list inventory log" GET "/inventory/log" "" 403 "$VIEWER_AUTH"
check "create inventory log invalid action" POST "/inventory" "{\"variant_unit_id\":$VU_ID,\"quantity\":1,\"action\":\"bad\"}" 422
check "show missing inventory log" GET "/inventory/99999999" "" 404

h "11) Authorization and unauthenticated checks"
check "unauthenticated quotations list" GET "/quotations" "" 401 ""
check "unauthenticated invoices list" GET "/invoices" "" 401 ""
check "unauthenticated due invoices list" GET "/invoices/due" "" 401 ""
check "unauthenticated payments show" GET "/payments/1" "" 401 ""
check "unauthenticated payments by invoice" GET "/invoices/$INV_ID/payments" "" 401 ""
check "unauthenticated inventory list" GET "/inventory/log" "" 401 ""
check "unauthenticated analytics summary" GET "/analytics/summary" "" 401 ""
check "unauthenticated customer ledger" GET "/customers/$CUST_ID/ledger" "" 401 ""

h "12) Cleanup"
if [[ -n "${INV3_ID:-}" ]]; then
  request DELETE "$BASE/invoices/$INV3_ID" "" "$AUTH" >/dev/null
fi
request DELETE "$BASE/quotations/$Q3_ID" "" "$AUTH" >/dev/null
request DELETE "$BASE/quotations/$Q_NOLOTS_ID" "" "$AUTH" >/dev/null
request DELETE "$BASE/customers/$CUST_ID" "" "$AUTH" >/dev/null
request DELETE "$BASE/lots/$LOT_ID" "" "$AUTH" >/dev/null
request DELETE "$BASE/variant-units/$VU_ID" "" "$AUTH" >/dev/null
request DELETE "$BASE/variants/$VAR_ID" "" "$AUTH" >/dev/null
request DELETE "$BASE/units/$UNIT_ID" "" "$AUTH" >/dev/null
request DELETE "$BASE/products/$PROD_ID" "" "$AUTH" >/dev/null
request DELETE "$BASE/categories/$CAT_ID" "" "$AUTH" >/dev/null
if [[ -n "${VIEWER_ID:-}" ]]; then
  request DELETE "$BASE/users/$VIEWER_ID" "" "$AUTH" >/dev/null
fi

if [[ ${#ERRORS[@]} -gt 0 ]]; then
  echo
  echo "Failures:"
  for e in "${ERRORS[@]}"; do
    echo " - $e"
  done
fi

echo
echo "══════════════════════════════════════════"
echo "RESULTS: PASSED=$PASS FAILED=$FAIL"
echo "══════════════════════════════════════════"

[[ $FAIL -eq 0 ]]
