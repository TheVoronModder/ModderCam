#!/usr/bin/env bash
set -euo pipefail

KLIP_DIR="${KLIP_DIR:-$HOME/printer_data}"
CFG_DIR="$KLIP_DIR/config"

echo "[ModderCam] Stopping and disabling service..."
sudo systemctl stop moddercam || true
sudo systemctl disable moddercam || true

echo "[ModderCam] Removing systemd files..."
sudo rm -f /etc/systemd/system/moddercam.service
sudo rm -f /etc/default/moddercam
sudo systemctl daemon-reload || true

echo "[ModderCam] Removing macros and scripts..."
rm -rf "$CFG_DIR/moddercam" "$CFG_DIR/scripts/snapshot.sh" "$CFG_DIR/scripts/streamctl.sh" || true

# Comment include line (safer than delete)
PCFG="$CFG_DIR/printer.cfg"
if [ -f "$PCFG" ]; then
  sed -i 's/^\([[:space:]]*\[include[[:space:]]\+moddercam\/moddercam\.cfg\].*\)$/# \1/' "$PCFG" || true
fi

echo "[ModderCam] Uninstalled. (Your snapshots remain in ~/printer_data/media/moddercam)."
