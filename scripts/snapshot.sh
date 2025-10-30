#!/usr/bin/env bash
set -euo pipefail
SNAP_URL="${1:-http://127.0.0.1:8080/?action=snapshot}"
OUT_DIR="${OUT_DIR:-$HOME/printer_data/media/moddercam}"
mkdir -p "$OUT_DIR"
ts="$(date +'%Y%m%d_%H%M%S')"
out="$OUT_DIR/snap_${ts}.jpg"
curl -fsSL "$SNAP_URL" -o "$out"
echo "Saved $out"
