#!/usr/bin/env bash
set -euo pipefail
echo "== ModderCam installer =="

sudo apt-get update
sudo apt-get install -y ffmpeg python3-venv python3-pip v4l-utils libatlas-base-dev

TARGET_DIR="$HOME/printer_data/config/ModderCam"
CUR_DIR="$(pwd)"

# Auto-move if not in printer_data/config
if [[ "$CUR_DIR" != *"printer_data/config/ModderCam"* ]]; then
  echo "Moving ModderCam to $TARGET_DIR..."
  mkdir -p "$HOME/printer_data/config"
  mv "$CUR_DIR" "$TARGET_DIR" 2>/dev/null || sudo mv "$CUR_DIR" "$TARGET_DIR"
  cd "$TARGET_DIR"
fi

echo "Installing into: $(pwd)"

python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install aiohttp websockets pyyaml aiortc av numpy

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

echo "✅ ModderCam installed successfully!"
echo "Visit: http://<pi-ip>:8090/"
