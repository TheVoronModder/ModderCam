#!/usr/bin/env bash
set -euo pipefail
CFG_DIR="$HOME/printer_data/config/ModderCam"
OUT_DIR="$HOME/printer_data/snapshots"
mkdir -p "$OUT_DIR"
DEVICE="$(grep '^device:' "$CFG_DIR/config.yaml" | awk '{print $2}' | tr -d '"' || echo /dev/video0)"
W=1280; H=720
TS="$(date +%Y%m%d-%H%M%S)"
OUT="$OUT_DIR/moddercam_${TS}.jpg"
ffmpeg -hide_banner -loglevel error -f video4linux2 -video_size "${W}x${H}" -i "${DEVICE}" -vframes 1 -y "$OUT"
echo "SNAPSHOT:$OUT"
