#!/bin/bash
set -e

echo "=========================================================================="
echo " Apple T2 Touch Bar & Touch ID Bridge Uninstaller (Ubuntu 24.04 LTS)"
echo "=========================================================================="

if [ "$EUID" -ne 0 ]; then
  echo "[-] Por favor ejecuta como root: sudo ./uninstall.sh"
  exit 1
fi

echo "[*] Deshabilitando y eliminando servicios systemd..."
systemctl disable --now t2-touchid.service 2>/dev/null || true
systemctl disable --now t2-touchid-bridge.service 2>/dev/null || true
rm -f /etc/systemd/system/t2-touchid.service
rm -f /etc/systemd/system/t2-touchid-bridge.service
rm -f /etc/systemd/system/fprintd.service.d/fprintd-t2-touchid.conf
rm -f /lib/systemd/system-sleep/t2-touchid-sleep
rm -f /usr/local/bin/t2-touchid
rm -f /usr/local/sbin/t2-touchid-bridge-init.sh
systemctl daemon-reload
systemctl restart fprintd.service 2>/dev/null || true

echo "[*] Eliminando configuraciones de udev, NetworkManager y modprobe..."
rm -f /etc/NetworkManager/conf.d/10-t2-services.conf
rm -f /etc/udev/rules.d/90-t2-services-ncm.rules
rm -f /etc/modprobe.d/t2-touchbar.conf
rm -rf /etc/kait2en
rm -rf /etc/t2-touchid
udevadm control --reload-rules || true

echo "[+] Desinstalación completada con éxito."
