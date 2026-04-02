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

h "1) Auth"
check "login superadmin" POST "/auth/login" '{"email":"admin@ati.local","password":"Admin@1234"}' 200 ""
AUTH=$(printf '%s' "$LAST_BODY" | json_get "data.token")
if [[ -z "$AUTH" ]]; then
  echo "Superadmin token missing; aborting tests."
  exit 1
fi

VIEWER_EMAIL="apitestviewer.${TAG}@ati.local"
check "create viewer user" POST "/users" "{\"name\":\"API Test Viewer\",\"email\":\"$VIEWER_EMAIL\",\"password\":\"Viewer@1234\",\"role\":\"viewer\"}" 201
VIEWER_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
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

check "create product" POST "/products" "{\"name\":\"$PRODUCT_NAME\",\"category_id\":$CAT_ID}" 201
PROD_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")

check "create unit" POST "/units" "{\"name\":\"$UNIT_NAME\",\"multiplier\":1}" 201
UNIT_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")

check "create variant" POST "/products/$PROD_ID/variants" "{\"sku\":\"$VARIANT_SKU\",\"attributes\":{\"pack\":\"single\"}}" 201
VAR_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")

check "create variant-unit" POST "/variants/$VAR_ID/units" "{\"unit_id\":$UNIT_ID,\"unit_price\":120,\"stock_quantity\":100}" 201
VU_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")

check "create customer" POST "/customers" "{\"name\":\"API Test Customer\",\"type\":\"general\",\"email\":\"$CUSTOMER_EMAIL\"}" 201
CUST_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")

h "3) Quotations CRUD success"
check "list quotations" GET "/quotations" "" 200
check "create quotation" POST "/quotations" "{\"customer_id\":$CUST_ID,\"note\":\"Q1\",\"items\":[{\"variant_unit_id\":$VU_ID,\"quantity\":2}]}" 201
QID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "show quotation" GET "/quotations/$QID" "" 200
check "update quotation" PUT "/quotations/$QID" '{"note":"Q1 updated"}' 200

h "4) Quotations failure cases"
check "viewer cannot list quotations" GET "/quotations" "" 403 "$VIEWER_AUTH"
check "create quotation invalid payload" POST "/quotations" '{"note":"bad"}' 422
check "update accepted quotation should fail" PUT "/quotations/$QID/status" "{\"status\":\"accepted\",\"customer_id\":$CUST_ID}" 200
INV_ID=$(printf '%s' "$LAST_BODY" | json_get "data.invoice_id")
check "cannot update accepted quotation" PUT "/quotations/$QID" '{"note":"blocked"}' 409
check "cannot delete accepted quotation" DELETE "/quotations/$QID" "" 409

check "create second quotation for delete" POST "/quotations" "{\"customer_id\":$CUST_ID,\"note\":\"Q2\",\"items\":[{\"variant_unit_id\":$VU_ID,\"quantity\":1}]}" 201
Q2_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "delete pending quotation" DELETE "/quotations/$Q2_ID" "" 204

h "5) Invoices CRUD success"
check "list invoices" GET "/invoices" "" 200
check "show invoice" GET "/invoices/$INV_ID" "" 200
check "update invoice" PUT "/invoices/$INV_ID" '{"status":"active"}' 200

check "create standalone invoice" POST "/quotations" "{\"customer_id\":$CUST_ID,\"note\":\"Q3\",\"items\":[{\"variant_unit_id\":$VU_ID,\"quantity\":1}]}" 201
Q3_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "create invoice" POST "/invoices" "{\"quotation_id\":$Q3_ID,\"customer_id\":$CUST_ID,\"date\":\"2026-03-28\",\"total_amount\":120}" 201
INV2_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "delete invoice without payments" DELETE "/invoices/$INV2_ID" "" 204

h "6) Invoices failure cases"
check "viewer cannot list invoices" GET "/invoices" "" 403 "$VIEWER_AUTH"
check "create invoice invalid payload" POST "/invoices" '{"customer_id":1}' 422
check "create duplicate invoice for quotation" POST "/invoices" "{\"quotation_id\":$Q3_ID,\"customer_id\":$CUST_ID,\"date\":\"2026-03-28\",\"total_amount\":120}" 201
INV3_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "duplicate invoice conflict" POST "/invoices" "{\"quotation_id\":$Q3_ID,\"customer_id\":$CUST_ID,\"date\":\"2026-03-28\",\"total_amount\":120}" 409

h "7) Payments CRUD success"
check "list payments by invoice" GET "/invoices/$INV_ID/payments" "" 200
check "create payment" POST "/invoices/$INV_ID/payments" '{"amount_paid":50,"payment_date":"2026-03-28","method":"cash"}' 201
PAY_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "show payment" GET "/payments/$PAY_ID" "" 200
check "update payment" PUT "/payments/$PAY_ID" '{"amount_paid":45,"reference":"PAY-UPDATED"}' 200
check "delete payment" DELETE "/payments/$PAY_ID" "" 204

h "8) Payments failure cases"
check "viewer cannot create payment" POST "/invoices/$INV_ID/payments" '{"amount_paid":1,"payment_date":"2026-03-28"}' 403 "$VIEWER_AUTH"
check "create payment invalid payload" POST "/invoices/$INV_ID/payments" '{"amount_paid":-1}' 422
check "show missing payment" GET "/payments/99999999" "" 404

h "9) Inventory CRUD success"
check "list inventory log" GET "/inventory/log" "" 200
check "create inventory log" POST "/inventory" "{\"variant_unit_id\":$VU_ID,\"quantity\":1,\"action\":\"returned\",\"note\":\"manual correction\"}" 201
ILOG_ID=$(printf '%s' "$LAST_BODY" | json_get "data.id")
check "show inventory log" GET "/inventory/$ILOG_ID" "" 200
check "update inventory log" PUT "/inventory/$ILOG_ID" '{"note":"manual correction updated"}' 200
check "delete inventory log" DELETE "/inventory/$ILOG_ID" "" 204

h "10) Inventory failure cases"
check "viewer cannot list inventory log" GET "/inventory/log" "" 403 "$VIEWER_AUTH"
check "create inventory log invalid action" POST "/inventory" "{\"variant_unit_id\":$VU_ID,\"quantity\":1,\"action\":\"bad\"}" 422
check "show missing inventory log" GET "/inventory/99999999" "" 404

h "11) Authorization and unauthenticated checks"
check "unauthenticated quotations list" GET "/quotations" "" 401 ""
check "unauthenticated invoices list" GET "/invoices" "" 401 ""
check "unauthenticated payments show" GET "/payments/1" "" 401 ""
check "unauthenticated inventory list" GET "/inventory/log" "" 401 ""

h "12) Cleanup"
if [[ -n "${INV3_ID:-}" ]]; then
  request DELETE "$BASE/invoices/$INV3_ID" "" "$AUTH" >/dev/null
fi
request DELETE "$BASE/quotations/$Q3_ID" "" "$AUTH" >/dev/null
request DELETE "$BASE/customers/$CUST_ID" "" "$AUTH" >/dev/null
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
