#!/usr/bin/env bash
set -euo pipefail

KLIP_DIR="${KLIP_DIR:-$HOME/printer_data}"
CFG_DIR="$KLIP_DIR/config"
MEDIA_DIR="$KLIP_DIR/media/moddercam"
PORT="8080"
DEVICE="auto"
RES="1280x720"
FPS="30"
DISABLE_CROWSNEST="0"
REMOVE_CROWSNEST="0"
AUTOSTART="0"

for arg in "$@"; do
  case "$arg" in
    --port=*) PORT="${arg#*=}"; shift ;;
    --device=*) DEVICE="${arg#*=}"; shift ;;
    --res=*) RES="${arg#*=}"; shift ;;
    --fps=*) FPS="${arg#*=}"; shift ;;
    --disable-crowsnest) DISABLE_CROWSNEST="1"; shift ;;
    --remove-crowsnest) REMOVE_CROWSNEST="1"; DISABLE_CROWSNEST="1"; shift ;;
    --autostart) AUTOSTART="1"; shift ;;
    *) ;;
  esac
done

echo "[ModderCam] Preparing directories..."
mkdir -p "$CFG_DIR/moddercam" "$CFG_DIR/scripts" "$CFG_DIR/mainsail" "$MEDIA_DIR"

echo "[ModderCam] Installing macros and scripts..."
cp -r moddercam "$CFG_DIR/"
cp -r scripts "$CFG_DIR/"
cp mainsail/moddercam_buttons.json "$CFG_DIR/mainsail/"
chmod +x "$CFG_DIR/scripts/"*.sh || true

# Ensure include in printer.cfg
PCFG="$CFG_DIR/printer.cfg"
if ! grep -q '^[[:space:]]*\[include[[:space:]]\+moddercam/moddercam\.cfg\]' "$PCFG" 2>/dev/null; then
  echo -e "\n[include moddercam/moddercam.cfg]" >> "$PCFG"
  echo "[ModderCam] Added include to printer.cfg"
fi

# Optionally disable/remove Crowsnest
if [ "$DISABLE_CROWSNEST" = "1" ]; then
  echo "[ModderCam] Disabling Crowsnest..."
  sudo systemctl stop crowsnest || true
  sudo systemctl disable crowsnest || true
  if [ "$REMOVE_CROWSNEST" = "1" ]; then
    echo "[ModderCam] Removing Crowsnest files (destructive)."
    sudo rm -rf "$CFG_DIR/crowsnest.conf" /home/pi/crowsnest /home/pi/crowsnest-env || true
  fi
fi

# Install mjpg-streamer if missing
if ! command -v mjpg_streamer >/dev/null 2>&1; then
  echo "[ModderCam] Installing mjpg-streamer via apt..."
  sudo apt-get update -y && sudo apt-get install -y mjpg-streamer || {
    echo "[ModderCam] Could not install mjpg-streamer automatically. Install it and re-run installer."
    exit 1
  }
fi

# Place systemd unit and defaults
echo "[ModderCam] Installing systemd unit..."
sudo cp systemd/moddercam.service /etc/systemd/system/moddercam.service
sudo cp etc-default/moddercam /etc/default/moddercam

# Configure /etc/default/moddercam
if [ "$DEVICE" = "auto" ]; then
  if [ -e /dev/video0 ]; then DEVICE="/dev/video0"; else DEVICE="/dev/video1"; fi
fi
sudo sed -i "s|^DEVICE=.*$|DEVICE=${DEVICE}|" /etc/default/moddercam
sudo sed -i "s|^RES=.*$|RES=${RES}|" /etc/default/moddercam
sudo sed -i "s|^FPS=.*$|FPS=${FPS}|" /etc/default/moddercam
sudo sed -i "s|^PORT=.*$|PORT=${PORT}|" /etc/default/moddercam

echo "[ModderCam] Reloading systemd..."
sudo systemctl daemon-reload

if [ "$AUTOSTART" = "1" ]; then
  echo "[ModderCam] Enabling and starting service..."
  sudo systemctl enable --now moddercam
else
  echo "[ModderCam] You can start the service now: sudo systemctl start moddercam"
fi

echo "[ModderCam] Restarting Klipper..."
sudo systemctl restart klipper || true

echo "[ModderCam] Done. Stream: http://<host>:${PORT}/?action=stream"
