#!/usr/bin/env python3
"""ATI REST API – full smoke test"""
import urllib.request, json, subprocess

# ─── Pre-test DB cleanup (remove stale records from previous runs) ───────────
def db(sql):
    r = subprocess.run(
        ["/Applications/XAMPP/xamppfiles/bin/mysql","-u","root","ati_db",
         "-e", f"SET FOREIGN_KEY_CHECKS=0; {sql}; SET FOREIGN_KEY_CHECKS=1"],
        capture_output=True, text=True
    )
    if r.returncode != 0:
        print(f"  [DB ERR] {r.stderr.strip()[:120]}")

print("Cleaning up stale test data…")
db("DELETE FROM users               WHERE email='tuser@ati.local'")
db("DELETE FROM inventory_log       WHERE variant_unit_id IN (SELECT id FROM variant_units WHERE variant_id IN (SELECT id FROM product_variants WHERE sku IN ('TST-001','TST-001-UP')))")
db("DELETE FROM variant_units       WHERE variant_id IN (SELECT id FROM product_variants WHERE sku IN ('TST-001','TST-001-UP'))")
db("DELETE FROM product_variants    WHERE sku IN ('TST-001','TST-001-UP')")
db("DELETE FROM quotation_items     WHERE quotation_id IN (SELECT id FROM quotation_requests WHERE customer_id IN (SELECT id FROM customers WHERE email='tc@test.com'))")
db("DELETE FROM quotation_requests  WHERE customer_id IN (SELECT id FROM customers WHERE email='tc@test.com')")
db("DELETE FROM payments            WHERE invoice_id IN (SELECT id FROM sales_invoices WHERE customer_id IN (SELECT id FROM customers WHERE email='tc@test.com'))")
db("DELETE FROM sales_invoices      WHERE customer_id IN (SELECT id FROM customers WHERE email='tc@test.com')")
db("DELETE FROM customers           WHERE email='tc@test.com'")
db("DELETE FROM products            WHERE name IN ('TestProd','TestProdUpdated')")
db("DELETE FROM units               WHERE name IN ('TestPack','TestPackUp')")
db("DELETE FROM categories          WHERE name IN ('TestCat','TestCatUp')")
print("Cleanup done.\n")

BASE  = "http://localhost/arif_trade_international/restAPI"
STATE = {"token": ""}
PASS  = 0
FAIL  = 0
ERRS  = []

def req(method, path, body=None, auth=True):
    url  = BASE + path
    data = json.dumps(body).encode() if body else None
    hdrs = {"Content-Type": "application/json", "Accept": "application/json"}
    if auth and STATE["token"]:
        hdrs["Authorization"] = f"Bearer {STATE['token']}"
    r = urllib.request.Request(url, data=data, headers=hdrs, method=method)
    try:
        with urllib.request.urlopen(r) as resp:
            body = resp.read()
            return resp.status, json.loads(body) if body.strip() else {}
    except urllib.error.HTTPError as e:
        body = e.read()
        return e.code, json.loads(body) if body.strip() else {}

def check(label, method, path, body, expect, auth=True):
    global PASS, FAIL
    status, resp = req(method, path, body, auth)
    ok = (status == expect)
    print(f"  {'OK ' if ok else 'FAIL'} [{status}] {label}")
    if not ok:
        print(f"       {json.dumps(resp)[:200]}")
        FAIL += 1
        ERRS.append(f"{label}  [got {status}, want {expect}]")
    else:
        PASS += 1
    return resp

def H(s): print(f"\n━━━ {s} ━━━")

# ──────────────────────────────────────────────────────────────
H("1. SYSTEM")
check("GET /health", "GET", "/health", None, 200, auth=False)
check("GET /spec",   "GET", "/spec",   None, 200, auth=False)

H("2. AUTH")
r = check("POST /auth/login (valid)", "POST", "/auth/login",
          {"email":"admin@ati.local","password":"Admin@1234"}, 200, auth=False)
STATE["token"] = r["data"]["token"]
print(f"  🔑 token acquired")
check("POST /auth/login (wrong password)", "POST", "/auth/login",
      {"email":"admin@ati.local","password":"wrongpassword"}, 401, auth=False)
