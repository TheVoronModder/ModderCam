#!/usr/bin/env bash
set -euo pipefail
CMD="${1:-ping}"
STREAM_URL="${STREAM_URL:-http://127.0.0.1:8080/?action=stream}"
case "$CMD" in
  ping)
    if curl -fsSIL --max-time 3 "$STREAM_URL" >/dev/null; then
      echo "Stream OK: $STREAM_URL"
    else
      echo "Stream unreachable: $STREAM_URL" >&2
      exit 1
    fi
    ;;
  *)
    echo "Usage: $0 ping" >&2
    exit 2
    ;;
esac
