#!/bin/sh

echo "=== Testing Apache CSP Multi-Line Headers ==="
echo ""

RESP=$(curl -s -I http://localhost:8080/ 2>&1)

echo "--- Content-Security-Policy-1 (backslash continuation) ---"
echo "$RESP" | grep -i "content-security-policy-1" || echo "MISSING"

echo ""
echo "--- Content-Security-Policy-2 (multiple Header append) ---"
echo "$RESP" | grep -i "content-security-policy-2" || echo "MISSING"

echo ""
echo "--- Content-Security-Policy-3 (single-line control) ---"
echo "$RESP" | grep -i "content-security-policy-3" || echo "MISSING"

echo ""
echo "--- Content-Security-Policy-4 (backslash continuation, unquoted lines) ---"
echo "$RESP" | grep -i "content-security-policy-4" || echo "MISSING"

echo ""
echo "=== Full Response Headers ==="
echo "$RESP"
