#!/bin/bash
set -e

IMAGE_NAME="apache-learning"
CONTAINER_NAME="apache-learning"

podman run -d \
  --name "$CONTAINER_NAME" \
  -p 8080:80 \
  -v "$(pwd)/conf:/usr/local/apache2/conf:ro" \
  -v "$(pwd)/htdocs:/usr/local/apache2/htdocs:ro" \
  "$IMAGE_NAME"

echo "Apache running at http://localhost:8080"
echo "Use: podman logs -f apache-learning"
echo "Use: podman stop apache-learning"