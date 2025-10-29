\
#!/usr/bin/env bash
set -euo pipefail
echo "== ModderCam installer =="

sudo apt-get update
sudo apt-get install -y ffmpeg python3-venv python3-pip v4l-utils libatlas-base-dev

APP_DIR="$HOME/printer_data/config/ModderCam"
if [[ ! -d "$APP_DIR" ]]; then
  echo "Please clone this repo at $APP_DIR first."
  exit 1
fi
cd "$APP_DIR"

python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install aiohttp websockets pyyaml
pip install aiortc av numpy

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

echo "Installed. Visit http://<pi-ip>:8090/"
