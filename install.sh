#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root: sudo ./install.sh" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install -Dm755 "${SCRIPT_DIR}/bin/kentut" /usr/local/bin/kentut
install -Dm644 "${SCRIPT_DIR}/systemd/kentut.service" /etc/systemd/system/kentut.service
install -Dm644 "${SCRIPT_DIR}/systemd/kentut.timer" /etc/systemd/system/kentut.timer
install -Dm644 "${SCRIPT_DIR}/systemd/kentut.env" /etc/default/kentut

systemctl daemon-reload
systemctl enable --now kentut.timer

echo "Installed kentut."
echo "Config: /etc/default/kentut"
echo "Timer: kentut.timer"
