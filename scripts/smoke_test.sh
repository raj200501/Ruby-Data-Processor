#!/usr/bin/env bash
set -euo pipefail

export PORT=${PORT:-4567}
export HOST=${HOST:-127.0.0.1}
export DATA_STORE_PATH=${DATA_STORE_PATH:-tmp/smoke_data.json}

mkdir -p tmp

ruby scripts/server.rb > tmp/smoke.log 2>&1 &
SERVER_PID=$!

cleanup() {
  kill "$SERVER_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

ruby scripts/wait_for_port.rb "$PORT" 30

curl -sSf "http://${HOST}:${PORT}/health" > /dev/null

create_payload='{"data_record":{"name":"Pressure","value":101.2,"source":"smoke","metadata":{"unit":"kPa"}}}'
created=$(curl -sSf -X POST "http://${HOST}:${PORT}/data" \
  -H 'Content-Type: application/json' \
  -d "$create_payload")

ruby -rjson -e "data = JSON.parse(ARGF.read); exit(1) unless data['id']" <<< "$created"

summary=$(curl -sSf "http://${HOST}:${PORT}/data/summary")

ruby -rjson -e "data = JSON.parse(ARGF.read); exit(1) unless data['count'] >= 1" <<< "$summary"