check("POST /auth/login (invalid email)",  "POST", "/auth/login",
      {"email":"notvalid","password":"x"}, 422, auth=False)
check("GET  /auth/me",       "GET",  "/auth/me",      None, 200)
check("POST /auth/refresh",  "POST", "/auth/refresh", None, 200)

H("3. USERS")
check("GET /users", "GET", "/users", None, 200)
r    = check("POST /users", "POST", "/users",
             {"name":"TUser","email":"tuser@ati.local","password":"Test@1234","role":"viewer"}, 201)
uid  = r["data"]["id"]
print(f"  → user id={uid}")
check(f"GET /users/{uid}",    "GET",    f"/users/{uid}", None, 200)
check(f"PUT /users/{uid}",    "PUT",    f"/users/{uid}", {"name":"TUser Updated","role":"editor"}, 200)
check(f"DELETE /users/{uid}", "DELETE", f"/users/{uid}", None, 204)

H("4. CATEGORIES")
check("GET /categories", "GET", "/categories", None, 200)
r    = check("POST /categories", "POST", "/categories", {"name":"TestCat"}, 201)
cid  = r["data"]["id"]
print(f"  → cat id={cid}")
check(f"GET /categories/{cid}", "GET", f"/categories/{cid}", None, 200)
check(f"PUT /categories/{cid}", "PUT", f"/categories/{cid}", {"name":"TestCatUp"}, 200)

H("5. PRODUCTS")
check("GET /products", "GET", "/products", None, 200)
r    = check("POST /products", "POST", "/products", {"name":"TestProd","category_id":cid}, 201)
pid  = r["data"]["id"]
print(f"  → product id={pid}")
check(f"GET /products/{pid}", "GET", f"/products/{pid}", None, 200)
check(f"PUT /products/{pid}", "PUT", f"/products/{pid}", {"name":"TestProdUpdated"}, 200)

H("6. PRODUCT VARIANTS")
check(f"GET /products/{pid}/variants", "GET", f"/products/{pid}/variants", None, 200)
r    = check(f"POST /products/{pid}/variants", "POST", f"/products/{pid}/variants",
             {"sku":"TST-001","attributes":{"color":"red"}}, 201)
vid  = r["data"]["id"]
print(f"  → variant id={vid}")
check(f"GET /variants/{vid}", "GET", f"/variants/{vid}", None, 200)
check(f"PUT /variants/{vid}", "PUT", f"/variants/{vid}", {"sku":"TST-001-UP"}, 200)

H("7. UNITS")
check("GET /units", "GET", "/units", None, 200)
r    = check("POST /units", "POST", "/units", {"name":"TestPack","multiplier":5}, 201)
unid = r["data"]["id"]
print(f"  → unit id={unid}")
check(f"GET /units/{unid}", "GET", f"/units/{unid}", None, 200)
check(f"PUT /units/{unid}", "PUT", f"/units/{unid}", {"name":"TestPackUp"}, 200)

H("8. VARIANT-UNITS")
check(f"GET /variants/{vid}/units", "GET", f"/variants/{vid}/units", None, 200)
r    = check(f"POST /variants/{vid}/units", "POST", f"/variants/{vid}/units",
             {"unit_id":unid,"unit_price":"150.00","stock_quantity":50}, 201)
vuid = r["data"]["id"]
print(f"  → variant-unit id={vuid}")
check(f"GET /variant-units/{vuid}", "GET", f"/variant-units/{vuid}", None, 200)
check(f"PUT /variant-units/{vuid}", "PUT", f"/variant-units/{vuid}", {"stock_quantity":60}, 200)

H("9. CUSTOMERS")
check("GET /customers", "GET", "/customers", None, 200)
r     = check("POST /customers", "POST", "/customers",
              {"name":"TestCust","type":"pharmacy","phone":"03001234567",
               "email":"tc@test.com","address":"Test Address"}, 201)
