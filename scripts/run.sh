#!/usr/bin/env bash
set -euo pipefail

export HOST=${HOST:-127.0.0.1}
export PORT=${PORT:-3000}
export DATA_STORE_PATH=${DATA_STORE_PATH:-db/data.json}

exec ruby scripts/server.rb
