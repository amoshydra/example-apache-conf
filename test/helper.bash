#!/usr/bin/env bash

# BATS Helper for Apache Fixtures Testing
# Provides common functions for container management and HTTP assertions

# Fixture directory (set by test file)
FIXTURE_DIR=""
CONTAINER_NAME=""
BASE_URL="http://localhost:8080"

# Start the Apache container for a fixture
start_fixture() {
    local fixture_name="$1"
    FIXTURE_DIR="$BATS_TEST_DIRNAME/../fixtures/$fixture_name"
    CONTAINER_NAME="apache-test-$fixture_name"
    
    echo "Starting fixture: $fixture_name"
    
    # Build image if needed
    podman build -t "$CONTAINER_NAME" -f - "$FIXTURE_DIR" << 'EOF'
FROM docker.io/library/httpd:2.4
RUN rm -f /usr/local/apache2/conf/httpd.conf /usr/local/apache2/conf/extra/*.conf
COPY conf/httpd.conf /usr/local/apache2/conf/httpd.conf
COPY htdocs /usr/local/apache2/htdocs
EXPOSE 8080
CMD ["httpd", "-D", "FOREGROUND"]
EOF
    
    # Stop any existing container
    podman stop "$CONTAINER_NAME" 2>/dev/null || true
    podman rm "$CONTAINER_NAME" 2>/dev/null || true
    
    # Start container
    podman run -d \
        --name "$CONTAINER_NAME" \
        -p 8080:8080 \
        "$CONTAINER_NAME"
    
    # Wait for Apache to be ready
    local retries=30
    while [ $retries -gt 0 ]; do
        if curl -s "$BASE_URL" > /dev/null 2>&1; then
            echo "Container ready"
            return 0
        fi
        sleep 1
        retries=$((retries - 1))
    done
    
    echo "Container failed to start"
    podman logs "$CONTAINER_NAME"
    return 1
}

# Stop and cleanup the container
stop_fixture() {
    if [ -n "$CONTAINER_NAME" ]; then
        podman stop "$CONTAINER_NAME" 2>/dev/null || true
        podman rm "$CONTAINER_NAME" 2>/dev/null || true
    fi
}

# Make HTTP GET request and return headers
http_get_headers() {
    local path="$1"
    curl -s -I "$BASE_URL$path" 2>/dev/null
}

# Make HTTP GET request and return body
http_get_body() {
    local path="$1"
    curl -s "$BASE_URL$path" 2>/dev/null
}

# Get specific header value
get_header() {
    local headers="$1"
    local header_name="$2"
    echo "$headers" | grep -i "^$header_name:" | cut -d':' -f2- | sed 's/^ *//' | tr -d '\n\r'
}

# Assert header equals expected value
assert_header_equals() {
    local headers="$1"
    local header_name="$2"
    local expected="$3"
    local actual
    actual=$(get_header "$headers" "$header_name")
    
    if [ "$actual" = "$expected" ]; then
        return 0
    else
        echo "Header '$header_name' mismatch: expected '$expected', got '$actual'"
        return 1
    fi
}

# Assert header contains substring
assert_header_contains() {
    local headers="$1"
    local header_name="$2"
    local substring="$3"
    local actual
    actual=$(get_header "$headers" "$header_name")
    
    if echo "$actual" | grep -q "$substring"; then
        return 0
    else
        echo "Header '$header_name' does not contain '$substring': got '$actual'"
        return 1
    fi
}

# Assert header does NOT contain substring
assert_header_not_contains() {
    local headers="$1"
    local header_name="$2"
    local substring="$3"
    local actual
    actual=$(get_header "$headers" "$header_name")
    
    if echo "$actual" | grep -q "$substring"; then
        echo "Header '$header_name' unexpectedly contains '$substring': got '$actual'"
        return 1
    else
        return 0
    fi
}

# Get HTTP status code
http_status() {
    local path="$1"
    curl -s -o /dev/null -w "%{http_code}" "$BASE_URL$path" 2>/dev/null
}
