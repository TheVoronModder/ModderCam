#!/usr/bin/env bash
set -euo pipefail
echo "== ModderCam installer =="

# --- System dependencies ---
sudo apt-get update
sudo apt-get install -y ffmpeg python3-venv python3-pip v4l-utils libatlas-base-dev

# --- Paths ---
USER_HOME=$(eval echo ~${SUDO_USER:-$USER})
CONFIG_ROOT="$USER_HOME/printer_data/config"
TARGET_DIR="$CONFIG_ROOT/ModderCam"
CUR_DIR="$(pwd)"

# --- If not already in config, move it there ---
if [[ "$CUR_DIR" != *"printer_data/config/ModderCam"* ]]; then
  echo "Moving ModderCam repo into $TARGET_DIR ..."
  mkdir -p "$CONFIG_ROOT"
  # Copy recursively in case filesystem permissions differ
  rsync -a --remove-source-files "$CUR_DIR"/ "$TARGET_DIR"/ 2>/dev/null || sudo rsync -a "$CUR_DIR"/ "$TARGET_DIR"/
  cd "$TARGET_DIR"
fi

echo "Installing into: $(pwd)"

# --- Python environment setup ---
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install aiohttp websockets pyyaml aiortc av numpy

# --- Systemd service setup ---
SERVICE=/etc/systemd/system/moddercam.service
sudo bash -c "cat > $SERVICE" <<'UNIT'
[Unit]
Description=ModderCam - Hybrid WebRTC/JSMpeg streamer for Klipper
After=network-online.target

[Service]
Type=simple
User=pi
WorkingDirectory=%h/printer_data/config/ModderCam
ExecStart=%h/printer_data/config/ModderCam/.venv/bin/python %h/printer_data/config/ModderCam/moddercam.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload
sudo systemctl enable moddercam
sudo systemctl restart moddercam

echo ""
echo "✅ ModderCam installed successfully!"
echo "Visit your stream at: http://<pi-ip>:8090/"
echo ""
