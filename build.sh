#!/bin/bash
set -e

IMAGE_NAME="apache-learning"

podman build -t "$IMAGE_NAME" .
echo "Built image: $IMAGE_NAME"