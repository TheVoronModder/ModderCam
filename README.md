# ModderCam (Standalone) — Camera Integration for Mainsail + Klipper (No Crowsnest)

**ModderCam (Standalone)** installs a lightweight `mjpg-streamer` service with
sane defaults, integrates Klipper macros for snapshots, and provides importable
Mainsail buttons. It also **disables (and optionally removes) Crowsnest**.

---

## TL;DR (fresh install)
```bash
git clone --depth=1 git@github.com:TheVoronModder/ModderCam.git /tmp/moddercam && \
cd /tmp/moddercam && chmod +x installer.sh && \
./installer.sh --disable-crowsnest --autostart --port=8080 --res=1280x720 --fps=30

```
Then in Mainsail: Settings → UI Settings → Custom Actions → Import →
`mainsail/moddercam_buttons.json`

---

## What you get
- `moddercam/moddercam.cfg` — Klipper macros (snapshot / stream ping)
- `scripts/snapshot.sh` — saves to `~/printer_data/media/moddercam`
- `scripts/streamctl.sh` — ping stream endpoint (health)
- `systemd/moddercam.service` — systemd unit for mjpg-streamer
- `etc-default/moddercam` — environment file (DEVICE/RES/FPS/PORT/options)
- `mainsail/moddercam_buttons.json` — importable buttons
- `installer.sh` / `uninstall.sh` — automate install/remove
- `README.md` — this file

---

## Installer flags
- `--disable-crowsnest` : Stop + disable Crowsnest service (non-destructive)
- `--remove-crowsnest`  : Also remove common Crowsnest files (destructive)
- `--autostart`         : Enable + start ModderCam service on boot
- `--port=8080`         : Stream HTTP port (default 8080)
- `--device=/dev/video0`: Camera device (default auto-detect the first UVC cam)
- `--res=1280x720`      : Resolution (e.g. 1920x1080)
- `--fps=30`            : Frames per second

You can edit `/etc/default/moddercam` anytime and `sudo systemctl restart moddercam`.

---

## Requirements
- Debian/Raspberry Pi OS-based Klipper host
- `sudo` available
- A UVC-compatible USB camera (most webcams work)
- `mjpg-streamer` (installer will try `sudo apt-get install -y mjpg-streamer`)

---

## Uninstall
```bash
./uninstall.sh
# (optional) Re-enable Crowsnest if you previously disabled it:
sudo systemctl enable --now crowsnest || true
```

---

## Mainsail buttons
Import `mainsail/moddercam_buttons.json`:
- **ModderCam: Snapshot** → `MODDERCAM_SNAPSHOT`
- **ModderCam: Stream ON (Ping)** → `MODDERCAM_STREAM_ON`
- **ModderCam: Stream OFF (Note)** → `MODDERCAM_STREAM_OFF`

---

## Troubleshooting
- Stream URL: `http://<printer-host>:8080/?action=stream`
- Snapshot URL: `http://<printer-host>:8080/?action=snapshot`
- Check service: `systemctl status moddercam`
- Logs: `journalctl -u moddercam -e`
- Camera list: `v4l2-ctl --list-devices` (install with `sudo apt-get install v4l-utils`)
- If you changed port/res/fps, edit `/etc/default/moddercam` and restart service.

---

## License
MIT
