# 🚀 ModderCam v1.0.0 — Release Notes

**Date:** October 29, 2025

### Summary
First full public release of **ModderCam**, a hybrid WebRTC + JSMpeg low-latency camera streamer for Klipper (RPi).  
Includes Jinja2‑kosher macros, systemd service, and a minimal adaptive UI.

### Highlights
- WebRTC (aiortc) primary path; JSMpeg fallback
- Klipper macros pack for service control + snapshots
- One-line installer: venv, deps, systemd
- Configurable modes/bitrate via `config.yaml`

### Install
```bash
cd ~/printer_data/config
git clone https://github.com/TheVoronModder/ModderCam.git
cd ModderCam
chmod +x install.sh uninstall.sh
./install.sh
```
Open: `http://<pi-ip>:8090/`

### Changelog
- v1.0.0 — initial release
