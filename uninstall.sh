#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run as root: sudo ./uninstall.sh" >&2
  exit 1
fi

systemctl disable --now kentut.timer 2>/dev/null || true
systemctl stop kentut.service 2>/dev/null || true

rm -f /etc/systemd/system/kentut.timer
rm -f /etc/systemd/system/kentut.service
rm -f /usr/local/bin/kentut

systemctl daemon-reload

echo "Uninstalled kentut."
echo "Config preserved at /etc/default/kentut"
