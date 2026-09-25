#!/usr/bin/env bash
# Smoke test for the static site.
#   ./scripts/check.sh                  -> serves the repo locally and checks it
#   ./scripts/check.sh https://host     -> checks a live deployment, including security headers
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASE="${1:-}"
LIVE="${1:-}"
SERVER_PID=""
FAILS=0

cleanup() {
  if [ -n "$SERVER_PID" ]; then
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

if [ -z "$BASE" ]; then
  PORT=$((20000 + RANDOM % 10000))
  python3 -m http.server "$PORT" --directory "$ROOT" >/dev/null 2>&1 &
  SERVER_PID=$!
  BASE="http://127.0.0.1:$PORT"
  for _ in $(seq 1 20); do
    if curl -sf "$BASE/" >/dev/null 2>&1; then
      break
    fi
    sleep 0.5
  done
fi

STATUS="$(curl -s -L -o /dev/null -w '%{http_code}' "$BASE/")"
BODY="$(curl -s -L "$BASE/")"

check() {
  local name="$1"
  local ok="$2"
  if [ "$ok" = "1" ]; then
    echo "PASS $name"
  else
    echo "FAIL $name"
    FAILS=$((FAILS + 1))
  fi
}

has() {
  grep -q -- "$1" <<<"$2" && echo 1 || echo 0
}

check "HTTP 200 on /" "$([ "$STATUS" = "200" ] && echo 1 || echo 0)"
check "body has <main" "$(has '<main' "$BODY")"
check "body has hero title" "$(has 'Aprende OpenCode' "$BODY")"
check "body has #ruta" "$(has 'id="ruta"' "$BODY")"

if [ -n "$LIVE" ]; then
  HEADERS="$(curl -s -I -L "$BASE/" | tr '[:upper:]' '[:lower:]')"
  check "header x-content-type-options nosniff" "$(has 'x-content-type-options: nosniff' "$HEADERS")"
  check "header x-frame-options deny" "$(has 'x-frame-options: deny' "$HEADERS")"
  check "header referrer-policy" "$(has 'referrer-policy: strict-origin-when-cross-origin' "$HEADERS")"
fi

if [ "$FAILS" -gt 0 ]; then
  echo "RESULT: $FAILS check(s) failed"
  exit 1
fi
echo "RESULT: all checks passed"
