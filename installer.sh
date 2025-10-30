#!/usr/bin/env bash
set -euo pipefail

# -------- Settings (hardcode to your repo) --------
GH_USER="${GH_USER:-TheVoronModder}"
GH_REPO="${GH_REPO:-ModderCam}"
GH_REF="${GH_REF:-main}"

# Pass-through flags to installer.sh
ARGS=("$@")

# -------- Preflight --------
command -v curl >/dev/null 2>&1 || { echo "curl is required"; exit 1; }
if ! command -v unzip >/dev/null 2>&1; then
  echo "[ModderCam] Installing unzip..."
  sudo apt-get update -y && sudo apt-get install -y unzip
fi

TMP_DIR="$(mktemp -d)"
cleanup(){ rm -rf "$TMP_DIR"; }
trap cleanup EXIT

ZIP_URL="https://github.com/${GH_USER}/${GH_REPO}/archive/refs/heads/${GH_REF}.zip"

echo "[ModderCam] Fetching ${ZIP_URL} ..."
curl -fsSL "$ZIP_URL" -o "$TMP_DIR/src.zip"

echo "[ModderCam] Extracting..."
unzip -q "$TMP_DIR/src.zip" -d "$TMP_DIR"
SRC_DIR="$(find "$TMP_DIR" -maxdepth 1 -type d -name "${GH_REPO}-*" | head -n1)"
[ -d "$SRC_DIR" ] || { echo "Archive missing expected folder"; exit 2; }

echo "[ModderCam] Running installer.sh ..."
cd "$SRC_DIR"
chmod +x installer.sh || true
./installer.sh "${ARGS[@]}"

echo "[ModderCam] Done."

