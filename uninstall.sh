\
#!/usr/bin/env bash
set -euo pipefail
echo "== ModderCam uninstaller =="
sudo systemctl disable --now moddercam || true
sudo rm -f /etc/systemd/system/moddercam.service
sudo systemctl daemon-reload
echo "Removed service. To delete files: rm -rf ~/printer_data/config/ModderCam"
