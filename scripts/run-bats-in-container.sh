#!/bin/bash
# Run BATS tests inside a container with access to host podman
# This allows bats to spawn Apache fixture containers

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Build the bats-runner image if needed
echo "🐳 Building bats-runner image..."
podman build -t bats-runner "$PROJECT_ROOT/test" -f "$PROJECT_ROOT/test/Dockerfile"

# Generate a temporary helper script that uses host podman
cat > "$PROJECT_ROOT/test/helper.container.bash" << 'HELPER_EOF'
#!/usr/bin/env bash

FIXTURE_DIR=""
CONTAINER_NAME=""
BASE_URL="http://host.containers.internal:8080"

start_fixture() {
    local fixture_name="$1"
    FIXTURE_DIR="/fixtures/$fixture_name"
    CONTAINER_NAME="apache-test-$fixture_name"
    
    echo "Starting fixture: $fixture_name"
    
    # Build image
    podman build -t "$CONTAINER_NAME" -f - "$FIXTURE_DIR" << EOF
FROM docker.io/library/httpd:2.4
RUN rm -f /usr/local/apache2/conf/httpd.conf /usr/local/apache2/conf/extra/*.conf
COPY conf/httpd.conf /usr/local/apache2/conf/httpd.conf
COPY htdocs /usr/local/apache2/htdocs
EXPOSE 8080
CMD ["httpd", "-D", "FOREGROUND"]
EOF
    
    # Stop existing
    podman stop "$CONTAINER_NAME" 2>/dev/null || true
    podman rm "$CONTAINER_NAME" 2>/dev/null || true
    
    # Start container
    podman run -d \
        --name "$CONTAINER_NAME" \
        -p 8080:8080 \
        "$CONTAINER_NAME"
    
    # Wait for ready
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

stop_fixture() {
    if [ -n "$CONTAINER_NAME" ]; then
        podman stop "$CONTAINER_NAME" 2>/dev/null || true
        podman rm "$CONTAINER_NAME" 2>/dev/null || true
    fi
}

http_get_headers() {
    local path="$1"
    curl -s -I "$BASE_URL$path" 2>/dev/null
}

http_get_body() {
    local path="$1"
    curl -s "$BASE_URL$path" 2>/dev/null
}

get_header() {
    local headers="$1"
    local header_name="$2"
    echo "$headers" | grep -i "^$header_name:" | cut -d':' -f2- | sed 's/^ *//'
}

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

http_status() {
    local path="$1"
    curl -s -o /dev/null -w "%{http_code}" "$BASE_URL$path" 2>/dev/null
}
HELPER_EOF

# Run bats container with host podman socket mounted
echo "🧪 Running BATS tests in container..."
podman run --rm \
    --privileged \
    -v "$PROJECT_ROOT/fixtures:/fixtures:ro" \
    -v "$PROJECT_ROOT/test:/tests:ro" \
    -v "$PROJECT_ROOT/test/helper.container.bash:/tests/helper.bash:ro" \
    -v /run/user/$(id - u)/podman/podman.sock:/var/run/docker.sock:ro \
    -e CONTAINER_HOST=unix:///var/run/docker.sock \
    bats-runner "$@"

# Cleanup temp file
rm -f "$PROJECT_ROOT/test/helper.container.bash"
