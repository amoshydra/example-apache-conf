#!/bin/bash
set -e

echo "=== Apache Configuration Tests ==="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Counters
TOTAL=0
PASSED=0
FAILED=0

# Store test results for summary
SUMMARY_FILE="/tmp/test_summary.md"
echo "## Apache Configuration Test Report" > "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "**Timestamp:** $(date -u '+%Y-%m-%d %H:%M:%S UTC')" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "| # | Test | Status | Expected | Actual |" >> "$SUMMARY_FILE"
echo "|---|------|--------|----------|--------|" >> "$SUMMARY_FILE"

# Function to test HTTP status
test_status() {
    local url=$1
    local expected=$2
    local description=$3
    
    TOTAL=$((TOTAL + 1))
    
    status=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    
    if [ "$status" = "$expected" ]; then
        echo -e "${GREEN}✓ PASS${NC}: $description (got $status)"
        PASSED=$((PASSED + 1))
        echo "| $TOTAL | $description | ✅ PASS | $expected | $status |" >> "$SUMMARY_FILE"
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}: $description (expected $expected, got $status)"
        FAILED=$((FAILED + 1))
        echo "| $TOTAL | $description | ❌ FAIL | $expected | $status |" >> "$SUMMARY_FILE"
        return 1
    fi
}

# Test 1: Document root should serve content
echo ""
echo "--- Testing Document Root ---"
test_status "http://localhost:8080/" "200" "Document root serves index.html"

# Test 1b: Public directory should be accessible
test_status "http://localhost:8080/public/" "200" "Public directory is accessible"

# Test 1c: Admin directory should be denied
test_status "http://localhost:8080/admin/" "403" "Admin directory access is denied"

# Test 1d: Non-existent file should return 404
test_status "http://localhost:8080/nonexistent-file-12345.html" "404" "Non-existent file returns 404"

# Test 2: If-else block - admin mode should allow access
echo ""
echo "--- Testing If-Else Block ---"
test_status "http://localhost:8080/api?mode=admin" "404" "Admin mode allows access"

# Test 3: If-else block - without admin mode should deny access
test_status "http://localhost:8080/api" "403" "Non-admin mode denies access"

echo ""
echo "=== All tests completed ==="
echo "Total: $TOTAL, Passed: $PASSED, Failed: $FAILED"

# Write summary footer
echo "" >> "$SUMMARY_FILE"
echo "---" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
if [ $FAILED -eq 0 ]; then
    echo "## ✅ Result: $PASSED/$TOTAL tests passed" >> "$SUMMARY_FILE"
else
    echo "## ❌ Result: $PASSED/$TOTAL tests passed, $FAILED failed" >> "$SUMMARY_FILE"
fi

# Write to GitHub Step Summary if available
if [ -n "$GITHUB_STEP_SUMMARY" ]; then
    cat "$SUMMARY_FILE" >> "$GITHUB_STEP_SUMMARY"
    echo "Test report written to GitHub Step Summary"
fi

# Exit with error if any tests failed
if [ $FAILED -gt 0 ]; then
    exit 1
fi
