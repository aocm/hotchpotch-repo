#!/usr/bin/env bash
set -euo pipefail

docker compose exec -T \
    -e NEXUS_BASE_URL="${NEXUS_BASE_URL:-http://nexus:8081}" \
    -e NEXUS_USERNAME="${NEXUS_USERNAME:-admin}" \
    -e NEXUS_PASSWORD="${NEXUS_PASSWORD:-admin123}" \
    jdk \
    bash -lc "cd /workspace && gradle clean publish"