cusid = r["data"]["id"]
print(f"  → customer id={cusid}")
check(f"GET /customers/{cusid}", "GET", f"/customers/{cusid}", None, 200)
check(f"PUT /customers/{cusid}", "PUT", f"/customers/{cusid}", {"name":"TestCustUpdated"}, 200)

H("10. QUOTATION REQUESTS")
check("GET /quotations", "GET", "/quotations", None, 200)
r    = check("POST /quotations", "POST", "/quotations",
             {"customer_id":cusid,"note":"Test quotation",
              "items":[{"variant_unit_id":vuid,"quantity":2}]}, 201)
qid  = r["data"]["id"]
print(f"  → quotation id={qid}")
check(f"GET /quotations/{qid}", "GET", f"/quotations/{qid}", None, 200)
r    = check(f"PUT /quotations/{qid}/status (accept)", "PUT", f"/quotations/{qid}/status",
             {"status":"accepted","customer_id":cusid}, 200)
invid = r["data"]["invoice_id"]
print(f"  → invoice id={invid}")

r2   = check("POST /quotations (for reject test)", "POST", "/quotations",
             {"customer_id":cusid,"note":"Reject me",
              "items":[{"variant_unit_id":vuid,"quantity":1}]}, 201)
qid2 = r2["data"]["id"]
check(f"PUT /quotations/{qid2}/status (reject)", "PUT", f"/quotations/{qid2}/status",
      {"status":"rejected"}, 200)

H("11. INVOICES")
check("GET /invoices",         "GET", "/invoices",          None, 200)
check(f"GET /invoices/{invid}","GET", f"/invoices/{invid}", None, 200)

H("12. PAYMENTS")
check(f"GET /invoices/{invid}/payments",  "GET", f"/invoices/{invid}/payments", None, 200)
r     = check(f"POST /invoices/{invid}/payments", "POST", f"/invoices/{invid}/payments",
              {"amount_paid":"100.00","payment_date":"2026-03-02","method":"cash","reference":"PAY-T01"}, 201)
payid = r["data"]["id"]
print(f"  → payment id={payid}")
check(f"GET /payments/{payid}", "GET", f"/payments/{payid}", None, 200)

H("13. INVENTORY LOG")
check("GET /inventory/log",                       "GET", "/inventory/log",                      None, 200)
check(f"GET /inventory/log?variant_id={vid}",     "GET", f"/inventory/log?variant_id={vid}",    None, 200)

H("14. QUOTATION RETURN")
check(f"PUT /quotations/{qid}/status (return)", "PUT", f"/quotations/{qid}/status",
      {"status":"returned"}, 200)

H("15. CLEANUP")
# Wipe child records via DB so API cascade deletes succeed
db(f"DELETE FROM inventory_log      WHERE variant_unit_id={vuid}")
db(f"DELETE FROM quotation_items    WHERE quotation_id IN (SELECT id FROM quotation_requests WHERE customer_id={cusid})")
db(f"DELETE FROM quotation_requests WHERE customer_id={cusid}")
db(f"DELETE FROM payments           WHERE invoice_id IN (SELECT id FROM sales_invoices WHERE customer_id={cusid})")
db(f"DELETE FROM sales_invoices     WHERE customer_id={cusid}")
check(f"DELETE /variant-units/{vuid}", "DELETE", f"/variant-units/{vuid}", None, 204)
check(f"DELETE /units/{unid}",         "DELETE", f"/units/{unid}",         None, 204)
check(f"DELETE /variants/{vid}",       "DELETE", f"/variants/{vid}",       None, 204)
check(f"DELETE /products/{pid}",       "DELETE", f"/products/{pid}",       None, 204)
check(f"DELETE /categories/{cid}",     "DELETE", f"/categories/{cid}",     None, 204)
check(f"DELETE /customers/{cusid}",    "DELETE", f"/customers/{cusid}",    None, 204)

# ──────────────────────────────────────────────────────────────
print(f"\n{'='*44}")
print(f"  RESULTS:  PASSED={PASS}   FAILED={FAIL}")
print(f"{'='*44}")
if ERRS:
    print("  Failures:")
    for e in ERRS:
        print(f"    • {e}")
