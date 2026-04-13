#!/usr/bin/env bats

load 'helper'

setup() {
    start_fixture "02-security-headers"
}

teardown() {
    stop_fixture
}

# ============================================
# Security Headers Tests
# ============================================

@test "02-security-headers: CSP header is present" {
    headers=$(http_get_headers "/")
    assert_header_contains "$headers" "Content-Security-Policy" "default-src 'self'"
}

@test "02-security-headers: X-Frame-Options is SAMEORIGIN" {
    headers=$(http_get_headers "/")
    assert_header_equals "$headers" "X-Frame-Options" "SAMEORIGIN"
}

@test "02-security-headers: X-Content-Type-Options is nosniff" {
    headers=$(http_get_headers "/")
    assert_header_equals "$headers" "X-Content-Type-Options" "nosniff"
}

@test "02-security-headers: X-XSS-Protection is enabled" {
    headers=$(http_get_headers "/")
    assert_header_contains "$headers" "X-XSS-Protection" "1; mode=block"
}

@test "02-security-headers: Referrer-Policy is set" {
    headers=$(http_get_headers "/")
    assert_header_equals "$headers" "Referrer-Policy" "strict-origin-when-cross-origin"
}

@test "02-security-headers: Permissions-Policy restricts features" {
    headers=$(http_get_headers "/")
    assert_header_contains "$headers" "Permissions-Policy" "geolocation=()"
    assert_header_contains "$headers" "Permissions-Policy" "camera=()"
    assert_header_contains "$headers" "Permissions-Policy" "microphone=()"
}

@test "02-security-headers: Strict-Transport-Security (HSTS) is set" {
    headers=$(http_get_headers "/")
    assert_header_contains "$headers" "Strict-Transport-Security" "max-age=31536000"
    assert_header_contains "$headers" "Strict-Transport-Security" "includeSubDomains"
}
