#!/usr/bin/env bash
set -euo pipefail

docker compose exec -T \
    -e NEXUS_BASE_URL="${NEXUS_BASE_URL:-http://nexus:8081}" \
    jdk \
    bash -lc "cd /workspace && gradle clean run"
