#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

NEXUS_BASE_URL="${NEXUS_BASE_URL:-http://localhost:8081}"
TARGET_ADMIN_PASSWORD="${TARGET_ADMIN_PASSWORD:-admin123}"
HOSTED_REPOSITORY_NAME="${HOSTED_REPOSITORY_NAME:-legacy-maven-hosted}"

cd "${PROJECT_ROOT}"

bash "${SCRIPT_DIR}/wait-for-nexus.sh"

if curl -fsS -u "admin:${TARGET_ADMIN_PASSWORD}" \
    "${NEXUS_BASE_URL}/service/rest/v1/repositories" >/dev/null 2>&1; then
    echo "Nexus admin password is already set."
else
    INITIAL_ADMIN_PASSWORD="$(bash "${SCRIPT_DIR}/get-nexus-admin-password.sh" | tr -d '\r')"

    curl -fsS -u "admin:${INITIAL_ADMIN_PASSWORD}" \
        -X PUT \
        -H "Content-Type: text/plain" \
        --data "${TARGET_ADMIN_PASSWORD}" \
        "${NEXUS_BASE_URL}/service/rest/v1/security/users/admin/change-password"

    echo
    echo "Nexus admin password changed to ${TARGET_ADMIN_PASSWORD}"
fi

EULA_RESPONSE="$(curl -fsS -u "admin:${TARGET_ADMIN_PASSWORD}" \
    "${NEXUS_BASE_URL}/service/rest/v1/system/eula")"

if printf '%s' "${EULA_RESPONSE}" \
    | python3 -c "import json, sys; sys.exit(0 if json.load(sys.stdin).get('accepted') else 1)"
then
    echo "Nexus EULA is already accepted."
else
    printf '%s' "${EULA_RESPONSE}" \
        | python3 -c "import json, sys; payload = json.load(sys.stdin); print(json.dumps({'accepted': True, 'disclaimer': payload['disclaimer']}))" \
        | curl -fsS -u "admin:${TARGET_ADMIN_PASSWORD}" \
            -X POST \
            -H "Content-Type: application/json" \
            "${NEXUS_BASE_URL}/service/rest/v1/system/eula" \
            --data @-

    echo
    echo "Nexus EULA accepted for the sample environment."
fi

if curl -fsS -u "admin:${TARGET_ADMIN_PASSWORD}" \
    "${NEXUS_BASE_URL}/service/rest/v1/repositories" \
    | HOSTED_REPOSITORY_NAME="${HOSTED_REPOSITORY_NAME}" python3 -c "import json, os, sys; target = os.environ['HOSTED_REPOSITORY_NAME']; repositories = json.load(sys.stdin); sys.exit(0 if any(repo.get('name') == target for repo in repositories) else 1)"
then
    echo "Hosted repository ${HOSTED_REPOSITORY_NAME} already exists."
else
    curl -fsS -u "admin:${TARGET_ADMIN_PASSWORD}" \
        -X POST \
        -H "Content-Type: application/json" \
        "${NEXUS_BASE_URL}/service/rest/v1/repositories/maven/hosted" \
        --data @- <<EOF
{
  "name": "${HOSTED_REPOSITORY_NAME}",
  "online": true,
  "storage": {
    "blobStoreName": "default",
    "strictContentTypeValidation": true,
    "writePolicy": "ALLOW"
  },
  "component": {
    "proprietaryComponents": true
  },
  "maven": {
    "versionPolicy": "MIXED",
    "layoutPolicy": "STRICT",
    "contentDisposition": "ATTACHMENT"
  }
}
EOF

    echo
    echo "Hosted repository ${HOSTED_REPOSITORY_NAME} created."
fi

echo "Repositories available for this sample:"
echo "  - ${NEXUS_BASE_URL}/repository/${HOSTED_REPOSITORY_NAME}/"
