#!/bin/bash
set -e

IMAGE_NAME="apache-learning"
CONTAINER_NAME="apache-learning"

podman stop "$CONTAINER_NAME"
podman rm "$CONTAINER_NAME"

echo "Server stopped"
