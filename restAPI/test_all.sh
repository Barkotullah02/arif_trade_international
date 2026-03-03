#!/usr/bin/env bash
# ============================================================
#  ATI REST API – Full endpoint smoke-test
# ============================================================
BASE="http://localhost/arif_trade_international/restAPI"
PASS=0; FAIL=0; ERRORS=()

# ── helpers ──────────────────────────────────────────────────
H() { echo; echo "━━━ $1 ━━━"; }
check() {
  local label="$1" method="$2" url="$3" data="$4" expect_status="$5"
  local args=(-s -o /tmp/ati_body -w "%{http_code}" -X "$method")
  [[ -n "$AUTH"  ]] && args+=(-H "Authorization: Bearer $AUTH")
  args+=(-H "Content-Type: application/json")
  [[ -n "$data"  ]] && args+=(-d "$data")
  local status
  status=$(curl "${args[@]}" "$url")
  local body; body=$(cat /tmp/ati_body)
  local success; success=$(echo "$body" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('success','?'))" 2>/dev/null)
  if [[ "$status" == "$expect_status" ]]; then
    echo "  ✅  [$status] $label"
    PASS=$((PASS+1))
  else
    echo "  ❌  [$status vs $expect_status] $label"
    echo "       body: $(echo "$body" | head -c 200)"
    FAIL=$((FAIL+1))
    ERRORS+=("$label  [got $status, want $expect_status]")
  fi
  # export last body for ID extraction
  export LAST_BODY="$body"
}
jq_id() { echo "$LAST_BODY" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data']['id'])" 2>/dev/null; }
jq_key() { local k="$1"; echo "$LAST_BODY" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data']['$k'])" 2>/dev/null; }

# ════════════════════════════════════════════════════════════
H "1. SYSTEM"
AUTH=""
check "GET /health"   GET  "$BASE/health"   ""  200
check "GET /spec"     GET  "$BASE/spec"      ""  200

# ════════════════════════════════════════════════════════════
H "2. AUTH"
check "POST /auth/login (valid)"         POST "$BASE/auth/login"   '{"email":"admin@ati.local","password":"Admin@1234"}' 200
AUTH=$(echo "$LAST_BODY" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['token'])" 2>/dev/null)
echo "  🔑 Token acquired"

check "POST /auth/login (bad password)"  POST "$BASE/auth/login"   '{"email":"admin@ati.local","password":"wrong"}' 401
check "GET  /auth/me"                    GET  "$BASE/auth/me"       ""  200
check "POST /auth/refresh"               POST "$BASE/auth/refresh"  ""  200

# ════════════════════════════════════════════════════════════
H "3. USERS"
check "GET  /users"          GET  "$BASE/users"  ""  200
check "POST /users (create)" POST "$BASE/users"  '{"name":"Test User","email":"testuser@ati.local","password":"Test@1234","role":"viewer"}' 201
UID=$(jq_id)
echo "  → Created user id=$UID"
check "GET  /users/$UID"     GET  "$BASE/users/$UID"  ""  200
check "PUT  /users/$UID"     PUT  "$BASE/users/$UID"  '{"name":"Test User Updated","role":"editor"}' 200
check "DELETE /users/$UID"   DELETE "$BASE/users/$UID" "" 200

# ════════════════════════════════════════════════════════════
H "4. CATEGORIES"
check "GET  /categories"         GET  "$BASE/categories"  ""  200
check "POST /categories"         POST "$BASE/categories"  '{"name":"Test Category","description":"Test desc"}' 201
CAT_ID=$(jq_id)
echo "  → Created category id=$CAT_ID"
check "GET  /categories/$CAT_ID" GET  "$BASE/categories/$CAT_ID" "" 200
check "PUT  /categories/$CAT_ID" PUT  "$BASE/categories/$CAT_ID" '{"name":"Test Category Updated"}' 200
# Don't delete yet – need it for product

# ════════════════════════════════════════════════════════════
H "5. PRODUCTS"
check "GET  /products"           GET  "$BASE/products"   ""  200
check "POST /products"           POST "$BASE/products"   "{\"name\":\"Test Product\",\"category_id\":$CAT_ID,\"description\":\"Test Prod\"}" 201
PROD_ID=$(jq_id)
echo "  → Created product id=$PROD_ID"
check "GET  /products/$PROD_ID"  GET  "$BASE/products/$PROD_ID"  "" 200
check "PUT  /products/$PROD_ID"  PUT  "$BASE/products/$PROD_ID"  '{"name":"Test Product Updated"}' 200

# ════════════════════════════════════════════════════════════
H "6. PRODUCT VARIANTS"
check "GET  /products/$PROD_ID/variants" GET "$BASE/products/$PROD_ID/variants" "" 200
check "POST /variants" POST "$BASE/variants" \
  "{\"product_id\":$PROD_ID,\"name\":\"Standard\",\"sku\":\"TEST-SKU-001\",\"unit_price\":\"100.00\",\"attributes\":{}}" 201
VAR_ID=$(jq_id)
echo "  → Created variant id=$VAR_ID"
check "GET  /variants/$VAR_ID"   GET  "$BASE/variants/$VAR_ID"   "" 200
check "PUT  /variants/$VAR_ID"   PUT  "$BASE/variants/$VAR_ID"   '{"unit_price":"120.00"}' 200

# ════════════════════════════════════════════════════════════
H "7. UNITS"
check "GET  /units"              GET  "$BASE/units"   ""  200
check "POST /units"              POST "$BASE/units"   '{"name":"Test Pack","multiplier":5}' 201
UNIT_ID=$(jq_id)
echo "  → Created unit id=$UNIT_ID"
check "GET  /units/$UNIT_ID"     GET  "$BASE/units/$UNIT_ID"   "" 200
check "PUT  /units/$UNIT_ID"     PUT  "$BASE/units/$UNIT_ID"   '{"name":"Test Pack Updated"}' 200

# ════════════════════════════════════════════════════════════
H "8. VARIANT-UNITS (stock & pricing)"
check "GET  /variants/$VAR_ID/units"   GET  "$BASE/variants/$VAR_ID/units"   ""  200
check "POST /variant-units"            POST "$BASE/variant-units"  \
  "{\"variant_id\":$VAR_ID,\"unit_id\":$UNIT_ID,\"stock\":50,\"price_override\":null}" 201
VU_ID=$(jq_id)
echo "  → Created variant-unit id=$VU_ID"
check "GET  /variant-units/$VU_ID"  GET  "$BASE/variant-units/$VU_ID"  "" 200
check "PUT  /variant-units/$VU_ID"  PUT  "$BASE/variant-units/$VU_ID"  '{"stock":60}' 200

# ════════════════════════════════════════════════════════════
H "9. CUSTOMERS"
check "GET  /customers"          GET  "$BASE/customers"  ""  200
check "POST /customers"          POST "$BASE/customers"  \
  '{"name":"Test Customer","email":"cust@test.com","phone":"03001234567","address":"Test Address"}' 201
CUST_ID=$(jq_id)
echo "  → Created customer id=$CUST_ID"
check "GET  /customers/$CUST_ID" GET  "$BASE/customers/$CUST_ID" "" 200
check "PUT  /customers/$CUST_ID" PUT  "$BASE/customers/$CUST_ID" '{"name":"Test Customer Updated"}' 200

# ════════════════════════════════════════════════════════════
H "10. QUOTATION REQUESTS"
check "GET  /quotations"         GET  "$BASE/quotations"  ""  200
check "POST /quotations"         POST "$BASE/quotations"  \
  "{\"customer_id\":$CUST_ID,\"notes\":\"Test quotation\",\"items\":[{\"variant_unit_id\":$VU_ID,\"quantity\":2,\"unit_price\":\"100.00\"}]}" 201
QUOT_ID=$(jq_id)
echo "  → Created quotation id=$QUOT_ID"
check "GET  /quotations/$QUOT_ID"   GET "$BASE/quotations/$QUOT_ID"   "" 200
check "PUT  /quotations/$QUOT_ID"   PUT "$BASE/quotations/$QUOT_ID"   '{"notes":"Updated notes"}' 200
check "POST /quotations/$QUOT_ID/accept"  POST "$BASE/quotations/$QUOT_ID/accept"  "" 200
INV_ID=$(echo "$LAST_BODY" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['invoice_id'])" 2>/dev/null)
echo "  → Accepted quotation, invoice id=$INV_ID"

# Create another quotation for reject test
check "POST /quotations (for reject)" POST "$BASE/quotations" \
  "{\"customer_id\":$CUST_ID,\"notes\":\"Reject test\",\"items\":[{\"variant_unit_id\":$VU_ID,\"quantity\":1,\"unit_price\":\"100.00\"}]}" 201
QUOT2_ID=$(jq_id)
check "POST /quotations/$QUOT2_ID/reject" POST "$BASE/quotations/$QUOT2_ID/reject" '{"reason":"Price too high"}' 200

# ════════════════════════════════════════════════════════════
H "11. INVOICES"
check "GET  /invoices"              GET "$BASE/invoices"          ""  200
check "GET  /invoices/$INV_ID"      GET "$BASE/invoices/$INV_ID"  ""  200

# ════════════════════════════════════════════════════════════
H "12. PAYMENTS"
check "GET  /invoices/$INV_ID/payments"   GET "$BASE/invoices/$INV_ID/payments" ""  200
check "POST /payments"  POST "$BASE/payments" \
  "{\"invoice_id\":$INV_ID,\"amount\":\"100.00\",\"method\":\"cash\",\"reference\":\"PAY-001\",\"notes\":\"Test payment\"}" 201
PAY_ID=$(jq_id)
echo "  → Created payment id=$PAY_ID"
check "GET  /payments/$PAY_ID"      GET "$BASE/payments/$PAY_ID"   ""  200

# ════════════════════════════════════════════════════════════
H "13. INVENTORY LOG"
check "GET  /inventory"             GET "$BASE/inventory"          ""  200
check "GET  /inventory?variant_id=$VAR_ID" GET "$BASE/inventory?variant_id=$VAR_ID" "" 200

# ════════════════════════════════════════════════════════════
H "14. QUOTATION RETURN (cleanup test)"
check "POST /quotations/$QUOT_ID/return" POST "$BASE/quotations/$QUOT_ID/return" '{"reason":"Customer returned goods"}' 200

# ════════════════════════════════════════════════════════════
H "15. CLEANUP (delete test data)"
check "DELETE /variant-units/$VU_ID"  DELETE "$BASE/variant-units/$VU_ID"  "" 200
check "DELETE /units/$UNIT_ID"        DELETE "$BASE/units/$UNIT_ID"        "" 200
check "DELETE /variants/$VAR_ID"      DELETE "$BASE/variants/$VAR_ID"      "" 200
check "DELETE /products/$PROD_ID"     DELETE "$BASE/products/$PROD_ID"     "" 200
check "DELETE /categories/$CAT_ID"    DELETE "$BASE/categories/$CAT_ID"    "" 200
check "DELETE /customers/$CUST_ID"    DELETE "$BASE/customers/$CUST_ID"    "" 200

# ════════════════════════════════════════════════════════════
echo
echo "══════════════════════════════════════════"
echo "  RESULTS:  ✅ PASSED=$PASS   ❌ FAILED=$FAIL"
echo "══════════════════════════════════════════"
if [[ ${#ERRORS[@]} -gt 0 ]]; then
  echo "  Failures:"
  for e in "${ERRORS[@]}"; do echo "    • $e"; done
fi
