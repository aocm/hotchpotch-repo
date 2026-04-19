#!/usr/bin/env bash
set -euo pipefail

NEXUS_BASE_URL="${NEXUS_BASE_URL:-http://localhost:8081}"
MAX_RETRIES="${MAX_RETRIES:-90}"
SLEEP_SECONDS="${SLEEP_SECONDS:-5}"

for ((attempt = 1; attempt <= MAX_RETRIES; attempt++)); do
    if curl -fsS "${NEXUS_BASE_URL}/service/rest/v1/status" >/dev/null 2>&1; then
        echo "Nexus is ready at ${NEXUS_BASE_URL}"
        exit 0
    fi

    echo "Waiting for Nexus (${attempt}/${MAX_RETRIES})..."
    sleep "${SLEEP_SECONDS}"
done

echo "Nexus did not become ready in time." >&2
exit 1
