FROM docker.io/library/alpine:latest

# Install bats-core and dependencies
RUN apk add --no-cache \
    bash \
    curl \
    git \
    coreutils \
    && git clone https://github.com/bats-core/bats-core.git /tmp/bats \
    && cd /tmp/bats \
    && ./install.sh /usr/local \
    && rm -rf /tmp/bats

# Install podman-remote (client only, connects to host podman)
RUN apk add --no-cache podman-remote

# Set up working directory
WORKDIR /tests

# Default command runs all tests
CMD ["bats", "--tap", "."]
