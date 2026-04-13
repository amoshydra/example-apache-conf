#!/usr/bin/env bats

load 'helper'

setup() {
    start_fixture "03-cache-conflict"
}

teardown() {
    stop_fixture
}

# ============================================
# Cache Conflict Demonstration
# 
# NOTE: This fixture intentionally has a misconfiguration.
# The global Header always set directive at the end ADDS headers
# rather than replacing them, resulting in DUPLICATE headers.
# 
# These tests document the EXPECTED (incorrect) behavior.
# ============================================

@test "03-cache-conflict: React index.html - global no-store header added" {
    headers=$(http_get_headers "/react-web/")
    
    # The global 'always' directive ADDS no-store header
    # This creates DUPLICATE Cache-Control headers
    assert_header_contains "$headers" "Cache-Control" "no-store"
    
    echo "Note: Duplicate headers present - both no-store and original cache headers"
}

@test "03-cache-conflict: React hashed JS - duplicate headers present" {
    headers=$(http_get_headers "/react-web/static/js/main.a3f2b1c.js")
    
    # Both headers are present - this is the problem!
    assert_header_contains "$headers" "Cache-Control" "no-store"
    assert_header_contains "$headers" "Cache-Control" "immutable"
    
    echo "Note: Conflicting directives - both no-store AND long-term cache headers present"
}

@test "03-cache-conflict: Angular index.html - global header added" {
    headers=$(http_get_headers "/angular-web/")
    
    # Global header is added to the response
    assert_header_contains "$headers" "Cache-Control" "no-store"
}

@test "03-cache-conflict: Angular main bundle - duplicate cache headers" {
    headers=$(http_get_headers "/angular-web/main.abc123.js")
    
    # Both conflicting headers are present
    assert_header_contains "$headers" "Cache-Control" "no-store"
    assert_header_contains "$headers" "Cache-Control" "max-age=31536000"
    
    echo "Note: Duplicate Cache-Control headers - browser behavior is undefined"
}

@test "03-cache-conflict: All assets have duplicate headers" {
    # Check various files - all should have the global header ADDED
    
    react_js=$(http_get_headers "/react-web/static/js/main.a3f2b1c.js")
    angular_css=$(http_get_headers "/angular-web/styles.def456.css")
    assets=$(http_get_headers "/angular-web/assets/config.json")
    
    # All should have the global no-store setting ADDED (not replaced)
    run bash -c "echo '$react_js' | grep -i 'Cache-Control:' | grep 'no-store'"
    [ "$status" -eq 0 ]
    
    run bash -c "echo '$angular_css' | grep -i 'Cache-Control:' | grep 'no-store'"
    [ "$status" -eq 0 ]
    
    run bash -c "echo '$assets' | grep -i 'Cache-Control:' | grep 'no-store'"
    [ "$status" -eq 0 ]
    
    echo "All file types have duplicate Cache-Control headers due to global directive"
}
