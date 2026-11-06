#!/bin/bash
set -e

echo "=========================================================================="
echo " Apple T2 Touch Bar & Touch ID Bridge Installer for Ubuntu 24.04 LTS"
echo " Author: Juan Monzón (@mylnzon58)"
echo " Based on KAIT2EN architecture, adapted for Ubuntu LTS / Debian"
echo "=========================================================================="

if [ "$EUID" -ne 0 ]; then
  echo "[-] Por favor ejecuta como root: sudo ./install.sh"
  exit 1
fi

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

echo "[+] 1. Configurando NetworkManager para enlace CDC-NCM..."
mkdir -p /etc/NetworkManager/conf.d
cp "$SCRIPT_DIR/config/10-t2-services.conf" /etc/NetworkManager/conf.d/10-t2-services.conf

echo "[+] 2. Instalando reglas udev para IPv6 link-local automática..."
cp "$SCRIPT_DIR/config/90-t2-services-ncm.rules" /etc/udev/rules.d/90-t2-services-ncm.rules
udevadm control --reload-rules || true

echo "[+] 3. Configurando opciones de debouncing y atenuación de Touch Bar..."
cp "$SCRIPT_DIR/config/t2-touchbar.conf" /etc/modprobe.d/t2-touchbar.conf

echo "[+] 4. Instalando configuración de Touch ID..."
mkdir -p /etc/t2-touchid
cp "$SCRIPT_DIR/config/t2-touchid.conf" /etc/t2-touchid/t2-touchid.conf

echo "[+] 5. Instalando script de inicialización de enlace..."
cp "$SCRIPT_DIR/config/t2-touchid-bridge-init.sh" /usr/local/sbin/t2-touchid-bridge-init.sh
chmod +x /usr/local/sbin/t2-touchid-bridge-init.sh

echo "[+] 6. Configurando y habilitando servicio systemd persistente..."
cp "$SCRIPT_DIR/config/t2-touchid-bridge.service" /etc/systemd/system/t2-touchid-bridge.service
systemctl daemon-reload
systemctl enable --now t2-touchid-bridge.service

echo "[+] 7. Ejecutando sintonización en vivo..."
/usr/local/sbin/t2-touchid-bridge-init.sh

echo "=========================================================================="
echo " [+] ¡Instalación completada con éxito!"
echo " Ejecutando verificación de comunicación con el chip Apple T2..."
echo "=========================================================================="
python3 "$SCRIPT_DIR/scripts/test-t2-bridge.py" || true
