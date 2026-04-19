#!/usr/bin/env bash
set -euo pipefail

docker compose exec -T nexus sh -c 'cat /nexus-data/admin.password'
