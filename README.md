# ModderCam
Hybrid WebRTC + JSMpeg low-latency camera streamer for Klipper, with Jinja2-kosher macros.
# ![ModderCam Logo](https://img.shields.io/badge/MODDERCAM-KLIPPER%20CAM%20STREAMER-00ff9c?style=for-the-badge&logo=raspberrypi)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.9%2B-brightgreen.svg?style=flat-square&logo=python)](https://www.python.org)
[![Platform](https://img.shields.io/badge/platform-Raspberry%20Pi-red?style=flat-square&logo=raspberrypi)]()
[![Latency](https://img.shields.io/badge/latency-100ms-lightgrey.svg?style=flat-square)]()
[![Klipper](https://img.shields.io/badge/compatible-Kalico%20%7C%20Danger%20Klipper-orange.svg?style=flat-square)]()

---

# ModderCam — Hybrid WebRTC + JSMpeg streamer for Klipper

**ModderCam** is a modern drop-in replacement for Crowsnest — a lightweight hybrid camera streamer optimized for Klipper systems.  
It provides **real-time WebRTC streaming** with fallback to **JSMpeg** for legacy browsers,  
and comes with **Jinja2-safe macros** for full control from your printer.

---

## Features
- ** Hybrid engine:** WebRTC (<120 ms latency) + JSMpeg fallback  
- ** Jinja2‑safe macros:** Start, stop, restart, snapshot from Fluidd/Mainsail  
- ** Systemd service:** Automatic startup and restart  
- ** Easy integration:** Runs alongside Moonraker / KlipperScreen  
- ** UI:** Auto‑switch between WebRTC and fallback stream, minimal HTML/JS  

---

##  Install
```bash
cd ~/printer_data/config
git clone https://github.com/TheVoronModder/ModderCam.git
cd ModderCam
chmod +x install.sh uninstall.sh
./install.sh
```
Then open your browser:  
 `http://<pi-ip>:8090/`

## Update Manager
```bash
[update_manager ModderCam]
type: git_repo
origin: https://github.com/TheVoronModder/ModderCam.git
path: ~/printer_data/config/ModderCam
primary_branch: main
install_script: install.sh
uninstall_script: uninstall.sh
managed_services: moddercam
refresh_interval: 168



```
---

##  Klipper Integration
Add to your `printer.cfg`:
```ini
[include ModderCam/klipper/moddercam.cfg]
```

### Available Macros
| Macro | Description |
|--------|--------------|
| `MODDERCAM_ON` | Start the service |
| `MODDERCAM_OFF` | Stop the service |
| `MODDERCAM_RESTART` | Restart service |
| `MODDERCAM_STATUS` | Check systemd status |
| `MODDERCAM_URL` | Show stream URL |
| `MODDERCAM_SNAPSHOT` | Capture still image |

---

##  Configuration
Edit `config.yaml` for custom camera modes, bitrate, or ports.

Example:
```yaml
device: "/dev/video0"
http_port: 8090
ws_port: 8091
bitrate_kbps: 3000
webrtc:
  codec: "h264"
  bitrate_kbps: 2500
```

---

##  Compatibility
- ✅ Kalico / Danger Klipper  
- ✅ Mainsail / Fluidd / KlipperScreen  
- ✅ Raspberry Pi 4B / 5 / Zero 2 W  
- ✅ Works with MJPEG / YUYV USB cameras  

---

##  Development Roadmap
| Goal | Status |
|------|--------|
| WebRTC data channel for stats overlay | 🧩 Planned |
| Multi‑camera support | 🧩 Planned |
| GPU (MMAL / libcamera) acceleration | 🧩 Planned |
| REST API endpoints | ✅ Basic |
| Full Moonraker proxy integration | 🧩 Planned |

---

##  License
**MIT License** — use freely with attribution.  
© 2025 TheVoronModder
