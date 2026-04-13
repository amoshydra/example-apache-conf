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
# The global Header always set directive at the end overrides
# all the carefully configured cache headers.
# 
# These tests document the EXPECTED (incorrect) behavior,
# not the desired behavior. This demonstrates how Apache
# directive ordering and 'always' can corrupt configurations.
# ============================================

@test "03-cache-conflict: React index.html - global override applies" {
    headers=$(http_get_headers "/react-web/")
    
    # Due to the global 'always' directive, we get no-store instead of no-cache
    assert_header_contains "$headers" "Cache-Control" "no-store"
    
    # Document the conflict: immutable should NOT be present
    # (this would be present if the location block worked)
    run bash -c "echo '$headers' | grep -i 'immutable' || true"
    echo "Note: 'immutable' directive is missing due to global override"
}

@test "03-cache-conflict: React hashed JS - global override applies" {
    headers=$(http_get_headers "/react-web/static/js/main.a3f2b1c.js")
    
    # The global directive overrides the long-term cache
    assert_header_contains "$headers" "Cache-Control" "no-store"
    assert_header_not_contains "$headers" "Cache-Control" "immutable"
    
    echo "Note: JS bundles should have max-age=31536000,immutable but get no-store instead"
}

@test "03-cache-conflict: Angular index.html - global override applies" {
    headers=$(http_get_headers "/angular-web/")
    
    # Both get no-store now, losing the fine-grained control
    assert_header_contains "$headers" "Cache-Control" "no-store"
}

@test "03-cache-conflict: Angular main bundle - global override applies" {
    headers=$(http_get_headers "/angular-web/main.abc123.js")
    
    assert_header_contains "$headers" "Cache-Control" "no-store"
    assert_header_not_contains "$headers" "Cache-Control" "max-age=31536000"
    
    echo "Note: All cache headers are overridden by global 'always' directive"
}

@test "03-cache-conflict: All assets affected by global directive" {
    # Check various files - all should show the same corrupted behavior
    
    react_js=$(http_get_headers "/react-web/static/js/main.a3f2b1c.js")
    angular_css=$(http_get_headers "/angular-web/styles.def456.css")
    assets=$(http_get_headers "/angular-web/assets/config.json")
    
    # All should have the global no-store setting
    run bash -c "echo '$react_js' | grep -i 'Cache-Control:' | grep 'no-store'"
    [ "$status" -eq 0 ]
    
    run bash -c "echo '$angular_css' | grep -i 'Cache-Control:' | grep 'no-store'"
    [ "$status" -eq 0 ]
    
    run bash -c "echo '$assets' | grep -i 'Cache-Control:' | grep 'no-store'"
    [ "$status" -eq 0 ]
    
    echo "All file types are affected by the global Cache-Control override"
}
