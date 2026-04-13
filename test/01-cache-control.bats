#!/usr/bin/env bats

load 'helper'

setup() {
    start_fixture "01-cache-control"
}

teardown() {
    stop_fixture
}

# ============================================
# React App Tests
# ============================================

@test "01-cache-control: React index.html has no-cache headers" {
    headers=$(http_get_headers "/react-web/")
    assert_header_contains "$headers" "Cache-Control" "no-cache"
    assert_header_contains "$headers" "Cache-Control" "no-store"
    assert_header_contains "$headers" "Cache-Control" "must-revalidate"
}

@test "01-cache-control: React hashed JS has long-term cache" {
    headers=$(http_get_headers "/react-web/static/js/main.a3f2b1c.js")
    assert_header_contains "$headers" "Cache-Control" "max-age=31536000"
    assert_header_contains "$headers" "Cache-Control" "immutable"
}

@test "01-cache-control: React hashed CSS has long-term cache" {
    headers=$(http_get_headers "/react-web/static/css/main.e5d4c3b.css")
    assert_header_contains "$headers" "Cache-Control" "max-age=31536000"
    assert_header_contains "$headers" "Cache-Control" "immutable"
}

# ============================================
# Angular App Tests
# ============================================

@test "01-cache-control: Angular index.html has no-cache headers" {
    headers=$(http_get_headers "/angular-web/")
    assert_header_contains "$headers" "Cache-Control" "no-cache"
    assert_header_contains "$headers" "Cache-Control" "no-store"
    assert_header_contains "$headers" "Cache-Control" "must-revalidate"
}

@test "01-cache-control: Angular main bundle has long-term cache" {
    headers=$(http_get_headers "/angular-web/main.abc123.js")
    assert_header_contains "$headers" "Cache-Control" "max-age=31536000"
    assert_header_contains "$headers" "Cache-Control" "immutable"
}

@test "01-cache-control: Angular runtime bundle has long-term cache" {
    headers=$(http_get_headers "/angular-web/runtime.xyz789.js")
    assert_header_contains "$headers" "Cache-Control" "max-age=31536000"
}

@test "01-cache-control: Angular polyfills bundle has long-term cache" {
    headers=$(http_get_headers "/angular-web/polyfills.uvw456.js")
    assert_header_contains "$headers" "Cache-Control" "max-age=31536000"
}

@test "01-cache-control: Angular styles has long-term cache" {
    headers=$(http_get_headers "/angular-web/styles.def456.css")
    assert_header_contains "$headers" "Cache-Control" "max-age=31536000"
    assert_header_contains "$headers" "Cache-Control" "immutable"
}

@test "01-cache-control: Angular assets have short-term cache" {
    headers=$(http_get_headers "/angular-web/assets/logo.png")
    assert_header_contains "$headers" "Cache-Control" "max-age=86400"
    
    headers=$(http_get_headers "/angular-web/assets/config.json")
    assert_header_contains "$headers" "Cache-Control" "max-age=86400"
}
